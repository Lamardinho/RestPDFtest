package com.rest.app.webRest.domain

import com.rest.app.dataBase.MyPdfURLs.getExportPDF
import com.rest.app.dataBase.MyPdfURLs.getInternetPayOrderJrxml
import com.rest.app.dataBase.tables.OrderTable
import net.sf.jasperreports.engine.*
import java.sql.DriverManager
import java.sql.SQLException
import java.sql.Timestamp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class BasePayMakeOrder {

    // save order on server
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun makeOrderOnServer(loginName: String, service: String, pay: Int) {
        val jasperPrint = processReport(loginName, service, pay)
        JasperExportManager.exportReportToPdfFile(jasperPrint, getExportPDF(loginName + "_" + myDate()))
        println("method makeReport is done! New file created: " + loginName + "_" + myDate())
    }

    // just from browser download
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun makeOrderDownload(loginName: String, service: String, pay: Int): ByteArray {
        val jasperPrint = processReport(loginName, service, pay)
        println("method makeReport is done! New file created: " + loginName + "_" + myDate())
        return JasperExportManager.exportReportToPdf(jasperPrint)
    }

    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun processReport(loginName: String, service: String, pay: Int): JasperPrint? {
        Class.forName("org.postgresql.Driver") // указываем для того, чтобы Tomcat подхватил драйвер
        val timestamp = Timestamp.valueOf(LocalDateTime.now()) // для вставки даты
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareCall("SELECT * FROM rtk.public.make_order(?,?,?,?)").use { callableStatement ->
                callableStatement.setTimestamp(1, timestamp) // 1ый '?' wildCard
                callableStatement.setString(2, loginName) // 2ой '?' wildCard
                callableStatement.setString(3, service) // 3ий '?' wildCard
                callableStatement.setInt(4, pay) // 4ый '?' wildCard
                println("You paid $pay RUB")
                callableStatement.executeQuery().use { resultSet ->
                    if (resultSet.next()) {
                        // заполняем объект order данными из БД, для послед.наполнения мапы
                        val order = OrderTable()
                        order.orderNumber = resultSet.getInt(1)
                        order.timestamp = resultSet.getTimestamp(2)
                        order.customer = resultSet.getString(3)
                        order.service = resultSet.getString(4)
                        order.pay = resultSet.getInt(5)
                        // наполняем мапу параметрами для JasperReports
                        val parameters: MutableMap<String, Any> = HashMap() // Parameters for report
                        parameters["order_number"] = order.orderNumber
                        parameters["jr_name"] = order.customer // customer name
                        parameters["jr_data"] = timestamp
                        parameters["jr_service"] = order.service
                        parameters["jr_pay"] = order.pay
                        // формируем отчёт
                        val dataSource: JRDataSource = JREmptyDataSource() // без него будут пустые отчеты
                        val jrxmlFile = JasperCompileManager.compileReport(getInternetPayOrderJrxml()) // от куда берём jrxml файл
                        return JasperFillManager.fillReport(jrxmlFile, parameters, dataSource) // JasperPrint - заполняет шаблон
                    }
                }
            }
        }
        return null
    }

    fun myDate(): String {
        val myDate = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss")
        val myNow = LocalDateTime.now()
        return myDate.format(myNow)
    }
}

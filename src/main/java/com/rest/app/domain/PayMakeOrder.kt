package com.rest.app.domain

import com.rest.app.dataBase.MyPdfURLs.getExportPDF
import com.rest.app.dataBase.MyPdfURLs.getInternetPayOrderJrxml
import com.rest.app.dataBase.tables.OrderTable
import net.sf.jasperreports.engine.*
import java.sql.DriverManager
import java.sql.SQLException
import java.sql.Timestamp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.concurrent.*

class PayMakeOrder {

    private val executor = ThreadPoolExecutor(4, 6,
            1, TimeUnit.MILLISECONDS, LinkedBlockingQueue())

    // метод для сохранения отчета на сервере
    @Throws(Exception::class)
    public fun makeOrderOnServer(loginName: String, service: String, pay: Int): Future<String>? {
        val future = executor.submit(MyCallable(loginName, service, pay))
        JasperExportManager.exportReportToPdfFile(future.get(),
                getExportPDF(loginName + "_" + myDate()))
        println("method makeReport is done! New file created: " + loginName + "_" + myDate())
        return null
    }

    // метод для сохранения отчета только на стороне клиента через браузер
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class, ExecutionException::class, InterruptedException::class)
    public fun makeOrderDownload(loginName: String, service: String, pay: Int): ByteArray {
        val future = executor.submit(MyCallable(loginName, service, pay))
        println("method makeReport is done! New file created: " + loginName + "_" + myDate())
        return JasperExportManager.exportReportToPdf(future.get()) // возвращаем массив байт
    }

    fun myDate(): String {  // возвращает текущую отформатированную дату
        return DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss").format(LocalDateTime.now())
    }

    internal class MyCallable(var loginName: String, var service: String, var pay: Int) : Callable<JasperPrint> {
        @Throws(Exception::class)
        override fun call(): JasperPrint? {
            return processReport()
        }

        @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
        private fun processReport(): JasperPrint? {
            Class.forName("org.postgresql.Driver") // указываем для того, чтобы Tomcat подхватил драйвер
            val timestamp = Timestamp.valueOf(LocalDateTime.now()) // для вставки даты в базу данных
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
                            // заполняем объект order данными из БД, для наполнения мапы параметров JasperReports
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
                            return JasperFillManager.fillReport(JasperCompileManager.compileReport(getInternetPayOrderJrxml())
                                    , parameters, JREmptyDataSource())
                        }
                    }
                }
            }
            return null
        }
    }
}

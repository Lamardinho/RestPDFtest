package com.rest.app.webRest

import com.rest.app.dataBase.MyPdfURLs.getDirWay
import com.rest.app.dataBase.MyPdfURLs.getExportPDF
import com.rest.app.dataBase.MyPdfURLs.getInternetPayOrderJrxml
import com.rest.app.dataBase.tables.OrderTable
import net.sf.jasperreports.engine.*
import java.io.File
import java.sql.DriverManager
import java.sql.SQLException
import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.*
import javax.ws.rs.*
import javax.ws.rs.core.MediaType

@Path("/MakeOrderInternetOnServer")
class MakeOrderInternetOnServer {

    @GET
    @Produces(MediaType.APPLICATION_JSON) // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON) // тип данных получаемых от клиента в теле запроса
    fun hello(): String {
        return "Hello " + System.getProperty("user.name") + "!"
    }

    // добавить Order
    // http://localhost:8080/RestPDFtest_war_exploded/rest/MakeOrderInternetOnServer/Marcus?pay=500
    @GET
    @Path("/{user}") // @Path("/{user}/{pay}")       /Marcus?pay=500
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun addNewOrder(@PathParam("user") loginName: String, @QueryParam("pay") pay: Int): String {
        Class.forName("org.postgresql.Driver") // указываем для того, чтобы Tomcat подхватил драйвер
        val timestamp = Timestamp.valueOf(LocalDateTime.now()) // для вставки даты
        var jasperPrint: JasperPrint
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareCall("SELECT * FROM rtk.public.make_order(?,?,'internet',?)").use { callableStatement ->
                callableStatement.setTimestamp(1, timestamp) // 1ый '?' wildCard
                callableStatement.setString(2, loginName) // 2ой '?' wildCard
                callableStatement.setInt(3, pay) // 3ий '?' wildCard
                /*boolean hasResults = callableStatement.execute();
                        while (hasResults) {ResultSet resultSet = callableStatement.getResultSet();
                            while (resultSet.next()) {System.out.println(resultSet.getInt(1));}
                            hasResults = callableStatement.getMoreResults();}*/println("You paid $pay RUB")
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
                        jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource) // JasperPrint - заполняет шаблон
                        val outDir = File(getDirWay()) // проверка и создание пути для экспорта PDF файла
                        outDir.mkdirs()
                        JasperExportManager.exportReportToPdfFile(jasperPrint, getExportPDF("MakeOrderInternetOnServer")) // Экспорт данных в PDF файл
                        println("method makeReport is done! New file created: $loginName") // для отчёта
                        println(order)
                    }
                }
            }
        }
        return "You paid $pay RUB"
    }
}

package com.rest.app.webRest

import com.rest.app.dataBase.MyPdfURLs.getInternetPayOrderJrxml
import com.rest.app.dataBase.tables.OrderTable
import net.sf.jasperreports.engine.*
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.SQLException
import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.concurrent.ConcurrentHashMap
import javax.ws.rs.*
import javax.ws.rs.core.MediaType
import javax.ws.rs.core.Response

@Path("/MakeOrderInternetDownload")
class MakeOrderInternetDownload {    // класс для сохранения отчета только на ПК клиента

    @GET
    @Produces(MediaType.APPLICATION_JSON) // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON) // тип данных получаемых от клиента в теле запроса
    fun hello(): String {
        return "Hello " + System.getProperty("user.name") + "!"
    }

    // добавить Order
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderInternetDownload/John?pay=500
    @GET
    @Path("/{user}") // @Path("/{user}/{pay}")       /Marcus?pay=500
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun addNewOrder(@PathParam("user") loginName: String, @QueryParam("pay") pay: Int): Response {
        Class.forName("org.postgresql.Driver")
        val ordersMap: MutableMap<Int, OrderTable> = ConcurrentHashMap()
        var jasperPrint: JasperPrint? = null
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(
                    "INSERT INTO rtk.public.orders(date, fk_customer_name, fk_service, pay) VALUES (?,?,'internet',?)").use { preparedStatement ->
                val timestamp = Timestamp.valueOf(LocalDateTime.now()) // для вставки даты
                preparedStatement.setTimestamp(1, timestamp)
                preparedStatement.setString(2, loginName)
                preparedStatement.setInt(3, pay)
                preparedStatement.executeUpdate() // выполнить запрос
                println("You paid $pay RUB")
                connection.prepareStatement("SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?) AND date = (?)").use { statement ->
                    statement.setString(1, loginName) // Name - это (?) из запроса
                    statement.setTimestamp(2, timestamp)
                    statement.executeQuery().use { resultSet ->
                        if (resultSet.next()) {
                            val order = OrderTable()
                            order.orderNumber = resultSet.getInt(1)
                            order.timestamp = resultSet.getTimestamp(2)
                            order.customer = resultSet.getString(3)
                            order.service = resultSet.getString(4)
                            order.pay = resultSet.getInt(5)
                            getExecuteQuery(ordersMap, statement) // наполняем мапу ordersMap данными из БД
                            // наполняем мапу parameters для JasperReports
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
                            // JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("JavaMakeOrderInternet")); // Экспорт данных в PDF файл
                            println("method makeReport is done! New file created: $loginName") // для отчёта
                        }
                    }
                }
            }
        }
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"$loginName.pdf\"").build()
    }

    // наполнение объектов order данными из БД и заполнение Мапы ordersMap для передачи на web
    @Throws(SQLException::class)
    private fun getExecuteQuery(ordersMap: MutableMap<Int, OrderTable>, statement: PreparedStatement) {
        statement.executeQuery().use { resultSet ->
            while (resultSet.next()) {
                val order = OrderTable()
                order.orderNumber = resultSet.getInt(1)
                order.timestamp = resultSet.getTimestamp(2)
                order.customer = resultSet.getString(3)
                order.service = resultSet.getString(4)
                order.pay = resultSet.getInt(5)
                ordersMap[order.orderNumber] = order
                println(order)
            }
        }
    }
}
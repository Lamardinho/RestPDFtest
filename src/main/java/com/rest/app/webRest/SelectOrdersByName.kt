package com.rest.app.webRest

import com.rest.app.dataBase.tables.OrderTable
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.SQLException
import java.util.concurrent.ConcurrentHashMap
import javax.ws.rs.*
import javax.ws.rs.core.MediaType

@Path("/SelectOrdersByName")
class SelectOrdersByName {
    //  *   *   *   выводит сразу все заказы при переходе на эту на страницу  *   *   *
    // http://localhost:8080/RestPDFtest_war_exploded/rest/SelectOrdersByName
    @GET
    @Produces(MediaType.APPLICATION_JSON)
  //  @Consumes(MediaType.APPLICATION_JSON)
    @Throws(ClassNotFoundException::class, SQLException::class)
    fun selectAllOrders(): Collection<OrderTable> {
        Class.forName("org.postgresql.Driver")
        val ordersMap: MutableMap<Int, OrderTable> = ConcurrentHashMap()
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareStatement("SELECT * FROM rtk.public.select_orders()").use { statement ->

                getResultSetExecuteQuery(ordersMap, statement)
            }
        }
        return ordersMap.values
    }

    //  *   *   *   выводит все заказы по имени клиента  *   *   *     /Marcus or /Alice or / Alexandra и т.д...
    // http://localhost:8080/RestPDFtest_war_exploded/rest/SelectOrdersByName/Marcus
    @GET
    @Path("/{user}")
    @Throws(SQLException::class, ClassNotFoundException::class)
    fun selectOrdersByName(@PathParam("user") userName: String): Collection<OrderTable> {
        Class.forName("org.postgresql.Driver")
        val ordersMap: MutableMap<Int, OrderTable> = ConcurrentHashMap()
        DriverManager.getConnection("jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareStatement("SELECT * FROM rtk.public.select_orders(?)").use { statement ->
                statement.setString(1, userName)     // Name - это (?) из запроса

                getResultSetExecuteQuery(ordersMap, statement)
            }
        }
        return ordersMap.values
    }

    // метод для наполнения объекта order данными из базы данных и заполнения Мапы ordersMap для передачи на web
    @Throws(SQLException::class)
    private fun getResultSetExecuteQuery(ORDERS: MutableMap<Int, OrderTable>, statement: PreparedStatement) {
        statement.executeQuery().use { resultSet ->
            while (resultSet.next()) {
                val order = OrderTable()
                order.orderNumber = resultSet.getInt(1)
                order.timestamp = resultSet.getTimestamp(2)
                order.customer = resultSet.getString(3)
                order.service = resultSet.getString(4)
                order.pay = resultSet.getInt(5)
                ORDERS[order.orderNumber] = order
                println(order)
            }
        }
    }
}

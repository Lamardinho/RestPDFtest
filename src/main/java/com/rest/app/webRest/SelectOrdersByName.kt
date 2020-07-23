package com.rest.app.webRest

import com.rest.app.dataBase.tables.OrderTable
import java.sql.DriverManager
import java.sql.SQLException
import java.util.concurrent.ConcurrentHashMap
import javax.ws.rs.*
import javax.ws.rs.core.MediaType

@Path("/ReturnMyOrders")
class SelectOrdersByName {

    @GET         // приветствие
    fun hello(): String {
        return "Hello " + System.getProperty("user.name") + "!"
    }

    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    @Throws(SQLException::class, ClassNotFoundException::class)
    fun myOrders(@PathParam("user") userName: String): Collection<OrderTable> {
        Class.forName("org.postgresql.Driver")
        val ordersMap: MutableMap<Int, OrderTable> = ConcurrentHashMap()
        DriverManager.getConnection("jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareStatement("SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)").use { statement ->
                statement.setString(1, userName) // Name - это (?) из запроса
                statement.executeQuery().use { resultSet ->
                    while (resultSet.next()) {
                        val order = OrderTable()
                        order.orderNumber = resultSet.getInt(1)
                        order.date = resultSet.getDate(2)
                        order.customer = resultSet.getString(3)
                        order.service = resultSet.getString(4)
                        order.pay = resultSet.getInt(5)
                        ordersMap[order.orderNumber] = order
                        println(order)
                    }
                }
            }
        }
        return ordersMap.values
    }
}

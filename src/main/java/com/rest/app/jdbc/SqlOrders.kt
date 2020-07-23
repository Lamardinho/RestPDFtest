package com.rest.app.jdbc

import com.rest.app.dataBase.tables.OrderTable
import java.sql.DriverManager
import java.sql.SQLException

class SqlOrders {
    // вывод всех заказов по ИМЕНИ клиента
    @Throws(SQLException::class, ClassNotFoundException::class)
    fun selectByName(Name: String) {
        Class.forName("org.postgresql.Driver")
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(
                    "SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)").use { statement ->
                statement.setString(1, Name) // Name - это (?) из запроса
                statement.executeQuery().use { resultSet ->
                    while (resultSet.next()) {
                        val order = OrderTable()
                        order.orderNumber = resultSet.getInt(1)
                        order.date = resultSet.getDate(2)
                        order.customer = resultSet.getString(3)
                        order.service = resultSet.getString(4)
                        order.pay = resultSet.getInt(5)
                        println(order)
                    }
                }
            }
        }
    }
}

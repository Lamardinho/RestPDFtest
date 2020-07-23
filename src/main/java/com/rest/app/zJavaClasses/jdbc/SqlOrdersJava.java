package com.rest.app.zJavaClasses.jdbc;

import com.rest.app.dataBase.tables.OrderTable;

import java.sql.*;

public class SqlOrdersJava {
    // вывод всех заказов по ИМЕНИ клиента
    public void selectByName(String Name) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)")) {
            statement.setString(1, Name);   // Name - это (?) из запроса
            try (final ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    OrderTable order = new OrderTable();
                    order.setOrderNumber(resultSet.getInt(1));
                    order.setDate(resultSet.getDate(2));
                    order.setCustomer(resultSet.getString(3));
                    order.setService(resultSet.getString(4));
                    order.setPay(resultSet.getInt(5));
                    System.out.println(order);
                }
            }
        }
    }

    public static void main(String[] args) throws SQLException, ClassNotFoundException {
        SqlOrdersJava orders = new SqlOrdersJava();
        orders.selectByName("Marcus");
    }
}

package com.rest.app.webRest;

import com.rest.app.dataBase.tables.OrderTable;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.*;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Path("/ReturnMyOrders")
public class JavaTestJdbcReturnOrders {
    private final static Map<Integer, OrderTable> ORDERS = new ConcurrentHashMap<>();

    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "!";
    }

    /*@GET    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON)    @Consumes(MediaType.APPLICATION_JSON)
    public SqlOrdersJava myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
    SqlOrdersJava orders = new SqlOrdersJava();    orders.selectByName(userName);    return orders;    }*/

    /*
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    @Consumes(MediaType.APPLICATION_JSON)
    public OrderTable myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    OrderTable order = new OrderTable();
        try (Connection connection = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
    PreparedStatement statement = connection.prepareStatement(
            "SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)")) {
        statement.setString(1, userName);   // Name - это (?) из запроса
        try (final ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                order.setOrderNumber(resultSet.getInt(1));
                order.setDate(resultSet.getDate(2));
                order.setCustomer(resultSet.getString(3));
                order.setService(resultSet.getString(4));
                order.setPay(resultSet.getInt(5));
                System.out.println(order);            }        }    }        return order;}     */

    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    @Consumes(MediaType.APPLICATION_JSON)
    public Collection<OrderTable> myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
        /*SqlOrdersJava orders = new SqlOrdersJava();
        orders.selectByName(userName);*/
        Class.forName("org.postgresql.Driver");
        OrderTable order = new OrderTable();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)")) {
            statement.setString(1, userName);   // Name - это (?) из запроса
            try (final ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    order.setOrderNumber(resultSet.getInt(1));
                    order.setDate(resultSet.getDate(2));
                    order.setCustomer(resultSet.getString(3));
                    order.setService(resultSet.getString(4));
                    order.setPay(resultSet.getInt(5));

                    ORDERS.put(order.getOrderNumber(), order);
                    System.out.println(order);
                }
            }
        }
        return ORDERS.values();
    }
}

package com.rest.app.webRest.java;

import com.rest.app.dataBase.tables.OrderTable;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.*;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Path("/JavaSelectOrdersByName")
public class SelectOrdersByName_Java {
    //  *   *   *   выводит сразу все заказы при переходе на эту на страницу  *   *   *
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaSelectOrdersByName
    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    public Collection<OrderTable> mainHome() throws ClassNotFoundException, SQLException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.select_orders()")) {

            getExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    //  *   *   *   выводит все заказы по имени клиента  *   *   *     /Marcus or /Alice or / Alexandra и т.д...
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaSelectOrdersByName/Marcus
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Collection<OrderTable> myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.select_orders(?)")) {
            statement.setString(1, userName);   // Name - это (?) из запроса

            getExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    // наполнение объектов order данными из БД и заполнение Мапы ordersMap для передачи на web
    private void getExecuteQuery(Map<Integer, OrderTable> ordersMap, PreparedStatement statement) throws SQLException {
        try (final ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                OrderTable order = new OrderTable();
                order.setOrderNumber(resultSet.getInt(1));
                order.setTimestamp(resultSet.getTimestamp(2));
                order.setCustomer(resultSet.getString(3));
                order.setService(resultSet.getString(4));
                order.setPay(resultSet.getInt(5));

                ordersMap.put(order.getOrderNumber(), order);
                System.out.println(order);
            }
        }
    }
}

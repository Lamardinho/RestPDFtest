package com.rest.app.webRest;

import com.rest.app.dataBase.tables.OrderTable;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.*;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Path("/ReturnMyOrdersJava")
public class JavaSelectOrdersByName {
    //  *   *   *   выводит сразу все заказы при переходе на эту на страницу  *   *   *
    // http://localhost:8080/RestPDFtest_war_exploded/rest/ReturnMyOrdersJava
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Collection<OrderTable> mainHome() throws ClassNotFoundException, SQLException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.orders")) {

            getResultSetExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    //  *   *   *   выводит все заказы по имени клиента  *   *   *     /Marcus or /Alice or / Alexandra и т.д...
    // http://localhost:8080/RestPDFtest_war_exploded/rest/ReturnMyOrdersJava/Marcus
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    @Consumes(MediaType.APPLICATION_JSON)
    public Collection<OrderTable> myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)")) {
            statement.setString(1, userName);   // Name - это (?) из запроса

            getResultSetExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    // метод для наполнения объекта order данными из базы данных и заполнения Мапы ordersMap для передачи на web
    private void getResultSetExecuteQuery(Map<Integer, OrderTable> ordersMap, PreparedStatement statement) throws SQLException {
        try (final ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                OrderTable order = new OrderTable();
                order.setOrderNumber(resultSet.getInt(1));
                order.setDate(resultSet.getDate(2));
                order.setCustomer(resultSet.getString(3));
                order.setService(resultSet.getString(4));
                order.setPay(resultSet.getInt(5));

                ordersMap.put(order.getOrderNumber(), order);
                System.out.println(order);
            }
        }
    }
}

/*
public Collection<OrderTable> myOrders(...) {
        return ORDERS.values();     }

или

public String myOrders(...) {
        return ORDERS.toString();   }
 */

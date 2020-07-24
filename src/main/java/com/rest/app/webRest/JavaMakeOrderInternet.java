package com.rest.app.webRest;

import com.rest.app.dataBase.tables.OrderTable;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.*;

@Path("/JavaMakeOrderInternet")
public class JavaMakeOrderInternet {

    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON)   // тип данных получаемых от клиента в теле запроса
    public String hello() {
        return "Hello " + System.getProperty("user.name") + "!";
    }

    // добавить Order
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderInternet/Marcus?pay=500
    @GET
    @Path("/{user}")      // @Path("/{user}/{pay}")       /Marcus?pay=500
    public String addNewOrder(@PathParam("user") String name, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement(
                     "INSERT INTO rtk.public.orders(date, fk_customer_name, fk_service, pay) VALUES (current_timestamp,?,'internet',?)")) {
            preparedStatement.setString(1, name);
            preparedStatement.setInt(2, pay);
            preparedStatement.executeUpdate();  // выполнить запрос
            System.out.println("Done!");

            /*try (final ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    OrderTable order = new OrderTable();
                    order.setOrderNumber(resultSet.getInt(1));
                    order.setTimestamp(resultSet.getTimestamp(2));
                    order.setCustomer(resultSet.getString(3));
                    order.setService(resultSet.getString(4));
                    order.setPay(resultSet.getInt(5));

                    System.out.println(order);
                }
            }*/

            System.out.println("order '" + " " + "Date" + "' was created");
        }
        return "done";
    }

    /*public static void main(String[] args) {
        JavaMakeOrderInternet makeOrder = new JavaMakeOrderInternet();
        try {
            makeOrder.addNewOrder("Bob", 500);
        } catch (Exception exception) {
            System.out.println("Warning! : " + exception);
        }
    }*/
}

package com.rest.app.webRest;

import com.rest.app.zJavaClasses.jdbc.SqlOrdersJava;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.SQLException;

@Path("/ReturnMyOrders")
public class JavaTestJdbcReturnOrders {
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "!";
    }

    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    @Consumes(MediaType.APPLICATION_JSON)
    public SqlOrdersJava myOrders(@PathParam("user") String userName) throws SQLException, ClassNotFoundException {
        SqlOrdersJava orders = new SqlOrdersJava();
        orders.selectByName(userName);
        return orders;
    }
}

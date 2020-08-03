package com.rest.app.webRest.java;

import com.rest.app.domain.PayMakeOrder;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.sql.SQLException;

@Path("/JavaMakeOrderServer")
public class MakeOrderServer_Java {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderServer/
    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    public String hello() {
        return "JavaPayServer: Hello " + System.getProperty("user.name") + "!";
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderServer/Marcus?service=TV&pay=300
    @GET
    @Path("/{user}")
    public String javaMakeOrderServer(@PathParam("user") String loginName, @QueryParam("service") String service, @QueryParam("pay") int pay) throws Exception {
        System.out.println("Using make on SERVER");
        final PayMakeOrder payMakeOrder = new PayMakeOrder();
        payMakeOrder.makeOrderOnServer(loginName, service, pay);
        return "Hello " + loginName + " you paid for " + service + ": " + pay + " RUB";
    }
}

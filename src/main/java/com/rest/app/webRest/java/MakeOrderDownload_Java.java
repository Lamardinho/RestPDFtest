package com.rest.app.webRest.java;

import com.rest.app.domain.PayMakeOrder;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;

@Path("/JavaMakeOrderDownload")
public class MakeOrderDownload_Java {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaPayDownload/
    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    public String hello() {
        return "JavaPayDownload: Hello " + System.getProperty("user.name") + "!";
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaPayDownload/Alice?service=TV&pay=300
    @GET
    @Path("/{user}")
    public Response javaMakeOrderDownload(@PathParam("user") String loginName, @QueryParam("service") String service, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException, JRException {
        System.out.println("Using make DOWNLOAD");
        return Response.ok().entity(new PayMakeOrder().makeOrderDownload(loginName, service, pay)).header(
                "Content-disposition", "attachment; filename=\"" +
                        loginName + "_" + new PayMakeOrder().myDate() + ".pdf\"").build();
    }
}

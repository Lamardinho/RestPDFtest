package com.rest.app.webRest.old;

import com.rest.app.webRest.basis.BasePayMakeOrder;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;

@Path("/JavaMakeOrderDownload")
public class JavaMakeOrderDownload {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaPayDownload/
    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON)   // тип данных получаемых от клиента в теле запроса
    public String hello() {
        return "JavaPayDownload: Hello " + System.getProperty("user.name") + "!";
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaPayDownload/Alice?service=TV&pay=300
    @GET
    @Path("/{user}")
    public Response javaMakeOrderDownload(@PathParam("user") String loginName, @QueryParam("service") String service, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException, JRException {
        System.out.println("Using make DOWNLOAD");
        final BasePayMakeOrder basePayMakeOrder = new BasePayMakeOrder();
        byte[] bytes = basePayMakeOrder.makeOrderDownload(loginName, service, pay);
        return Response.ok().entity(bytes).header("Content-disposition", "attachment; filename=\"" + loginName + "_" + basePayMakeOrder.myDate() + ".pdf\"").build();
    }
}

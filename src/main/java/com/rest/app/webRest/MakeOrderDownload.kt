package com.rest.app.webRest

import com.rest.app.webRest.domain.BasePayMakeOrder
import net.sf.jasperreports.engine.JRException
import java.sql.SQLException
import javax.ws.rs.*
import javax.ws.rs.core.MediaType
import javax.ws.rs.core.Response

@Path("/MakeOrderDownload")
class MakeOrderDownload {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/MakeOrderDownload/
    @GET
    @Produces(MediaType.APPLICATION_JSON) // тип данных отправляемых клиенту (не является обязательной?)
  //  @Consumes(MediaType.APPLICATION_JSON) // тип данных получаемых от клиента в теле запроса
    fun hello(): String {
        return "MakeOrderDownload: Hello " + System.getProperty("user.name") + "!"
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/MakeOrderDownload/Alice?service=TV&pay=300
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON)
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun makeOrderDownload(@PathParam("user") loginName: String, @QueryParam("service") service: String, @QueryParam("pay") pay: Int): Response {
        println("Using make DOWNLOAD")
        val basePayMakeOrder = BasePayMakeOrder()
        val bytes = basePayMakeOrder.makeOrderDownload(loginName, service, pay)
        return Response.ok().entity(bytes).header("Content-disposition", "attachment; filename=\"" + loginName + "_" + basePayMakeOrder.myDate() + ".pdf\"").build()
    }
}

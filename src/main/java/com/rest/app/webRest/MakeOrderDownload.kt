package com.rest.app.webRest

import com.rest.app.dataBase.MyDate.getNowDate
import com.rest.app.domain.PayMakeOrder
import net.sf.jasperreports.engine.JRException
import java.sql.SQLException
import javax.ws.rs.*
import javax.ws.rs.core.MediaType
import javax.ws.rs.core.Response

@Path("/MakeOrderDownload")
class MakeOrderDownload {

    // http://localhost:8080/home/rest/MakeOrderDownload/
    @GET
    @Produces(MediaType.APPLICATION_JSON) // тип данных отправляемых клиенту (не является обязательной?)
    fun hello(): String {
        return "MakeOrderDownload: Hello " + System.getProperty("user.name") + "!"
    }

    // http://localhost:8080/home/rest/MakeOrderDownload/Alice?service=TV&pay=300
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON)
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun makeOrderDownload(
            @PathParam("user") loginName: String,
            @QueryParam("service") service: String,
            @QueryParam("pay") pay: Int): Response {
        println("Using make DOWNLOAD")
        return Response.ok().entity(PayMakeOrder().makeOrderDownload(loginName, service, pay)).header(
                "Content-disposition", "attachment; filename=\"" + loginName + "_" + getNowDate() + ".pdf\"").build()
    }
}

/* val bytesArray = PayMakeOrder().makeOrderDownload(loginName, service, pay)
   return Response.ok().entity(bytesArray).header("Content-disposition", "attachment; filename=\"" +
   loginName + "_" + basePayMakeOrder.myDate() + ".pdf\"").build() */

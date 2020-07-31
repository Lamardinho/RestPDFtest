package com.rest.app.webRest

import com.rest.app.domain.PayMakeOrder
import net.sf.jasperreports.engine.JRException
import java.sql.SQLException
import javax.ws.rs.*
import javax.ws.rs.core.MediaType

@Path("/MakeOrderOnServer")
class MakeOrderOnServer {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/MakeOrderOnServer/
    @GET
    @Produces(MediaType.APPLICATION_JSON) // тип данных отправляемых клиенту (не является обязательной?)
    fun hello2(): String {
        return "MakeOrderOnServer: Hello " + System.getProperty("user.name") + "!"
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/MakeOrderOnServer/Marcus?service=TV&pay=300
    @GET
    @Path("/{user}")
    @Produces(MediaType.APPLICATION_JSON)
    @Throws(SQLException::class, ClassNotFoundException::class, JRException::class)
    fun makeOrderOnServer(@PathParam("user") loginName: String, @QueryParam("service") service: String, @QueryParam("pay") pay: Int): String {
        println("Using make on SERVER")
        PayMakeOrder().makeOrderOnServer(loginName, service, pay)
        return "Hello $loginName you paid for $service: $pay RUB"
    }
}

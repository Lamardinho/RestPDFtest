package com.rest.app.leftClasses;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

@Path("/hello")
public class RestTest {
    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/test
    */
    @GET
    public String checkPerson() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user;
    }
    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/hello/23?name=Marcus
    */
    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public String checkPerson(@PathParam("id") int id,
                              @QueryParam("name") String name) {
        return "your id: " + id + ",your  name " + name;
    }
}

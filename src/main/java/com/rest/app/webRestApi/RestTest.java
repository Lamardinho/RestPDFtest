package com.rest.app.webRestApi;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

@Path("/test")
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
    http://localhost:8080/RestPDFtest_war_exploded/rest/test/23?name=Marcus
    */
    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public String checkPerson(@PathParam("id") int simpleId,
                              @QueryParam("name") String simpleName) {
        return "your id: " + simpleId + ",your  name " + simpleName;
    }
}

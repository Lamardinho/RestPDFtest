package com.rest.app.zJavaClasses.LeftClasses.restLesson;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Arrays;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

//инфа с: https://youtu.be/P8JgvRZMjLY

/* для использования:
http://localhost:8080/home/rest/user
http://localhost:8080/home/rest/user/1

показать массив наших юзеров:
curl -H "Content-Type: application/json" -X GET http://localhost:8080/home/rest/user/
создать юзера:
curl -H "Content-Type: application/json" -X POST -d '{"address":{"name":"New York"},"name":"Lamar Jabbar","id":1,"roles":[{"name":"ADMIN"},{"name":"USER"}]}' http://localhost:8080/home/rest/user/
curl -H "Content-Type: application/json" -X POST -d '{"address":{"name":"Chicago"},"name":"Michael Jordan","id":2,"roles":[{"name":"ADMIN"},{"name":"USER"}]}' http://localhost:8080/home/rest/user/
curl -H "Content-Type: application/json" -X POST -d '{"address":{"name":"LA"},"id":3,"name":"Marcus Prince","roles":[{"name":"Admin"},{"name":"User"}]}' http://localhost:8080/home/rest/user/
создать нескольких юзеров: [{},{},{}] = 3 юзера
curl -H "Content-Type: application/json" -X POST -d '[{},{},{}]' http://localhost:8080/home/rest/user/multi
(не работает) вместо замены данных определенного ID, он создает новый:
curl -H "Content-Type: application/json" -X POST -d '{"id":1,"address":{"name":"1"},"name":"1 1","roles":[{"name":"Admin"},{"name":"User"}]}' http://localhost:8080/home/rest/user/
удаляет определенного юзера:
curl -H "Content-Type: application/json" -X DELETE http://localhost:8080/home/rest/user/4
 */

@Path("/user")
public class UserRestController {
    private final static AtomicInteger ID = new AtomicInteger(0);
    private final static Map<Integer, User> USERS = new ConcurrentHashMap<>();

    static { // выполняется во время загрузки класса
        User user = new User(
                ID.incrementAndGet(),
                "Default User",
                new Address("Street"),
                Arrays.asList(new Role("freedom"), new Role("User"))
        );
        USERS.put(user.getId(), user);
    }

    /*static { // выполняется во время загрузки класса, выполнятся блоки будут последовательно
        System.out.println("123");    }*/

    @GET
    // метод GET должен быть уникальный, все остальные GET должны быть "перезагрузкой": 1) @Path("/{id}") 2) @Path("/") и тд
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public User getUser(@PathParam("id") int id) {
        return USERS.getOrDefault(id, new User() {
            public String getError() {   // возвращает сообщение, если объект не существует
                return String.format("User not found. [id=%s]", id);
            }
        });
    }

    // отдает все объекты
    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Collection<User> get() {
        return USERS.values();
    }

    @POST   // @POST - используется для создания объекта
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public User create(User user) {
        user.setId(ID.incrementAndGet());
        USERS.put(user.getId(), user);
        return user;
    }

    // метод для множественного создания объектов
    @POST    // перегруженный метод @POST
    @Path("/multi")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public User[] create(User[] users) {
        for (User user : users) {
            this.create(user);
        }
        return users;
    }

    @PUT    // для обновления - update
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public User update(User user) {
        USERS.put(user.getId(), user);
        return user;
    }

    @DELETE     // в методах @DELETE используем только: public Response, другие типы данных не приемлимы
    @Path("/{id}")
    public Response delete(@PathParam("id") int id) {
        USERS.remove(id);
        return Response.status(200).build();
    }
}

/*public UserRestController() {System.out.println("newTest UserRestController");}

    static { // выполняется во время загрузки класса
        User user = new User(
                ID.incrementAndGet(),
                "Marcus Prince",
                new Address("LA"),
                Arrays.asList(new Role("Admin"), new Role("User"))
        );
         USERS.put(user.getId(), user);
    }

    static { // выполняется во время загрузки класса, выполнятся блоки будут последовательно
        System.out.println("123");    } */
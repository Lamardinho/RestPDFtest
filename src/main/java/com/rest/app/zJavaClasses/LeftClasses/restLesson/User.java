package com.rest.app.zJavaClasses.LeftClasses.restLesson;

import java.util.List;

public class User {
    private int id;
    private String name;
    private Address address;
    private List<Role> roles;

    public User() {
    }

    public User(int id, String name, Address address, List<Role> roles) {
        this.id = id;
        this.name = name;
        this.address = address;
        this.roles = roles;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Address getAddress() {
        return address;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    public List<Role> getRoles() {
        return roles;
    }

    public void setRoles(List<Role> roles) {
        this.roles = roles;
    }
}

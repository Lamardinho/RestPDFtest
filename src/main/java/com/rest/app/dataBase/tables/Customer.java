package com.rest.app.dataBase.tables;

public class Customer {
    private int id;
    private String login;

    public Customer() {
    }

    public Customer(int id, String login) {
        this.id = id;
        this.login = login;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    @Override
    public String toString() {
        return "Customer{" + "customerID=" + id + ", customerLOGIN='" + login + '\'' + '}';
    }
}

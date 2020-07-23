package com.rest.app.dataBase.tables;

public class ServiceTable {
    private int id;
    private String service;

    public ServiceTable() {
    }

    public ServiceTable(int id, String service) {
        this.id = id;
        this.service = service;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getService() {
        return service;
    }

    public void setService(String service) {
        this.service = service;
    }

    @Override
    public String toString() {
        return "Service{" + "id=" + id + ", service='" + service + '\'' + '}';
    }
}

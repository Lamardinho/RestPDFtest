package com.rest.app.dataBase.tables;

import java.sql.Timestamp;

public class OrderTable {
    private int orderNumber;
    private Timestamp timestamp;
    private String customer;
    private String service;
    private int pay;

    public OrderTable() {
    }

    public OrderTable(int orderNumber, Timestamp timestamp, String customer, String service, int pay) {
        this.orderNumber = orderNumber;
        this.timestamp = timestamp;
        this.customer = customer;
        this.service = service;
        this.pay = pay;
    }

    public int getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(int orderNumber) {
        this.orderNumber = orderNumber;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    public String getCustomer() {
        return customer;
    }

    public void setCustomer(String customer) {
        this.customer = customer;
    }

    public String getService() {
        return service;
    }

    public void setService(String service) {
        this.service = service;
    }

    public int getPay() {
        return pay;
    }

    public void setPay(int pay) {
        this.pay = pay;
    }

    @Override
    public String toString() {
        return "OrderTable{" +
                "orderNumber=" + orderNumber +
                ", timestamp=" + timestamp +
                ", customer='" + customer + '\'' +
                ", service='" + service + '\'' +
                ", pay=" + pay +
                '}';
    }
}

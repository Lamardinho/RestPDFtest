package com.rest.app.dataBase.tables;

import java.sql.Date;

public class Order {
    private int orderNumber;
    private Date date;
    private String customer;
    private String service;
    private int pay;

    public Order() {
    }

    public Order(int orderNumber, Date date, String customer, String service, int pay) {
        this.orderNumber = orderNumber;
        this.date = date;
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

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
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
        return "Order{" + "orderNumber=" + orderNumber + ", date=" + date + ", customer='" + customer + '\'' + ", service='" + service + '\'' + ", pay=" + pay + '}';
    }
}

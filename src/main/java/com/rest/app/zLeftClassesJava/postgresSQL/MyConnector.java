package com.rest.app.zLeftClassesJava.postgresSQL;

import java.sql.*;

public class MyConnector {

    private void getConnection() throws SQLException {
        try (Connection ignored = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff",
                "postgres",
                "post@post23")) {
            System.out.println("Connection successful");
        }
    }

    public static void main(String[] args) throws SQLException {
        MyConnector myConnector = new MyConnector();
        myConnector.getConnection();
    }
}


/*Соответствие методов командам SQL:
executeUpdate(String sql)   // CREATE, DROP, INSERT, UPDATE, DELETE
executeQuery(String sql)    //SELECT
execute(String sql)         // универсальный метод */
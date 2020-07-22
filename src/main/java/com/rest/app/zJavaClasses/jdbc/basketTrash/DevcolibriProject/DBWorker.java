package com.rest.app.zJavaClasses.jdbc.basketTrash.DevcolibriProject;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBWorker {
    private Connection connection;

    public DBWorker() {
        try {
            connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return connection;
    }

    /*public void getConnection2() throws SQLException {
        try (Connection ignored = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23")) {
            System.out.println("Connection successful");
        }
    }*/
}


/*
 if (!connection.isClosed()) System.out.println("connection established");
            //connection.close();
            if (connection.isClosed()) System.out.println("connection stopped");
 */
package com.rest.app.zLeftClassesJava.postgresSqlLeftTests;

import java.sql.*;

public class MyApplication {

    public void getCon() throws SQLException {
        String url = "jdbc:postgresql://localhost:5432/phones_magazine";
        String userName = "postgres";
        String password = "post@post23";
        try (Connection connection = DriverManager.getConnection(url, userName, password); PreparedStatement statement = connection.prepareStatement(
                "SELECT * FROM phones_magazine.public.users WHERE id = (?)")) {
            statement.setInt(1, 2);
            final ResultSet resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String byName = "login: " + resultSet.getString("login");
                String byIndex = "password: " + resultSet.getString(3);
                final int role = resultSet.getInt("role");
                System.out.println(byName);
                System.out.println(byIndex);
                System.out.println("role: " + role);
            }
        }
    }

    public static void main(String[] args) throws SQLException {
        MyApplication myApplication = new MyApplication();
        myApplication.getCon();
    }
}

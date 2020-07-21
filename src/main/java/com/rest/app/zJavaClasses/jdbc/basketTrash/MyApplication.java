package com.rest.app.zJavaClasses.jdbc.basketTrash;

import java.sql.*;

public class MyApplication {

    public void getCon(int id) throws SQLException {
        String url = "jdbc:postgresql://localhost:5432/phones_magazine";
        String userName = "postgres";
        String password = "post@post23";
        try (Connection connection = DriverManager.getConnection(url, userName, password); PreparedStatement statement = connection.prepareStatement(
                "SELECT * FROM phones_magazine.public.users WHERE id = (?)")) {
            statement.setInt(1, id);
            final ResultSet resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String byName = resultSet.getString("login");
                String byIndex = resultSet.getString(3);
                final int role = resultSet.getInt("role");
                System.out.println("login: " + byName);
                System.out.println("password: " + byIndex);
                System.out.println("role: " + role);
                System.out.println();
            }
        }
    }

    public static void main(String[] args) throws SQLException {
        MyApplication myApplication = new MyApplication();
        myApplication.getCon(1);
        myApplication.getCon(2);
    }
}

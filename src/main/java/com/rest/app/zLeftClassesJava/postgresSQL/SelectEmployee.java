package com.rest.app.zLeftClassesJava.postgresSQL;

import java.sql.*;

public class SelectEmployee {

    public void getEmployeeSQL(int employee_ID) throws SQLException {
        String url = "jdbc:postgresql://localhost:5432/rest_staff";
        String userName = "postgres";
        String password = "post@post23";
        try (Connection connection = DriverManager.getConnection(url, userName, password);
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)")) {

            statement.setInt(1, employee_ID);   // employee_ID - это (?) из запроса
            final ResultSet resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String employee_name = resultSet.getString(2);
                String employee_position = resultSet.getString(3);
                long employee_phone = resultSet.getLong(4);
                java.sql.Date employee_data_birthday = resultSet.getDate(5);

                System.out.println("Name: " + employee_name);
                System.out.println("Position: " + employee_position);
                System.out.println("Phone: " + employee_phone);
                System.out.println("Birthday: " + employee_data_birthday);
            }
        }
    }
    /*public void getEmployeeALL(int employee_ID) throws SQLException {
        String url = "jdbc:postgresql://localhost:5432/rest_staff";
        String userName = "postgres";
        String password = "post@post23";
        try (Connection connection = DriverManager.getConnection(url, userName, password); PreparedStatement statement = connection.prepareStatement(
                "SELECT * FROM rest_staff.public.staff")) {
            statement.setInt(1, employee_ID);
            final ResultSet resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String employee_name = resultSet.getString(2);
                String employee_position = resultSet.getString(3);
                long employee_phone = resultSet.getLong(4);
                java.sql.Date employee_data_birthday = resultSet.getDate(5);

                System.out.println("Name: " + employee_name);
                System.out.println("Position: " + employee_position);
                System.out.println("Phone: " + employee_phone);
                System.out.println("Birthday:" + employee_data_birthday);
            }
        }
    }*/

    public static void main(String[] args) throws SQLException {
        SelectEmployee myApp2 = new SelectEmployee();
        myApp2.getEmployeeSQL(1);
    }
}

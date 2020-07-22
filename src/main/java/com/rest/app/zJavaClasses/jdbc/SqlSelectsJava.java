package com.rest.app.zJavaClasses.jdbc;

import java.sql.*;

public class SqlSelectsJava {

    public void addNewEmployee(String name, String position, long phone, java.sql.Date date) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(
                     "INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)")) {
            statement.setString(1, name);
            statement.setString(2, position);
            statement.setLong(3, phone);
            statement.setDate(4, date);
            statement.executeUpdate();  // применение команд?
            System.out.println("employee '" + name + "' was created");
        }
    }

    public void deleteEmployee(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(
                     "DELETE FROM rest_staff.public.staff WHERE employee_id = (?)")) {
            statement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            statement.executeUpdate();  // применение команд?
            System.out.println("employee id: '" + employeeId + "' has been removed");
        }
    }

    public void selectEmployee(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)")) {
            statement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            try (final ResultSet resultSet = statement.executeQuery()) { // применение команд?
                if (resultSet.next()) {
                    String employeeName = resultSet.getString(2);
                    String employeePosition = resultSet.getString(3);
                    long employeePhone = resultSet.getLong(4);
                    java.sql.Date employeeDataBirthday = resultSet.getDate(5);
                    System.out.println("Name: " + "{" + employeeName + "}" + " Position: " + "{" + employeePosition + "}" +
                            " Phone: " + "{" + employeePhone + "}" + " Birthday: " + "{" + employeeDataBirthday + "}");
                }
            }
        }
    }
}

/*Соответствие методов командам SQL:
executeUpdate(String sql)   // CREATE, DROP, INSERT, UPDATE, DELETE
executeQuery(String sql)    //SELECT
execute(String sql)         // универсальный метод */
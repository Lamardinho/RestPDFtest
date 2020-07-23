package com.rest.app.zJavaClasses.jdbc;

import java.sql.*;

public class SqlSelectsJava {
    // добавить Employee
    public void addNewEmployee(String name, String position, long phone, java.sql.Date date) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)")) {
            statement.setString(1, name);
            statement.setString(2, position);
            statement.setLong(3, phone);
            statement.setDate(4, date);
            statement.executeUpdate();  // применение команд?
            System.out.println("employee '" + name + "' was created");
        }
    }

    // удалить Employee
    public void deleteEmployeeById(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("DELETE FROM rest_staff.public.staff WHERE employee_id = (?)")) {
            statement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            statement.executeUpdate();  // применение команд?
            System.out.println("employee id: '" + employeeId + "' has been removed");
        }
    }

    // выбрать Employee
    public void selectEmployeeById(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)")) {
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

    // выбрать Employee
    public void selectEmployeeByName(String Name) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rest_staff.public.staff WHERE employee_name = (?)")) {
            statement.setString(1, Name);   // Name - это (?) из запроса
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

    // выбрать всех Employees
    public void selectAllStaff() throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             Statement statement = connection.createStatement()) {
            try (final ResultSet resultSet = statement.executeQuery("SELECT * FROM rest_staff.public.staff")) { // применение команд?
                while (resultSet.next()) {
                    String employeeName = resultSet.getString(2);
                    String employeePosition = resultSet.getString(3);
                    long employeePhone = resultSet.getLong(4);
                    java.sql.Date employeeDataBirthday = resultSet.getDate(5);
                    int id = resultSet.getInt(1);
                    System.out.println("Name: " + "{" + employeeName + "}" + " Position: " + "{" + employeePosition + "}" +
                            " Phone: " + "{" + employeePhone + "}" + " Birthday: " + "{" + employeeDataBirthday + "}" + " id: " + "{" + id + "}");
                }
            }
        }
    }
}

/*Соответствие методов командам SQL:
executeUpdate(String sql)   // CREATE, DROP, INSERT, UPDATE, DELETE
executeQuery(String sql)    //SELECT
execute(String sql)         // универсальный метод */
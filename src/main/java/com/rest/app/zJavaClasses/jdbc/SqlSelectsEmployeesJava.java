package com.rest.app.zJavaClasses.jdbc;

import java.sql.*;

public class SqlSelectsEmployeesJava {
    // добавить Employee
    public void addNewEmployee(String name, String position, long phone, java.sql.Date date) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement("INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)")) {
            preparedStatement.setString(1, name);
            preparedStatement.setString(2, position);
            preparedStatement.setLong(3, phone);
            preparedStatement.setDate(4, date);
            preparedStatement.executeUpdate();  // выполнить запрос
            System.out.println("employee '" + name + "' was created");
        }
    }

    // удалить Employee
    public void deleteEmployeeById(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement("DELETE FROM rest_staff.public.staff WHERE employee_id = (?)")) {
            preparedStatement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            preparedStatement.executeUpdate();  // выполняет запрос
            System.out.println("employee id: '" + employeeId + "' has been removed");
        }
    }

    // выбрать Employee ById
    public void selectEmployeeById(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)")) {
            preparedStatement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            try (final ResultSet resultSet = preparedStatement.executeQuery()) { // для вывода данных
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

    // выбрать Employee ByName
    public void selectEmployeeByName(String Name) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM rest_staff.public.staff WHERE employee_name = (?)")) {
            preparedStatement.setString(1, Name);   // Name - это (?) из запроса
            try (final ResultSet resultSet = preparedStatement.executeQuery()) { // для вывода данных
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
            try (final ResultSet resultSet = statement.executeQuery("SELECT * FROM rest_staff.public.staff")) {
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
package com.rest.app.zJavaClasses.jdbc;

import com.rest.app.dataBase.MySQLs;

import java.sql.*;

public class SqlSelectsJava {

    public void addNewEmployee(String name, String position, long phone, java.sql.Date date) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(MySQLs.INSTANCE.createEmployee())) {
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
             PreparedStatement statement = connection.prepareStatement(MySQLs.INSTANCE.deleteEmployee())) {
            statement.setInt(1, employeeId);   // employeeId - это (?) из запроса
            statement.executeUpdate();  // применение команд?
            System.out.println("employee id: '" + employeeId + "' has been removed");
        }
    }

    public void selectEmployee(int employeeId) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement(MySQLs.INSTANCE.selectEmployee())) {
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
    // лучше через enum или лучше как сейчас? Если через enum, то лучше внутри класса или отдельным enum class? или без разницы и от ситуации?
    /*enum SQLsEnum {
        GET("SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)"),
        INSERT("INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)"),
        DELETE("DELETE FROM rest_staff.public.staff WHERE employee_id = (?)");  // UPDATE("")
        String QUERY;
        SQLsEnum(String QUERY) {this.QUERY = QUERY;}
    }*/
}

/*Соответствие методов командам SQL:
executeUpdate(String sql)   // CREATE, DROP, INSERT, UPDATE, DELETE
executeQuery(String sql)    //SELECT
execute(String sql)         // универсальный метод */
package com.rest.app.zLeftClassesJava.postgresSQL;

import java.sql.*;

public class SelectCreateEmployee {     // класс для SELECT сотрудника

    public void addEmployee(String name, String position, long phone, java.sql.Date date) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23")) {
            PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)");
            statement.setString(1, name);
            statement.setString(2, position);
            statement.setLong(3, phone);
            statement.setDate(4, date);
            statement.executeUpdate();
            System.out.println("employee '" + name + "' was created");
        }
    }

    public static void main(String[] args) throws SQLException {
        SelectCreateEmployee mainTestSQL = new SelectCreateEmployee();
        // mainTestSQL.addEmployee("Lebron James", "Сorporate сoach", 89025486047L, java.sql.Date.valueOf("1984-12-30"));
        // mainTestSQL.addEmployee("Michael Jordan", "Сorporate girls сoach", 89085487041L, java.sql.Date.valueOf("1963-02-17"));
    }
}

/*Соответствие методов командам SQL:
executeUpdate(String sql)   // CREATE, DROP, INSERT, UPDATE, DELETE
executeQuery(String sql)    //SELECT
execute(String sql)         // универсальный метод */

  /*ResultSet rs = statement.executeQuery("SELECT * FROM rest_staff.public.staff");
            while (rs.next()) {
                int id = rs.getInt(1);
                String employee_name = rs.getString(2);
                String employee_position = rs.getString(3);
                long employee_phone = rs.getLong(4);
                java.sql.Date employee_data_birthday = rs.getDate(5);
                System.out.println(id + "\n" + employee_name + "\n" + employee_position + "\n" + employee_phone + "\n" + employee_data_birthday);
            }*/
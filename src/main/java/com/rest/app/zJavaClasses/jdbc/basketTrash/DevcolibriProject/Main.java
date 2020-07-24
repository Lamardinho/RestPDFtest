package com.rest.app.zJavaClasses.jdbc.basketTrash.DevcolibriProject;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Main {
    public static void main(String[] args) throws SQLException {
        DBWorker worker = new DBWorker();
        String query = "SELECT * FROM rest_staff.public.users";

        try (Statement statement = worker.getConnection().createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            while (resultSet.next()) {
                User user = new User();
                user.setId(resultSet.getInt(1));
                user.setUsername(resultSet.getString(2));
                user.setPassword(resultSet.getString(3));
                System.out.println(user);
            }
        }
    }
}

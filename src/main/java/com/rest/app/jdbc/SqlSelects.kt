package com.rest.app.jdbc

import java.sql.Date
import java.sql.DriverManager
import java.sql.SQLException

class SqlSelects {
    @Throws(SQLException::class)
    fun addNewEmployee(name: String, position: String, phone: Long, date: Date) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(
                    "INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)").use { statement ->
                statement.setString(1, name)
                statement.setString(2, position)
                statement.setLong(3, phone)
                statement.setDate(4, date)
                statement.executeUpdate() // применение команд?
                println("employee '$name' was created")
            }
        }
    }

    @Throws(SQLException::class)
    fun deleteEmployee(employeeId: Int) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(
                    "DELETE FROM rest_staff.public.staff WHERE employee_id = (?)").use { statement ->
                statement.setInt(1, employeeId) // employeeId - это (?) из запроса
                statement.executeUpdate() // применение команд?
                println("employee id: '$employeeId' has been removed")
            }
        }
    }

    @Throws(SQLException::class)
    fun selectEmployee(employeeId: Int) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(
                    "SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)").use { statement ->
                statement.setInt(1, employeeId) // employeeId - это (?) из запроса
                statement.executeQuery().use { resultSet ->  // применение команд?
                    if (resultSet.next()) {
                        val employeeName = resultSet.getString(2)
                        val employeePosition = resultSet.getString(3)
                        val employeePhone = resultSet.getLong(4)
                        val employeeDataBirthday = resultSet.getDate(5)
                        println("Name: " + "{" + employeeName + "}" + " Position: " + "{" + employeePosition + "}" +
                                " Phone: " + "{" + employeePhone + "}" + " Birthday: " + "{" + employeeDataBirthday + "}")
                    }
                }
            }
        }
    }
}

package com.rest.app.jdbc

import com.rest.app.dataBase.MySQLs
import com.rest.app.dataBase.MySQLs.createEmployee
import com.rest.app.dataBase.MySQLs.deleteEmployeeById
import com.rest.app.dataBase.MySQLs.selectEmployeeById
import com.rest.app.dataBase.MySQLs.selectEmployeeByName
import java.sql.Date
import java.sql.DriverManager
import java.sql.SQLException

class SqlSelects {
    // добавить Employee
    @Throws(SQLException::class)
    fun addNewEmployee(name: String, position: String, phone: Long, date: Date) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(createEmployee()).use { statement ->
                statement.setString(1, name)
                statement.setString(2, position)
                statement.setLong(3, phone)
                statement.setDate(4, date)
                statement.executeUpdate() // применение команд?
                println("employee '$name' was created")
            }
        }
    }

    // удалить Employee
    @Throws(SQLException::class)
    fun deleteEmployeeById(employeeId: Int) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(deleteEmployeeById()).use { statement ->
                statement.setInt(1, employeeId) // employeeId - это (?) из запроса
                statement.executeUpdate() // применение команд?
                println("employee id: '$employeeId' has been removed")
            }
        }
    }

    // выбрать Employee
    @Throws(SQLException::class)
    fun selectEmployeeById(employeeId: Int) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(selectEmployeeById()).use { statement ->
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

    // выбрать Employee
    @Throws(SQLException::class)
    fun selectEmployeeByName(Name: String) {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.prepareStatement(selectEmployeeByName()).use { statement ->
                statement.setString(1, Name) // Name - это (?) из запроса
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

    // выбрать всех Employees
    @Throws(SQLException::class)
    fun selectAllStaff() {
        DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rest_staff", "postgres", "post@post23").use { connection ->
            connection.createStatement().use { statement ->
                statement.executeQuery(MySQLs.selectAllStaff()).use { resultSet ->  // применение команд?
                    while (resultSet.next()) {
                        val employeeName = resultSet.getString(2)
                        val employeePosition = resultSet.getString(3)
                        val employeePhone = resultSet.getLong(4)
                        val employeeDataBirthday = resultSet.getDate(5)
                        val id = resultSet.getInt(1)
                        println("Name: " + "{" + employeeName + "}" + " Position: " + "{" + employeePosition + "}" +
                                " Phone: " + "{" + employeePhone + "}" + " Birthday: " + "{" + employeeDataBirthday + "}" + " id: " + "{" + id + "}")
                    }
                }
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

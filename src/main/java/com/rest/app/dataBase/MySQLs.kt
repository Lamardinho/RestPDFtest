package com.rest.app.dataBase

object MySQLs {
    fun selectEmployeeById(): String {
        return "SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)"
    }

    fun selectEmployeeByName(): String {
        return "SELECT * FROM rest_staff.public.staff WHERE employee_name = (?)"
    }

    fun selectAllStaff(): String {
        return "SELECT * FROM rest_staff.public.staff"
    }

    fun createEmployee(): String {
        return "INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)"
    }

    fun deleteEmployeeById(): String {
        return "DELETE FROM rest_staff.public.staff WHERE employee_id = (?)"
    }
}

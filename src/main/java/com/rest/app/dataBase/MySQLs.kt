package com.rest.app.dataBase

object MySQLs {
    fun selectEmployee(): String {
        return "SELECT * FROM rest_staff.public.staff WHERE employee_id = (?)"
    }

    fun createEmployee(): String {
        return "INSERT INTO rest_staff.public.staff(employee_name, employee_position, employee_phone, employee_data_birthday) VALUES(?,?,?,?)"
    }

    fun deleteEmployee(): String {
        return "DELETE FROM rest_staff.public.staff WHERE employee_id = (?)"
    }
}
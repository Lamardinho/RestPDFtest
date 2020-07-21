package com.rest.app.dataBase

import java.util.HashMap

class GetMap {
    // метод для заполнения Мапы и получения её parameters
    fun getFillMap(employee: Employee): Map<String, Any> {
        val parameters: MutableMap<String, Any> = HashMap() // Parameters for report
        // Parameters for report
        parameters["jr_name"] = employee.jrName
        parameters["jr_position"] = employee.jrPosition
        parameters["jr_phone_mobile"] = employee.jrPhoneMobile
        parameters["jr_data_birthday"] = employee.jrDataBirthday
        return parameters
    }
}

package com.rest.app.dataBase

import java.util.HashMap

class GetMap {
    // метод для заполнения Мапы и получения её parameters
    fun getFillMap(employer: Employer): Map<String, Any> {
        val parameters: MutableMap<String, Any> = HashMap() // Parameters for report
        // Parameters for report
        parameters["jr_name"] = employer.jrName
        parameters["jr_position"] = employer.jrPosition
        parameters["jr_phone_mobile"] = employer.jrPhoneMobile
        parameters["jr_data_birthday"] = employer.jrDataBirthday
        return parameters
    }
}

package com.rest.app.dataBase

class EmployerGet {
    private val employerEng = Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987")
    private val employerRus = Employer("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987")

    fun getEnglish(): Employer {
        return employerEng
    }

    fun getRussian(): Employer {
        return employerRus
    }
}

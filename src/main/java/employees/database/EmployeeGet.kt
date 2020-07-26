package employees.database

import employees.database.Employee

class EmployeeGet {     // класс для создания сотрудников
    private val employeeEng = Employee("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987")
    private val employeeRus = Employee("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987")

    fun getEnglish(): Employee {
        return employeeEng
    }

    fun getRussian(): Employee {
        return employeeRus
    }
}

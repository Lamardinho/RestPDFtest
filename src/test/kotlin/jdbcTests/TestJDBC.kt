package jdbcTests

import com.rest.app.jdbc.SqlEmployeesSel
import org.junit.Test
import java.sql.Date
import java.sql.SQLException

class TestJDBC {

    private val sqlSelects = SqlEmployeesSel()

    @Test
    @Throws(SQLException::class)
    fun selectEmployeeById() {
        println("\n@Test selectEmp:")
        sqlSelects.selectEmployeeById(1)
        sqlSelects.selectEmployeeById(2)
        sqlSelects.selectEmployeeById(3)
    }

    @Test
    @Throws(SQLException::class)
    fun selectAllEmployee() {
        println("\n@Test selectAllEmp:")
        sqlSelects.selectAllStaff()
    }

    @Test
    @Throws(SQLException::class)
    fun selectEmployeeByName() {
        println("\n@Test selectAllEmp:")
        sqlSelects.selectEmployeeByName("Marcus Prince")
    }

    @Test
    @Throws(SQLException::class)
    fun createEmp() {
        println("\n@Test createEmp:")
        sqlSelects.addNewEmployee("Test User", "Tester", 89630165023L, Date.valueOf("1990-01-01"))
    }

    @Test
    @Throws(SQLException::class)
    fun deleteEmp() {
        println("\n@Test deleteEmp:")
        sqlSelects.deleteEmployeeById(28)
    }
}
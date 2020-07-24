package jdbcTests;

import com.rest.app.zJavaClasses.jdbc.SqlSelectsEmployeesJava;
import org.junit.Test;

import java.sql.SQLException;

public class TestsJdbcJava {
    private final SqlSelectsEmployeesJava sqlSelectsEmployeesJava = new SqlSelectsEmployeesJava();

    @Test
    public void selectEmployeeById() throws SQLException {
        System.out.println("\n@Test selectEmp:");
        sqlSelectsEmployeesJava.selectEmployeeById(1);
        sqlSelectsEmployeesJava.selectEmployeeById(2);
        sqlSelectsEmployeesJava.selectEmployeeById(3);
    }

    @Test
    public void selectAllEmployee() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelectsEmployeesJava.selectAllStaff();
    }

    @Test
    public void selectEmployeeByName() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelectsEmployeesJava.selectEmployeeByName("Marcus Prince");
    }

    @Test
    public void createEmp() throws SQLException {
        System.out.println("\n@Test createEmp:");
        sqlSelectsEmployeesJava.addNewEmployee("Test User", "Tester", 89630165023L, java.sql.Date.valueOf("1990-01-01"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        System.out.println("\n@Test deleteEmp:");
        sqlSelectsEmployeesJava.deleteEmployeeById(29);
    }
}

package jdbcTests;

import com.rest.app.zJavaClasses.jdbc.SqlSelectsJava;
import org.junit.Test;

import java.sql.SQLException;

public class TestsJdbcJava {
    private final SqlSelectsJava sqlSelectsJava = new SqlSelectsJava();

    @Test
    public void selectEmployeeById() throws SQLException {
        System.out.println("\n@Test selectEmp:");
        sqlSelectsJava.selectEmployeeById(1);
        sqlSelectsJava.selectEmployeeById(2);
        sqlSelectsJava.selectEmployeeById(3);
    }

    @Test
    public void selectAllEmployee() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelectsJava.selectAllStaff();
    }

    @Test
    public void selectEmployeeByName() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelectsJava.selectEmployeeByName("Marcus Prince");
    }

    @Test
    public void createEmp() throws SQLException {
        System.out.println("\n@Test createEmp:");
        sqlSelectsJava.addNewEmployee("Test User", "Tester", 89630165023L, java.sql.Date.valueOf("1990-01-01"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        System.out.println("\n@Test deleteEmp:");
        sqlSelectsJava.deleteEmployeeById(29);
    }
}

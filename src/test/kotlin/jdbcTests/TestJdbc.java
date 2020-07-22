package jdbcTests;

import com.rest.app.jdbc.SqlSelects;
import org.junit.Test;

import java.sql.SQLException;

public class TestJdbc {
    private final SqlSelects sqlSelects = new SqlSelects();

    @Test
    public void selectEmployeeById() throws SQLException {
        System.out.println("\n@Test selectEmp:");
        sqlSelects.selectEmployeeById(1);
        sqlSelects.selectEmployeeById(2);
        sqlSelects.selectEmployeeById(3);
    }

    @Test
    public void selectAllEmployee() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelects.selectAllStaff();
    }

    @Test
    public void selectEmployeeByName() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        sqlSelects.selectEmployeeByName("Marcus Prince");
    }

    @Test
    public void createEmp() throws SQLException {
        System.out.println("\n@Test createEmp:");
        sqlSelects.addNewEmployee("Test User", "Tester", 89630165023L, java.sql.Date.valueOf("1990-01-01"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        System.out.println("\n@Test deleteEmp:");
        sqlSelects.deleteEmployeeById(28);
    }
}

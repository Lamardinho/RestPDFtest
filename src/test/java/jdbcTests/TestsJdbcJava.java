package jdbcTests;

import employees.jdbc.JavaSqlEmployeesSel;
import org.junit.Test;

import java.sql.SQLException;

public class TestsJdbcJava {
    private final JavaSqlEmployeesSel javaSqlEmployeesSel = new JavaSqlEmployeesSel();

    @Test
    public void selectEmployeeById() throws SQLException {
        System.out.println("\n@Test selectEmp:");
        javaSqlEmployeesSel.selectEmployeeById(1);
        javaSqlEmployeesSel.selectEmployeeById(2);
        javaSqlEmployeesSel.selectEmployeeById(3);
    }

    @Test
    public void selectAllEmployee() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        javaSqlEmployeesSel.selectAllStaff();
    }

    @Test
    public void selectEmployeeByName() throws SQLException {
        System.out.println("\n@Test selectAllEmp:");
        javaSqlEmployeesSel.selectEmployeeByName("Marcus Prince");
    }

    @Test
    public void createEmp() throws SQLException {
        System.out.println("\n@Test createEmp:");
        javaSqlEmployeesSel.addNewEmployee("Test User", "Tester", 89630165023L, java.sql.Date.valueOf("1990-01-01"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        System.out.println("\n@Test deleteEmp:");
        javaSqlEmployeesSel.deleteEmployeeById(30);
    }
}

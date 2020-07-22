package jdbcTests;

import com.rest.app.zJavaClasses.jdbc.SqlSelectsJava;
import org.junit.Test;

import java.sql.SQLException;

public class TestsJdbcJava {
    SqlSelectsJava sqlSelectsJava = new SqlSelectsJava();

    @Test
    public void selectEmp() throws SQLException {
        System.out.println("\n@Test selectEmp:");
        sqlSelectsJava.selectEmployee(1);
        sqlSelectsJava.selectEmployee(2);
        sqlSelectsJava.selectEmployee(3);
        sqlSelectsJava.selectEmployee(4);
        sqlSelectsJava.selectEmployee(5);
        sqlSelectsJava.selectEmployee(6);
        sqlSelectsJava.selectEmployee(12);
    }

    @Test
    public void createEmp() throws SQLException {
        System.out.println("\n@Test createEmp:");
        sqlSelectsJava.addNewEmployee("Michael Jordan", "Сorporate girls сoach", 89085487041L, java.sql.Date.valueOf("1963-02-17"));
        sqlSelectsJava.addNewEmployee("LeBron James", "Сorporate сoach", 89025486047L, java.sql.Date.valueOf("1984-12-30"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        System.out.println("\n@Test deleteEmp:");
        sqlSelectsJava.deleteEmployee(26);
        sqlSelectsJava.deleteEmployee(27);
    }
}

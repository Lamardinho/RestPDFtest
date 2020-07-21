package jdbcTests;

import com.rest.app.jdbc.SqlSelects;
import org.junit.Test;

import java.sql.SQLException;

public class TestJdbc {
    SqlSelects sqlSelects = new SqlSelects();

    @Test
    public void selectEmp() throws SQLException {
        sqlSelects.selectEmployee(1);
        sqlSelects.selectEmployee(2);
        sqlSelects.selectEmployee(3);
        sqlSelects.selectEmployee(4);
        sqlSelects.selectEmployee(5);
        sqlSelects.selectEmployee(6);
        sqlSelects.selectEmployee(12);
    }

    @Test
    public void createEmp() throws SQLException {
        sqlSelects.addNewEmployee("Michael Jordan", "Сorporate girls сoach", 89085487041L, java.sql.Date.valueOf("1963-02-17"));
        sqlSelects.addNewEmployee("LeBron James", "Сorporate сoach", 89025486047L, java.sql.Date.valueOf("1984-12-30"));
    }

    @Test
    public void deleteEmp() throws SQLException {
        sqlSelects.deleteEmployee(16);
        sqlSelects.deleteEmployee(17);
    }
}

package jdbcTests;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import com.rest.app.webRest.java.old.JavaMakeOrderDownloadOld;
import net.sf.jasperreports.engine.*;
import org.junit.Test;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class TestJavaMakeOrderInternet {

    @Test
    public void test1() throws SQLException, JRException, ClassNotFoundException {
        testInsert1("Bob", 500);
    }

    @Test
    public void test2() throws SQLException, JRException, ClassNotFoundException {
        JavaMakeOrderDownloadOld makeOrder = new JavaMakeOrderDownloadOld();
        makeOrder.addNewOrder("John", 500, "internet");
    }

    public void testInsert1(String loginName, int pay) throws SQLException, JRException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");  // указываем для того, чтобы Tomcat подхватил драйвер
        final java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now()); // для вставки даты
        JasperPrint jasperPrint = null;
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23"); // подключаемся к БД
             // используем CallableStatement для работы с хранимыми процедурами
             CallableStatement callableStatement = connection.prepareCall("SELECT * FROM rtk.public.make_order(?,?,'internet',?)")) {
            callableStatement.setTimestamp(1, timestamp);   // 1ый '?' wildCard
            callableStatement.setString(2, loginName);      // 2ой '?' wildCard
            callableStatement.setInt(3, pay);               // 3ий '?' wildCard
            /*boolean hasResults = callableStatement.execute();
            while (hasResults) {ResultSet resultSet = callableStatement.getResultSet();
                while (resultSet.next()) {System.out.println(resultSet.getInt(1));}
                hasResults = callableStatement.getMoreResults();}*/
            System.out.println("You paid " + pay + " RUB");
            try (final ResultSet resultSet = callableStatement.executeQuery()) {
                if (resultSet.next()) {
                    // заполняем объект order данными из БД, для послед.наполнения мапы
                    OrderTable order = new OrderTable();
                    order.setOrderNumber(resultSet.getInt(1));
                    order.setTimestamp(resultSet.getTimestamp(2));
                    order.setCustomer(resultSet.getString(3));
                    order.setService(resultSet.getString(4));
                    order.setPay(resultSet.getInt(5));
                    // наполняем мапу параметрами для JasperReports
                    Map<String, Object> parameters = new HashMap<>(); // Parameters for report
                    parameters.put("order_number", order.getOrderNumber());
                    parameters.put("jr_name", order.getCustomer());  // customer name
                    parameters.put("jr_data", timestamp);
                    parameters.put("jr_service", order.getService());
                    parameters.put("jr_pay", order.getPay());
                    // формируем отчёт
                    JRDataSource dataSource = new JREmptyDataSource(); // без него будут пустые отчеты
                    JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getInternetPayOrderJrxml());  // от куда берём jrxml файл
                    jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);  // JasperPrint - заполняет шаблон
                    JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("TestCallableSt")); // Экспорт данных в PDF файл
                    System.out.println("method makeReport is done! New file created: " + loginName); // для отчёта
                }
            }
        }
    }
}

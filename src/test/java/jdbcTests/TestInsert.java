package jdbcTests;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;
import org.junit.Test;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class TestInsert {

    @Test
    public void test1() throws SQLException, JRException {
        testInsert1("Bob", 500);
    }

    public void testInsert1(String loginName, int pay) throws SQLException, JRException {
        final java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now()); // для вставки даты
        JasperPrint jasperPrint;
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement(
                     "SELECT * FROM rtk.public.make_order(?,?,'internet',?)")) {
            preparedStatement.setTimestamp(1, timestamp);
            preparedStatement.setString(2, loginName);
            preparedStatement.setInt(3, pay);
            // preparedStatement.execute();  // выполнить запрос
            System.out.println("You paid " + pay + " RUB");
            // CallableStatement вместо PreparedStatement (вверху)

            try (final ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    OrderTable order = new OrderTable();
                    order.setOrderNumber(resultSet.getInt(1));
                    order.setTimestamp(resultSet.getTimestamp(2));
                    order.setCustomer(resultSet.getString(3));
                    order.setService(resultSet.getString(4));
                    order.setPay(resultSet.getInt(5));
                    // наполняем мапу parameters для JasperReports
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
                    JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("JavaMakeOrderInternet")); // Экспорт данных в PDF файл
                    System.out.println("method makeReport is done! New file created: " + loginName); // для отчёта
                }
            }
        }
    }
}

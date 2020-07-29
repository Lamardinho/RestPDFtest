package com.rest.app.webRest.old;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

public class JavaBasePayMakeOrder {

    // on server
    public void makeOrderOnServer(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException {
        JasperPrint jasperPrint = processReport(loginName, service, pay);
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(loginName + "_" + myDate()));
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + myDate());
    }

    // just from browser download
    public byte[] makeOrderDownload(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException {
        JasperPrint jasperPrint = processReport(loginName, service, pay);
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + myDate());
        return JasperExportManager.exportReportToPdf(jasperPrint);
    }

    public JasperPrint processReport(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException {
        Class.forName("org.postgresql.Driver");  // указываем для того, чтобы Tomcat подхватил драйвер
        final java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now()); // для вставки даты

        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23"); // подключаемся к БД
             // используем CallableStatement для работы с хранимыми процедурами
             CallableStatement callableStatement = connection.prepareCall("SELECT * FROM rtk.public.make_order(?,?,?,?)")) {
            callableStatement.setTimestamp(1, timestamp);   // 1ый '?' wildCard
            callableStatement.setString(2, loginName);      // 2ой '?' wildCard
            callableStatement.setString(3, service);        // 3ий '?' wildCard
            callableStatement.setInt(4, pay);               // 4ый '?' wildCard

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
                    return JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);  // JasperPrint - заполняет шаблон
                }
            }
        }
        return null;
    }

    public String myDate() {
        final DateTimeFormatter myDate = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        LocalDateTime myNow = LocalDateTime.now();
        return myDate.format(myNow);
    }
}

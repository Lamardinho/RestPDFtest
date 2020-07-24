package com.rest.app.webRest;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.File;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

@Path("/JavaMakeOrderInternet")
public class JavaMakeOrderInternet {

    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON)   // тип данных получаемых от клиента в теле запроса
    public String hello() {
        return "Hello " + System.getProperty("user.name") + "!";
    }

    // добавить Order
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderInternet/Marcus?pay=500
    @GET
    @Path("/{user}")      // @Path("/{user}/{pay}")       /Marcus?pay=500
    public String addNewOrder(@PathParam("user") String loginName, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException, JRException {
        Class.forName("org.postgresql.Driver");
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement(
                     "INSERT INTO rtk.public.orders(date, fk_customer_name, fk_service, pay) VALUES (?,?,'internet',?)")) {
            java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now());
            preparedStatement.setTimestamp(1, timestamp);
            preparedStatement.setString(2, loginName);
            preparedStatement.setInt(3, pay);
            preparedStatement.executeUpdate();  // выполнить запрос
            System.out.println("You paid " + pay + " RUB");

            /*// новый запрос
            try (Connection connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
                 PreparedStatement statement = connection.prepareStatement(
                         "SELECT * FROM rtk.public.orders WHERE fk_customer_name = (?)")) {
                statement.setString(1, loginName);   // Name - это (?) из запроса
                try (final ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        OrderTable order = new OrderTable();
                        order.setOrderNumber(resultSet.getInt(1));
                        order.setTimestamp(resultSet.getTimestamp(2));
                        order.setCustomer(resultSet.getString(3));
                        order.setService(resultSet.getString(4));
                        order.setPay(resultSet.getInt(5));
                        System.out.println(order);
                    }
                }
            }*/

            //  makeReport(loginName, pay);   // заполнение мапы для отчета JasperReports
        }
        return "You paid " + pay + " RUB";
    }

    public void makeReport(String loginName, int pay) throws JRException {
        Map<String, Object> parameters = new HashMap<>(); // Parameters for report
        parameters.put("order_number", 23);
        parameters.put("jr_name", loginName);                                            // +
        parameters.put("jr_data", java.sql.Timestamp.valueOf("2020-01-01 23:23:23"));
        parameters.put("jr_service", "internet");
        parameters.put("jr_pay", pay);                                                   // +

        JRDataSource dataSource = new JREmptyDataSource(); // без него будут пустые отчеты
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getInternetPayOrder());  // от куда берём jrxml файл
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);  // JasperPrint - заполняет шаблон
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());     // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs();
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("testOrder")); // Экспорт данных в PDF файл
        System.out.println("method makeReport is done! New file created: " + loginName); // для отчёта
    }
    /*public static void main(String[] args) {
        JavaMakeOrderInternet makeOrder = new JavaMakeOrderInternet();
        try {
            makeOrder.addNewOrder("Bob", 500);
        } catch (Exception exception) {
            System.out.println("Warning! : " + exception);
        }
    }*/
}

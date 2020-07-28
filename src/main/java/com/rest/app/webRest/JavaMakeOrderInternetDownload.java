package com.rest.app.webRest;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Path("/JavaMakeOrderInternetDownload")
public class JavaMakeOrderInternetDownload {    // класс для сохранения отчета только на ПК клиента

    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON)   // тип данных получаемых от клиента в теле запроса
    public String hello() {
        return "Hello " + System.getProperty("user.name") + "!";
    }

    // добавить Order
    // http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderInternetDownload/John?pay=500
    @GET
    @Path("/{user}")      // @Path("/{user}/{pay}")       /Marcus?pay=500
    public Response addNewOrder(@PathParam("user") String loginName, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException, JRException {
        Class.forName("org.postgresql.Driver");
        final java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now()); // для вставки даты
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        JasperPrint jasperPrint = null;
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement preparedStatement = connection.prepareStatement(
                     "INSERT INTO rtk.public.orders(date, fk_customer_name, fk_service, pay) VALUES (?,?,'internet',?)")) {


            preparedStatement.setTimestamp(1, timestamp);
            preparedStatement.setString(2, loginName);
            preparedStatement.setInt(3, pay);
            preparedStatement.executeUpdate();  // выполнить запрос
            System.out.println("You paid " + pay + " RUB");

            try (PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.select_orders(?,?)")) {
                statement.setString(1, loginName);   // Name - это (?) из запроса
                statement.setTimestamp(2, timestamp);
                try (final ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        OrderTable order = new OrderTable();
                        order.setOrderNumber(resultSet.getInt(1));
                        order.setTimestamp(resultSet.getTimestamp(2));
                        order.setCustomer(resultSet.getString(3));
                        order.setService(resultSet.getString(4));
                        order.setPay(resultSet.getInt(5));
                        getExecuteQuery(ordersMap, statement);  // наполняем мапу ordersMap данными из БД
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
                        // JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("JavaMakeOrderInternet")); // Экспорт данных в PDF файл
                        System.out.println("method makeReport is done! New file created: " + loginName); // для отчёта
                    }
                }
            }
        }
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"" + loginName + "_" + timestamp + ".pdf\"").build();
    }

    // наполнение объектов order данными из БД и заполнение Мапы ordersMap для передачи на web
    private void getExecuteQuery(Map<Integer, OrderTable> ordersMap, PreparedStatement statement) throws SQLException {
        try (final ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                OrderTable order = new OrderTable();
                order.setOrderNumber(resultSet.getInt(1));
                order.setTimestamp(resultSet.getTimestamp(2));
                order.setCustomer(resultSet.getString(3));
                order.setService(resultSet.getString(4));
                order.setPay(resultSet.getInt(5));

                ordersMap.put(order.getOrderNumber(), order);
                System.out.println(order);
            }
        }
    }
}

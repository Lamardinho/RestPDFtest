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

@Path("/JavaMakeOrderInternetDownload")
public class JavaMakeOrderInternetDownload {    // класс для сохранения отчета только на ПК клиента

    @GET
    @Produces(MediaType.APPLICATION_JSON)   // тип данных отправляемых клиенту (не является обязательной?)
    @Consumes(MediaType.APPLICATION_JSON)   // тип данных получаемых от клиента в теле запроса
    public String hello() {
        return "Hello " + System.getProperty("user.name") + "!";
    }

    // добавить Order: http://localhost:8080/RestPDFtest_war_exploded/rest/JavaMakeOrderInternetDownload/John?pay=500
    @GET
    @Path("/{user}")      // @Path("/{user}/{pay}")       /Marcus?pay=500
    public Response addNewOrder(@PathParam("user") String loginName, @QueryParam("pay") int pay) throws SQLException, ClassNotFoundException, JRException {
        Class.forName("org.postgresql.Driver");  // указываем для того, чтобы Tomcat подхватил драйвер
        final java.sql.Timestamp timestamp = Timestamp.valueOf(java.time.LocalDateTime.now()); // для вставки даты
        JasperPrint jasperPrint = null;
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23"); // подключаемся к БД
             PreparedStatement preparedStatement = connection.prepareStatement(
                     "SELECT * FROM rtk.public.make_order(?,?,'internet',?)")) {
            preparedStatement.setTimestamp(1, timestamp);   // 1ый '?' wildCard
            preparedStatement.setString(2, loginName);      // 2ой '?' wildCard
            preparedStatement.setInt(3, pay);               // 3ий '?' wildCard
            // preparedStatement.execute();  // выполнить запрос
            System.out.println("You paid " + pay + " RUB");
            // реализовать CallableStatement вместо PreparedStatement (вверху)
            try (final ResultSet resultSet = preparedStatement.executeQuery()) {
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
                    // JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("JavaMakeOrderInternet")); // Экспорт данных в PDF файл
                    System.out.println("method makeReport is done! New file created: " + loginName); // для отчёта
                }
            }
        }
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"" + loginName + "_" + timestamp + ".pdf\"").build();
    }
}

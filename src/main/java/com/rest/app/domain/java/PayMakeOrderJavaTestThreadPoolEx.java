package com.rest.app.domain.java;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

public class PayMakeOrderJavaTestThreadPoolEx {

    public void myExecutor(String loginName, String service, int pay) throws Exception {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(4, 10,
                1, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>());

        Future<?> future = executor.submit((Runnable) makeOrderOnServer(loginName, service, pay));
        while (!future.isDone()) {
            System.out.println("Is not done");           // Thread.sleep(1000);
        }

        /*List<Future<String>> futures = new ArrayList<>();
        for (int i = 0; i < 4; i++) {
            futures.add(makeOrderOnServer(loginName, service, pay));        }
        for (Future<String> future : futures) {
            future.get();        }         */
        executor.shutdown();
    }

    // метод для сохранения отчета на сервере
    private Future<String> makeOrderOnServer(String loginName, String service, int pay) throws Exception {
        myExecutor(loginName, service, pay);
        JasperExportManager.exportReportToPdfFile(processReport(loginName, service, pay),
                MyPdfURLs.INSTANCE.getExportPDF(loginName + "_" + myDate()));
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + myDate());
        return null;
    }

    // метод для сохранения отчета только на стороне клиента через браузер
    private byte[] makeOrderDownload(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException {
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + myDate());
        return JasperExportManager.exportReportToPdf(processReport(loginName, service, pay));      // возвращаем массив байт
    }

    private JasperPrint processReport(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException {
        Class.forName("org.postgresql.Driver");  // указываем для того, чтобы Tomcat подхватил драйвер
        final Timestamp timestamp = Timestamp.valueOf(LocalDateTime.now());   // для вставки даты в базу данных
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
                    // заполняем объект order данными из БД, для наполнения мапы параметров JasperReports
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
                    return JasperFillManager.fillReport(JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getInternetPayOrderJrxml())
                            , parameters, new JREmptyDataSource());
                }
            }
        }
        return null;
    }

    public String myDate() {  // возвращает текущую отформатированную дату
        return DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss").format(LocalDateTime.now());
    }

    /*static class MyCallable implements Callable<String> {
        @Override
        public String call() throws Exception {
            // new PayMakeOrderJavaTestThreadPoolEx().makeOrderOnServer();
            return null;
        }
    }*/
}

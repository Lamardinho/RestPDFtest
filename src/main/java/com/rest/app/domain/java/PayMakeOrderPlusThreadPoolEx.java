package com.rest.app.domain.java;

import com.rest.app.dataBase.MyDate;
import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.dataBase.tables.OrderTable;
import net.sf.jasperreports.engine.*;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.*;

public class PayMakeOrderPlusThreadPoolEx {

    private final ThreadPoolExecutor executor = new ThreadPoolExecutor(4, 6,
            1, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>());

    // метод для сохранения отчета на сервере
    public Future<String> makeOrderOnServer(String loginName, String service, int pay) throws Exception {
        Future<JasperPrint> future = executor.submit(new MyCallable(loginName, service, pay));

        JasperExportManager.exportReportToPdfFile(future.get(),
                MyPdfURLs.INSTANCE.getExportPDF(loginName + "_" + MyDate.INSTANCE.getNowDate()));
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + MyDate.INSTANCE.getNowDate());
        return null;
    }

    // метод для сохранения отчета только на стороне клиента через браузер
    public byte[] makeOrderDownload(String loginName, String service, int pay) throws SQLException, ClassNotFoundException, JRException, ExecutionException, InterruptedException {
        Future<JasperPrint> future = executor.submit(new MyCallable(loginName, service, pay));
        System.out.println("method makeReport is done! New file created: " + loginName + "_" + MyDate.INSTANCE.getNowDate());
        return JasperExportManager.exportReportToPdf(future.get());      // возвращаем массив байт
    }

    static class MyCallable implements Callable<JasperPrint> {
        private final String loginName;
        private final String service;
        private final int pay;

        public MyCallable(String loginName, String service, int pay) {
            this.loginName = loginName;
            this.service = service;
            this.pay = pay;
        }

        @Override
        public JasperPrint call() throws Exception {
            return processReport();
        }

        private JasperPrint processReport() throws SQLException, ClassNotFoundException, JRException {
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
    }
}

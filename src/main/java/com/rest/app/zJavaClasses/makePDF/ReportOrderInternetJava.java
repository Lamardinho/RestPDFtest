package com.rest.app.zJavaClasses.makePDF;

import com.rest.app.dataBase.MyPdfURLs;
import net.sf.jasperreports.engine.*;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class ReportOrderInternetJava {
    /*public void makeReport(String reportName) throws JRException {
        Map<String, Object> parameters = new HashMap<>(); // Parameters for report
        // Parameters for report // можно переписать параметры в методе, если переменная более в 2ух методах
        parameters.put("order_number", 23);
        parameters.put("jr_name", "Marcus");
        parameters.put("jr_data", java.sql.Timestamp.valueOf("2020-01-01 23:23:23"));
        parameters.put("jr_service", "internet");
        parameters.put("jr_pay", 500);

        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource(); // обязательно использовать! без него будут пустые отчеты
        // от куда берём jrxml файл
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getInternetPayOrder());
        // JasperPrint - заполняет шаблон
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);
        // проверка и создание пути для экспорта PDF файла
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        // Экспорт данных в PDF файл
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("testOrder"));
        // для отчёта
        System.out.println("method makeReport is done! New file created: " + reportName);
    }

    public static void main(String[] args) throws JRException {
        ReportOrderInternetJava makeOrder = new ReportOrderInternetJava();
        makeOrder.makeReport("reportName");
    }*/
}

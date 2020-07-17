package com.rest.app.zJava.makePDF;

import com.rest.app.dataBase.Employer;
import com.rest.app.dataBase.EmployerGet;
import com.rest.app.dataBase.GetMap;
import com.rest.app.dataBase.MyPdfURLs;
import net.sf.jasperreports.engine.*;

import java.io.File;

public class ReportPDF {
    private final EmployerGet employerGet = new EmployerGet();
    private final GetMap getMap = new GetMap();

    public void makeReport(Employer employer, String reportName) throws JRException {
        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource(); // обязательно использовать! без него будут пустые отчеты
        // от куда берём jrxml файл
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        // JasperPrint - заполняет шаблон
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employer), dataSource);
        // проверка и создание пути для экспорта PDF файла
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        // Экспорт данных в PDF файл
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(reportName));
        // для отчёта
        System.out.println("method makeReport is done! New file created: " + reportName);
    }

    // для RESTа - генерирует PDF на сервере
    public void makeRestReport(String userName) throws JRException {
        JRDataSource dataSource = new JREmptyDataSource();
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employerGet.getEnglish()), dataSource);
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(userName));
        System.out.println("method makeTestReport is done! New file created :" + MyPdfURLs.INSTANCE.getExportPDF(userName));
    }
}

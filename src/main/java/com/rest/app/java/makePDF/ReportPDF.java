package com.rest.app.java.makePDF;

import com.rest.app.dataBaseK.Employer;
import com.rest.app.dataBaseK.EmployerGet;
import com.rest.app.dataBaseK.GetMap;
import com.rest.app.dataBaseK.MyPdfURLs;
import net.sf.jasperreports.engine.*;

import java.io.File;

public class ReportPDF {
    private final EmployerGet employerGet = new EmployerGet();
    private final GetMap getMap = new GetMap();

    public void makeReport(Employer employer, String reportName) throws JRException {
        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource();
        // от куда берём jrxml файл
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        // JasperPrint
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employer), dataSource);
        // проверка и создание пути для экспорта PDF файла
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(reportName));
        //JasperExportManager.exportReportToPdfStream(jasperPrint,);
        System.out.println("method makeReport is done! New file created: " + reportName);
    }

    // для RESTа
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

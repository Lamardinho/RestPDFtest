package com.rest.app.makePDF;

import com.rest.app.dataBaseK.Employer;
import com.rest.app.dataBaseK.MyPdfURLs;
import net.sf.jasperreports.engine.*;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class ReportPDF {
    // сотрудники, для вставки данных в отчет
    private final Employer employerEng = new Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987");
    private final Employer employerRus = new Employer("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987");

    public void makeReport(Employer employer, String reportName) throws JRException {
        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource();
        // от куда берём jrxml файл
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        // JasperPrint
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getFillMapParam(employer), dataSource);
        // проверка и создание пути для экспорта PDF файла
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(reportName));
        //JasperExportManager.exportReportToPdfStream(jasperPrint,);
        System.out.println("method makeReport is done! New file created: " + reportName);
    }

    public void makeTestReport() throws JRException {
        JRDataSource dataSource = new JREmptyDataSource();
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getFillMapParam(employerEng), dataSource);
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        JasperExportManager.exportReportToPdfFile(
                jasperPrint, MyPdfURLs.INSTANCE.getExportPDF("test"));
        System.out.println("method makeTestReport is done! New file created :" + MyPdfURLs.INSTANCE.getExportPDF("test"));
    }

    public void makeRestReport(String userName) throws JRException {
        JRDataSource dataSource = new JREmptyDataSource();
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getFillMapParam(employerEng), dataSource);
        File outDir = new File(MyPdfURLs.INSTANCE.getDirWay());
        outDir.mkdirs();
        JasperExportManager.exportReportToPdfFile(jasperPrint, MyPdfURLs.INSTANCE.getExportPDF(userName));
        System.out.println("method makeTestReport is done! New file created :" + MyPdfURLs.INSTANCE.getExportPDF(userName));
    }

    @NotNull
    // метод для заполнения Мапы и получения её parameters
    protected Map<String, Object> getFillMapParam(Employer employer) {
        Map<String, Object> parameters = new HashMap<>(); // Parameters for report
        // Parameters for report
        parameters.put("jr_name", employer.getJrName());
        parameters.put("jr_position", employer.getJrPosition());
        parameters.put("jr_phone_mobile", employer.getJrPhoneMobile());
        parameters.put("jr_data_birthday", employer.getJrDataBirthday());
        return parameters;
    }

    public Employer getEmployerEng() {
        return employerEng;
    }

    public Employer getEmployerRus() {
        return employerRus;
    }
}

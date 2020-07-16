package com.rest.app.makePDF;

import dataBaseK.Employer;
import net.sf.jasperreports.engine.*;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class ReportPDF {
    // сотрудники, для вставки данных в отчет
    private final Employer employerEng = new Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987");
    private final Employer employerRus = new Employer("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987");

    public void makeReport(Employer employer, String name) throws JRException {
        Map<String, Object> parameters = new HashMap<String, Object>(); // Parameters for report
        // Parameters for report // можно переписать параметры в методе, если переменная более в 2ух методах
        parameters.put("jr_name", employer.getJrName());
        parameters.put("jr_position", employer.getJrPosition());
        parameters.put("jr_phone_mobile", employer.getJrPhoneMobile());
        parameters.put("jr_data_birthday", employer.getJrDataBirthday());
        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource();
        // от куда берём jrxml файл
        JasperReport jrxmlFile = JasperCompileManager.compileReport("src/main/resources/templates/myReport.jrxml");
        // JasperPrint
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);
        // Make sure the output directory exists
        File outDir = new File("src/main/resources/PDFoutput"); // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs();
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, "src/main/resources/PDFoutput/" + name + ".pdf");
        //JasperExportManager.exportReportToPdfStream(jasperPrint,);
        System.out.println("Done!");
    }

    public void makeTestReport() throws JRException {
        Map<String, Object> parameters = new HashMap<String, Object>(); // Parameters for report
        // Parameters for report // можно переписать параметры в методе, если переменная более в 2ух методах
        parameters.put("jr_name", employerEng.getJrName());
        parameters.put("jr_position", employerEng.getJrPosition());
        parameters.put("jr_phone_mobile", employerEng.getJrPhoneMobile());
        parameters.put("jr_data_birthday", employerEng.getJrDataBirthday());
        // DataSource. This is simple example, no database. Then using empty datasource
        JRDataSource dataSource = new JREmptyDataSource();
        // от куда берём jrxml файл
        //D:\JavaProjects\RestPDFtest\src\main\java\com\rest\app\web

        JasperReport jrxmlFile = JasperCompileManager.compileReport("src/main/resources/templates/myReport.jrxml");
        // JasperPrint
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource);
        // Make sure the output directory exists
        File outDir = new File("src/main/resources/PDFoutput"); // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs();
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, "src/main/resources/PDFoutput/Test.pdf");
        //JasperExportManager.exportReportToPdfStream(jasperPrint,);
        System.out.println("Done!");
    }

    public Employer getEmployerEng() {
        return employerEng;
    }

    public Employer getEmployerRus() {
        return employerRus;
    }
}

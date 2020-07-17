package com.rest.app.makePDF;

import com.rest.app.dataBaseK.Employer;
import com.rest.app.dataBaseK.MyPdfURLs;
import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.util.FileBufferedOutputStream;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class ReportPdfBuffer {
    private final Employer employerEng = new Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987");

    public void makeReportBuffer() throws JRException, IOException {
        JRDataSource dataSource = new JREmptyDataSource();
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getFillMapParam(employerEng), dataSource);
        /*StringBuilder stringBuffer = new StringBuilder();
        stringBuffer.append(jasperPrint);*/
        File pdf = File.createTempFile("output.", ".pdf");
        JasperExportManager.exportReportToPdfStream(jasperPrint, new FileOutputStream(pdf));
    }

    public static void main(String[] args) throws JRException, IOException {
        ReportPdfBuffer reportPdfBuffer = new ReportPdfBuffer();
        reportPdfBuffer.makeReportBuffer();
    }

    @NotNull
    // метод для заполнения Мапы и получения её parameters
    private Map<String, Object> getFillMapParam(Employer employer) {
        Map<String, Object> parameters = new HashMap<>(); // Parameters for report
        // Parameters for report
        parameters.put("jr_name", employer.getJrName());
        parameters.put("jr_position", employer.getJrPosition());
        parameters.put("jr_phone_mobile", employer.getJrPhoneMobile());
        parameters.put("jr_data_birthday", employer.getJrDataBirthday());
        return parameters;
    }
}
/*
// get the JRXML template as a stream
InputStream template = JasperReportsApplication.class
    .getResourceAsStream("/sampleReport.xml");
// compile the report from the stream
JasperReport report = JasperCompileManager.compileReport(template);
// fill out the report into a print object, ready for export.
JasperPrint print = JasperFillManager.fillReport(report, new HashMap<String, String>());
// export it!
File pdf = File.createTempFile("output.", ".pdf");
JasperExportManager.exportReportToPdfStream(print, new FileOutputStream(pdf));
 */
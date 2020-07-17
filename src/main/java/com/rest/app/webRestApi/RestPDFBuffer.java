package com.rest.app.webRestApi;

import com.rest.app.dataBaseK.Employer;
import com.rest.app.dataBaseK.MyPdfURLs;
import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.*;
import org.jetbrains.annotations.NotNull;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Path("/pdfbuffer")
public class RestPDFBuffer {
    private final Employer employerEng = new Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987");

    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer
    */
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/Marcus";
    }

    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/Marcus
    */
    @GET
    @Path("/{buffername}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Response createPDFReport(@PathParam("buffername") String gPDFName) throws JRException, IOException {
        JRDataSource dataSource = new JREmptyDataSource();
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getFillMapParam(employerEng), dataSource);

        File pdf = File.createTempFile("output.", ".pdf");
        JasperExportManager.exportReportToPdfStream(jasperPrint, new FileOutputStream(pdf));

        //File pdfFile = new File(pdf); // читаем сегенерир. файл
        return Response.ok().entity(pdf).header( // и отправляем его
                "Content-disposition", "attachment; filename=\"" + gPDFName + ".pdf\"").build();
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

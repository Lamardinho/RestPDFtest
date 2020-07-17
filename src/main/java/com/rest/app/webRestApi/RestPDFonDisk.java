package com.rest.app.webRestApi;

import com.rest.app.dataBaseK.MyPdfURLs;
import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.awt.*;
import java.io.File;

@Path("/pdf")
public class RestPDFonDisk {
    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/pdf
    */
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdf/Marcus";
    }

    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/pdf/Marcus
    */
    @GET
    @Path("/{pdfname}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Response createPDFReport(@PathParam("pdfname") String gPDFName) throws JRException {
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeRestReport(gPDFName); // генерируем PDF и присваимваем имя "gPDFName"
        File pdfFile = new File(MyPdfURLs.INSTANCE.getExportPDF(gPDFName)); // читаем сегенерир. файл
        return Response.ok().entity(pdfFile).header( // и открываем его
                "Content-disposition", "attachment; filename=\"" + gPDFName + ".pdf\"").build();
    }

    // просто формирует и открывает локально PDFку:
    /*@GET
    @Path("/{name}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public String createPDFReport2(@PathParam("name") String gName) throws JRException {
        //String user = System.getProperty("user.name"); // определяет имя пользователя системы
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeRestReport(gName);
        openPDF(gName);
        return "'makeRestReport' is done! New file name: " + gName;
    }
    void openPDF(String reportPlace) {
        try {
            File pdfFile = new File("D:/JavaProjects/RestPDFtest/src/main/resources/PDFoutput/" + reportPlace + ".pdf");
            if (pdfFile.exists()) {
                if (Desktop.isDesktopSupported()) {
                    Desktop.getDesktop().open(pdfFile);
                } else {
                    System.out.println("Awt Desktop is not supported!");
                }
            } else {
                System.out.println("File is not exists!");
            }
            System.out.println("Done");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }*/
}

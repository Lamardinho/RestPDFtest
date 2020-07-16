package com.rest.app.webRestApi;

import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.awt.*;
import java.io.File;

@Path("/pdf")
public class RestPDF {
    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/test
    */
    @GET
    public String checkPerson() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user;
    }

    /*
    http://localhost:8080/RestPDFtest_war_exploded/rest/hello/Marcus
    */
    @GET
    @Path("/{name}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public String checkPerson(@PathParam("name") String gName) throws JRException {
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
    }
}

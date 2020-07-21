package com.rest.app.webRest;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.zJavaClasses.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.File;

@Path("/javapdf")
public class JavaRestPDFonDisk {

    // http://localhost:8080/RestPDFtest_war_exploded/rest/pdf
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdf/Marcus";
    }

    // http://localhost:8080/RestPDFtest_war_exploded/rest/pdf/Marcus
    @GET
    @Path("/{javapdfname}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Response createPDFReport(@PathParam("javapdfname") String gPDFName) throws JRException {
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeRestReport(gPDFName); // генерируем PDF и присваимваем имя "gPDFName"
        File pdfFile = new File(MyPdfURLs.INSTANCE.getExportPDF(gPDFName)); // читаем сегенерир. файл
        return Response.ok().entity(pdfFile).header( // и открываем его
                "Content-disposition", "attachment; filename=\"" + gPDFName + ".pdf\"").build();
    }
}

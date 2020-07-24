package com.rest.app.webRest;

import com.rest.app.dataBase.EmployeeGet;
import com.rest.app.dataBase.GetMap;
import com.rest.app.dataBase.MyPdfURLs;
import net.sf.jasperreports.engine.*;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/JavaRestPDFBuffer")
public class JavaRestPDFBuffer {
    private final EmployeeGet employeeGet = new EmployeeGet(); // ссылка на сотрудника
    private final GetMap getMap = new GetMap();

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/JavaRestPDFBuffer
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/Marcus";
    }

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/JavaRestPDFBuffer/anyname
    // формирование PDFки в буфер и сохранение на стороне клиента:
    @GET
    @Path("/{javabufname}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Response createPDFReport(@PathParam("javabufname") String gPDFName) throws JRException {
        JRDataSource dataSource = new JREmptyDataSource();  // обязательно использовать! без него будут пустые отчеты
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employeeGet.getEnglish()), dataSource);
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"" + gPDFName + ".pdf\"").build();
    }
}

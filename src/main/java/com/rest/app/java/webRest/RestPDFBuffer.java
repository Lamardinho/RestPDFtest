package com.rest.app.java.webRest;

import com.rest.app.dataBaseK.EmployerGet;
import com.rest.app.dataBaseK.GetMap;
import com.rest.app.dataBaseK.MyPdfURLs;
import net.sf.jasperreports.engine.*;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/pdfbuffer")
public class RestPDFBuffer {
    private final EmployerGet employerGet = new EmployerGet(); // ссылка на сотрудника
    private final GetMap getMap = new GetMap();

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer
    @GET
    public String hello() {
        String user = System.getProperty("user.name"); // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/Marcus";
    }

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/anyname
    // формирование PDFки в буфер и сохранение на стороне клиента:
    @GET
    @Path("/{pdfbuffer}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    public Response createPDFReport(@PathParam("pdfbuffer") String gPDFName) throws JRException {
        JRDataSource dataSource = new JREmptyDataSource();  // обязательно использовать! без него будут пустые отчеты
        JasperReport jrxmlFile = JasperCompileManager.compileReport(MyPdfURLs.INSTANCE.getMyReportJrxml());
        JasperPrint jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employerGet.getEnglish()), dataSource);
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"" + gPDFName + ".pdf\"").build();
    }

    /*@NotNull
    // метод для заполнения Мапы и получения её parameters
    private Map<String, Object> getFillMapParam(Employer employer) {
        Map<String, Object> parameters = new HashMap<>(); // Parameters for report
        // Parameters for report
        parameters.put("jr_name", employer.getJrName());
        parameters.put("jr_position", employer.getJrPosition());
        parameters.put("jr_phone_mobile", employer.getJrPhoneMobile());
        parameters.put("jr_data_birthday", employer.getJrDataBirthday());
        return parameters;
    }*/
}

package com.rest.app.webRest

import com.rest.app.dataBase.EmployerGet
import com.rest.app.dataBase.GetMap
import com.rest.app.dataBase.MyPdfURLs.getMyReportJrxml
import net.sf.jasperreports.engine.*
import javax.ws.rs.GET
import javax.ws.rs.Path
import javax.ws.rs.PathParam
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType
import javax.ws.rs.core.Response

@Path("/pdfbuffer")
open class RestPDFBuffer {
    private val employerGet = EmployerGet() // ссылка на сотрудника
    private val getMap = GetMap()

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer
    @GET
    open fun hello(): String? {
        val user = System.getProperty("user.name") // определяет имя пользователя системы
        return "Hello " + user + "! Enter the filename in the URL line to export to PDF: /filename." +
                " Eg: http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/Marcus"
    }

    //  http://localhost:8080/RestPDFtest_war_exploded/rest/pdfbuffer/anyname
    // формирование PDFки в буфер и сохранение на стороне клиента:
    @GET
    @Path("/{buffername}")
    @Produces(MediaType.APPLICATION_JSON) // для передачи в формате JSON
    @Throws(JRException::class)
    fun createPDFReport(@PathParam("buffername") gPDFName: String): Response? {
        val dataSource: JRDataSource = JREmptyDataSource() // обязательно использовать! без него будут пустые отчеты
        val jrxmlFile = JasperCompileManager.compileReport(getMyReportJrxml()) // выбираем шаблон
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employerGet.getEnglish()), dataSource) // заполняем шаблон
        return Response.ok().entity(JasperExportManager.exportReportToPdf(jasperPrint)).header(
                "Content-disposition", "attachment; filename=\"$gPDFName.pdf\"").build()
    }
}

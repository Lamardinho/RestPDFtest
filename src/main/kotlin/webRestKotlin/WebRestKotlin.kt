package webRestKotlin

import makePDFk.ReportPdfKotlin
import net.sf.jasperreports.engine.JRException
import javax.ws.rs.GET
import javax.ws.rs.Path

@Path("/pdfk")
class WebRestKotlin {
    @GET
    @Throws(JRException::class)
    fun makeReport(): String {
        val reportPDF = ReportPdfKotlin()
        reportPDF.testRestReport()
        return "Done: 'testRestReport' "
    }
}

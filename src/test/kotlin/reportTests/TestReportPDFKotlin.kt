package reportTests

import makePDFk.ReportPdfKotlin
import net.sf.jasperreports.engine.JRException
import org.junit.Test

class TestReportPDFKotlin {
    private val reportPdfKotlin = ReportPdfKotlin()

    @Test
    @Throws(JRException::class)
    fun setCreatePDFmyBlankParam2() {  // создаем файлы.pdf
        reportPdfKotlin.makeReport(reportPdfKotlin.employerEng, "myReport")
        reportPdfKotlin.makeReport(reportPdfKotlin.employerRus, "myReport3")
    }
}

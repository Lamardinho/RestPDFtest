package employees.makePDF

import employees.database.MyPdfFiles.getMyReport
import employees.database.MyPdfFiles.getMyReport2
import com.testautomationguru.utility.PDFUtil

class ComparisonPDF {
    // сравнение файлов
    @Throws(Exception::class)
    fun compPDF() {
        val pdfUtil = PDFUtil() // читает PDF и переводит его в String
        val comparison = pdfUtil.compare(getMyReport(), getMyReport2()) // MyPdfFiles.INSTANCE.
        println("compPDF: myReport vs myReport2 = $comparison")
    }

    // сравнение файлов на выбор
    @Throws(Exception::class)
    fun compPDF(a: String, b: String) {
        val pdfUtil = PDFUtil() // читает PDF и переводит его в String
        val comparison = pdfUtil.compare(a, b)
        println("compPDF(a, b): $a vs $b = $comparison")
    }
}

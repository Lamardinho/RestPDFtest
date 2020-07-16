package makePDFk

import com.testautomationguru.utility.PDFUtil
import com.rest.app.dataBaseK.MyPdfFiles


class ComparisonPdfKotlin {
  //  private val files = MyPdfFiles() // ссылка на файлы . заменили на object MyPdfFiles {
    private val pdfUtil = PDFUtil()  // читает PDF и переводит его в String


    @Throws(Exception::class)
    fun compPDF() {    // сравнение
        val comparison = pdfUtil.compare(MyPdfFiles.getMyReport(), MyPdfFiles.getMyReport2())
        println("compPDF: myReport vs myReport2 = $comparison")
    }

    @Throws(Exception::class)
    fun compPDF(a: String?, b: String?) {
        val comparison = pdfUtil.compare(a, b)
        println("compPDF(a, b): $a vs $b = $comparison")
    }
}
package reportTests

import com.testautomationguru.utility.PDFUtil // добавляем библиотеку для работы с PDF
import dataBaseK.MyPdfFiles
import makePDFk.ComparisonPdfKotlin
import org.junit.Assert
import org.junit.Test

class TestComparisonPdfKotlin { // класс для сравнения PDF файлов

    @Test // положительное сравнение
    @Throws(Exception::class)
    fun compPDF() {
        val pdfUtil = PDFUtil() // читает PDF и переводит его в String
        val comparison = pdfUtil.compare(MyPdfFiles.getMyReport(), MyPdfFiles.getMyReport2())
        Assert.assertTrue(comparison)
        println("compPDF: myReport vs myReport2 = $comparison")
    }

    @Test // отрицательное сравнение
    @Throws(Exception::class)
    fun compPDF2() {
        val pdfUtil = PDFUtil() // читает PDF и переводит его в String
        val comparison = pdfUtil.compare(MyPdfFiles.getMyReport(), MyPdfFiles.getMyReport3())
        Assert.assertFalse(comparison)
        println("compPDF2: myReport vs myReport3 = $comparison")
    }

    @Test   // тест с параметрами
    @Throws(Exception::class)
    fun compPDF3() {
        val comparisonPdfKotlin = ComparisonPdfKotlin()
        comparisonPdfKotlin.compPDF(MyPdfFiles.getMyReport(), MyPdfFiles.getMyReport2())
        comparisonPdfKotlin.compPDF(MyPdfFiles.getMyReport(), MyPdfFiles.getMyReport3())
    }

    /*@Test
    @Throws(JRException::class)
    fun myBlank() {
        // сотрудник, для вставки данных в отчет
        val employer = EmployerKotlin("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987")

        // от куда берём jrxml файл
        val jrxmlFile = JasperCompileManager.compileReport("src/main/resources/templates/myReport.jrxml")

        // Parameters for report
        val parameters: MutableMap<String, Any?> = HashMap()
        parameters["jr_name"] = employer.jrName
        parameters["jr_position"] = employer.jrPosition
        parameters["jr_phone_mobile"] = employer.jrPhoneMobile
        parameters["jr_data_birthday"] = employer.jrDataBirthday

        // DataSource. This is simple example, no database. Then using empty datasource
        val dataSource: JRDataSource = JREmptyDataSource()

        // JasperPrint
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource)

        // Make sure the output directory exists
        val outDir = File("src/main/resources/PDFoutput") // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs()

        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, "src/main/resources/PDFoutput/KotlinMyBlank.pdf") // путь и имя экспортируемого PDF файла

        println("Done!")
    }
    @Test
    @Throws(JRException::class)
    fun myBlank3() {     // для формирования 3го файла "myBlank3" и проверки вставки данных на кириллице
        // сотрудник, для вставки данных
        val employer = EmployerKotlin("Илья Слезкин", "Developer", "8-963-01-65-023", "16.04.1987")

        // Compile jrxml file   // от куда берём jrxml файл
        val jrxmlFile = JasperCompileManager.compileReport("src/main/resources/templates/myReport.jrxml")

        // Parameters for report
        val parameters: MutableMap<String, Any?> = HashMap()
        parameters["jr_name"] = employer.jrName
        parameters["jr_position"] = employer.jrPosition
        parameters["jr_phone_mobile"] = employer.jrPhoneMobile
        parameters["jr_data_birthday"] = employer.jrDataBirthday

        // DataSource. This is simple example, no database. Then using empty datasource
        val dataSource: JRDataSource = JREmptyDataSource()

        // JasperPrint
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource)

        // Make sure the output directory exists
        val outDir = File("src/main/resources/PDFoutput") // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs()

        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, "src/main/resources/PDFoutput/KotlinMyBlank3.pdf")

        println("Done!")    }*/
}
package reportTests;

import com.testautomationguru.utility.PDFUtil; // добавляем библиотеку для работы с PDF
import com.rest.app.dataBaseK.MyPdfFiles;
import org.junit.Assert;
import org.junit.Test;
import com.rest.app.makePDF.ComparisonPDF;

public class TestComparisonPDF { // класс для сравнения PDF файлов
    private final PDFUtil pdfUtil = new PDFUtil();      // читает PDF и переводит его в String

    @Test   // положительное сравнение
    public void compPDF() throws Exception {
        boolean comparison = pdfUtil.compare(MyPdfFiles.INSTANCE.getMyReport(), MyPdfFiles.INSTANCE.getMyReport2());
        Assert.assertTrue(comparison);
        System.out.println("compPDF: myReport vs myReport2 = " + comparison);
    }

    @Test   // отрицательное сравнение
    public void compPDF2() throws Exception {
        boolean comparison = pdfUtil.compare(MyPdfFiles.INSTANCE.getMyReport(), MyPdfFiles.INSTANCE.getMyReport3());
        Assert.assertFalse(comparison);
        System.out.println("compPDF2: myReport vs myReport3 = " + comparison);
    }

    @Test   // тест с параметрами
    public void compPDF3() throws Exception {
        ComparisonPDF comparisonPDF = new ComparisonPDF();
        comparisonPDF.compPDF(MyPdfFiles.INSTANCE.getMyReport(), MyPdfFiles.INSTANCE.getMyReport2());
        comparisonPDF.compPDF(MyPdfFiles.INSTANCE.getMyReport(), MyPdfFiles.INSTANCE.getMyReport3());
    }
}

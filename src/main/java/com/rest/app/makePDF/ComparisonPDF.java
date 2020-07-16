package com.rest.app.makePDF;

import com.testautomationguru.utility.PDFUtil; // добавляем библиотеку для работы с PDF
import com.rest.app.dataBaseK.MyPdfFiles;

public class ComparisonPDF {

    public void compPDF() throws Exception {   // сравнение
        PDFUtil pdfUtil = new PDFUtil();      // читает PDF и переводит его в String
        boolean comparison = pdfUtil.compare(MyPdfFiles.INSTANCE.getMyReport(), MyPdfFiles.INSTANCE.getMyReport2()); // INSTANCE дает ссылку на объект "object класса MyPdfFiles
        System.out.println("compPDF: myReport vs myReport2 = " + comparison);
    }

    public void compPDF(String a, String b) throws Exception {
        PDFUtil pdfUtil = new PDFUtil();      // читает PDF и переводит его в String
        boolean comparison = pdfUtil.compare(a, b);
        System.out.println("compPDF(a, b): " + a + " vs " + b + " = " + comparison);
    }
}

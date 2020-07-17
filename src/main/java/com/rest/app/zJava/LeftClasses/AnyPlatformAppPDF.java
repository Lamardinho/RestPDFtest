package com.rest.app.zJava.LeftClasses;

import com.rest.app.dataBase.MyPdfFiles;

import java.awt.*;
import java.io.File;
import java.io.IOException;

// **************   класс для открытия PDF файлов - НЕ ИСПОЛЬЗУЕТСЯ ***************

public class AnyPlatformAppPDF {
    public static void main(String[] args) throws IOException {
        /*ProcessBuilder processBuilder = new ProcessBuilder(MyPdfFiles.INSTANCE.getMyReport());
        processBuilder.start();*/
        try {
            File pdfFile = new File(MyPdfFiles.INSTANCE.getMyReport());
            if (pdfFile.exists()) {
                if (Desktop.isDesktopSupported()) {
                    Desktop.getDesktop().open(pdfFile);
                } else System.out.println("Awt Desktop is not supported!");
            } else System.out.println("File is not exists!");
            System.out.println("Done");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    // НЕ ЮЗАЛ:
    public static void openWebpage(java.net.URI uri) {
        Desktop desktop = Desktop.isDesktopSupported() ? Desktop.getDesktop() : null;
        if (desktop != null && desktop.isSupported(Desktop.Action.BROWSE)) {
            try {
                desktop.browse(uri);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

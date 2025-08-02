import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';

class ExportUtils {
  static Future<void> exportToPDF(List<Product> products, BuildContext context) async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfGrid grid = PdfGrid();

      // Define grid columns
      grid.columns.add(count: 3);
      grid.headers.add(1);
      final PdfGridRow header = grid.headers[0];
      header.cells[0].value = 'Product Name';
      header.cells[1].value = 'Price';
      header.cells[2].value = 'Stock';

      // Style headers
      header.style = PdfGridRowStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        textBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
      );

      // Add product rows
      for (var product in products) {
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = product.productName;
        row.cells[1].value = '\$${product.price.toStringAsFixed(2)}';
        row.cells[2].value = product.stock.toString();
      }

      // Style grid
      grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
        borderOverlapStyle: PdfBorderOverlapStyle.inside,
        cellSpacing: 1,
      );

      // Draw grid on page
      grid.draw(
        page: page,
        bounds: const Rect.fromLTWH(0, 20, 0, 0),
      );

      // Save to file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/products_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await document.save());
      document.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported to $path'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> exportToCSV(List<Product> products, BuildContext context) async {
    try {
      final StringBuffer csv = StringBuffer();
      csv.writeln('Product Name,Price,Stock');
      for (var product in products) {
        final name = '"${product.productName.replaceAll('"', '""')}"'; // Escape quotes
        csv.writeln('$name,\$${product.price.toStringAsFixed(2)},${product.stock}');
      }

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/products_${DateTime.now().millisecondsSinceEpoch}.csv';
      await File(path).writeAsString(csv.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported to $path'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
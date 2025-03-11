import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Mkhalfat extends StatelessWidget {
  final List<Map<String, dynamic>> violations = [
    {
      "name": "إعاقة طريق",
      "value": "10",
      "location": "الفروانية",
      "file": "https://example.com/file1.pdf",
      "status": "ادفع الآن",
      "color": Colors.red
    },
    {
      "name": "كسر إشارة",
      "value": "50",
      "location": "السالمية",
      "file": "https://example.com/file2.pdf",
      "status": "تم الدفع",
      "color": Colors.green
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المخالفات")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            dataRowHeight: 35,
            headingRowHeight: 40,
            border: TableBorder.all(color: Colors.black),
            headingRowColor: MaterialStateProperty.all(Colors.blue[900]),
            columns: [
              DataColumn(label: Text("اسم المخالفة", style: _headerTextStyle)),
              DataColumn(label: Text("القيمة", style: _headerTextStyle)),
              DataColumn(label: Text("المكان", style: _headerTextStyle)),
              DataColumn(label: Text("مرفقات", style: _headerTextStyle)),
              DataColumn(label: Text("الحالة", style: _headerTextStyle)),
            ],
            rows: violations.map((data) {
              return DataRow(cells: [
                DataCell(Text(data["name"], style: _cellTextStyle)),
                DataCell(Text(data["value"], style: _cellTextStyle)),
                DataCell(Text(data["location"], style: _cellTextStyle)),
                DataCell(
                  TextButton(
                    onPressed: () => _openUrl(data["file"]),
                    child: Text("تحميل ملف", style: TextStyle(color: Colors.blue, fontSize: 10)),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: data["color"],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      data["status"],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // دالة لفتح الرابط في المتصفح الافتراضي للموبايل
  void _openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("لا يمكن فتح الرابط: $url");
    }
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
  );

  static const TextStyle _cellTextStyle = TextStyle(
    fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black,
  );
}

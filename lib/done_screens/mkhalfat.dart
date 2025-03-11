import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Mkhalfat extends StatelessWidget {
  const Mkhalfat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المخالفات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('violations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          var violations = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "name": data["name"] ?? "غير معروف",
              "value": data["value"]?.toString() ?? "0",
              "location": data["location"] ?? "غير معروف",
              "fileUrl": data["fileUrl"] ?? "",
              "status": data["status"] ?? "غير معروف",
            };
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 9, // تحسين المسافات بين الأعمدة
                dataRowHeight: 45, // زيادة ارتفاع الصفوف لعرض أفضل
                headingRowHeight: 50, // تحسين وضوح العناوين
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade900),
                columns: const [
                  DataColumn(label: Text("اسم المخالفة", style: _headerTextStyle)),
                  DataColumn(label: Text("القيمة", style: _headerTextStyle)),
                  DataColumn(label: Text("المكان", style: _headerTextStyle)),
                  DataColumn(label: Text("مرفقات", style: _headerTextStyle)),
                  DataColumn(label: Text("الحالة", style: _headerTextStyle)),
                ],
                rows: violations.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return index.isEven ? Colors.grey.shade100 : Colors.white; // تباين الألوان بين الصفوف
                      },
                    ),
                    cells: [
                      DataCell(Text(data["name"], style: _cellTextStyle)),
                      DataCell(Text("${data["value"]} ", style: _cellTextStyle)), // إضافة د.ك للعملة
                      DataCell(Text(data["location"], style: _cellTextStyle)),
                      DataCell(
                        data["fileUrl"].isNotEmpty
                            ? TextButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(data['fileUrl']);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              print("❌ لا يمكن فتح الرابط");
                            }
                          },
                          child: const Text("تحميل", style: TextStyle(color: Colors.blue, fontSize: 12)),
                        )
                            : const Text("لا يوجد", style: _cellTextStyle),
                      ),
                      DataCell(
                        Text(
                          data["status"],
                          style: TextStyle(
                            color: data["status"] == "تم الدفع" ? Colors.green : Colors.red, // لون الحالة
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, // لون أبيض للعناوين
  );

  static const TextStyle _cellTextStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black, // تحسين حجم الخط
  );
}

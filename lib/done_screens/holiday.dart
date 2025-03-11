import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Holiday extends StatelessWidget {
  const Holiday({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإجازات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('holidays').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          var vacations = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "travelDate": data["travelDate"] ?? "غير متاح",
              "returnDate": data["returnDate"] ?? "غير متاح",
              "remainingDays": data["remainingDays"]?.toString() ?? "غير متاح",
              "debt": data["debt"] ?? "غير معروف",
              "fileUrl": data["fileUrl"] ?? "",
              "status": data["status"] ?? "غير معروف",
            };
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 5,
                dataRowHeight: 45,
                headingRowHeight: 50,
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade900),
                columns: const [
                  DataColumn(label: Text("تاريخ السفر", style: _headerTextStyle)),
                  DataColumn(label: Text("تاريخ العودة", style: _headerTextStyle)),
                  DataColumn(label: Text("المتبقي", style: _headerTextStyle)),
                  DataColumn(label: Text("المديونية", style: _headerTextStyle)),
                  DataColumn(label: Text("المرفقات", style: _headerTextStyle)),
                  DataColumn(label: Text("الحالة", style: _headerTextStyle)),
                ],
                rows: vacations.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return index.isEven ? Colors.grey.shade100 : Colors.white; // تناوب ألوان الصفوف
                      },
                    ),
                    cells: [
                      DataCell(Text(data["travelDate"], style: _cellTextStyle)),
                      DataCell(Text(data["returnDate"], style: _cellTextStyle)),
                      DataCell(
                        Text(
                          data["remainingDays"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: data["remainingDays"] == "صفر" ? Colors.black : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          data["debt"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: data["debt"] == "تم الدفع" ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        data["fileUrl"].isNotEmpty
                            ? TextButton(
                          onPressed: () {
                            print("تحميل الملف من: ${data['fileUrl']}");
                          },
                          child: const Text("تحميل", style: TextStyle(color: Colors.blue, fontSize: 12)),
                        )
                            : const Text("لا يوجد", style: _cellTextStyle),
                      ),
                      DataCell(
                        Text(
                          data["status"],
                          style: TextStyle(
                            color: data["status"] == "مازال" ? Colors.red : Colors.green, // لون بناءً على الحالة
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

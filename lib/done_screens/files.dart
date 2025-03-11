import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Files extends StatelessWidget {
  const Files({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المستندات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('files').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          var documents = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "name": data["name"] ?? "غير معروف",
              "startDate": data["startDate"] ?? "غير متاح",
              "endDate": data["endDate"] ?? "غير متاح",
              "remainingDays": data["remainingDays"]?.toString() ?? "غير متاح",
              "fileUrl": data["fileUrl"] ?? "",
              "status": data["status"] ?? "غير معروف",
            };
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 0, // تحسين المسافات بين الأعمدة
                dataRowHeight: 45, // تحسين ارتفاع الصفوف
                headingRowHeight: 50, // تحسين وضوح العناوين
                border: TableBorder.all(color: Colors.grey.shade300), // لون خفيف للحدود
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade900), // لون أزرق داكن للعناوين
                columns: const [
                  DataColumn(label: Text("المستند", style: _headerTextStyle)),
                  DataColumn(label: Text("تاريخ البداية", style: _headerTextStyle)),
                  DataColumn(label: Text("تاريخ الانتهاء", style: _headerTextStyle)),
                  DataColumn(label: Text("متبقي", style: _headerTextStyle)),
                  DataColumn(label: Text("ملف", style: _headerTextStyle)),
                  DataColumn(label: Text("الحالة", style: _headerTextStyle)),
                ],
                rows: documents.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return index.isEven ? Colors.grey.shade100 : Colors.white; // تناوب ألوان الصفوف
                      },
                    ),
                    cells: [
                      DataCell(Text(data["name"], style: _cellTextStyle)),
                      DataCell(Text(data["startDate"], style: _cellTextStyle)),
                      DataCell(Text(data["endDate"], style: _cellTextStyle)),
                      DataCell(
                        Text(
                          data["remainingDays"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: data["remainingDays"].contains("-") ? Colors.red : Colors.black,
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
                            color: data["status"] == "منتهي" ? Colors.red : Colors.green, // لون بناءً على الحالة
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Oil extends StatelessWidget {
  const Oil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تغيير زيت وفلاتر")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('oil_changes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          var oilChanges = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              "changeDate": data["changeDate"] ?? "غير متاح",
              "amount": data["amount"]?.toString() ?? "غير متاح",
              "centerPhone": data["centerPhone"] ?? "غير متاح",
              "centerAddress": data["centerAddress"] ?? "غير متاح",
              "fileUrl": data["fileUrl"] ?? "",
              "status": data["status"] ?? "غير معروف",
            };
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 4,
                dataRowHeight: 45,
                headingRowHeight: 50,
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade900),
                columns: const [
                  DataColumn(label: Text("تاريخ التغيير", style: _headerTextStyle)),
                  DataColumn(label: Text("المبلغ", style: _headerTextStyle)),
                  DataColumn(label: Text("هاتف المركز", style: _headerTextStyle)),
                  DataColumn(label: Text("عنوان المركز", style: _headerTextStyle)),
                  DataColumn(label: Text("المرفقات", style: _headerTextStyle)),
                  DataColumn(label: Text("الحالة", style: _headerTextStyle)),
                ],
                rows: oilChanges.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return index.isEven ? Colors.grey.shade100 : Colors.white;
                      },
                    ),
                    cells: [
                      DataCell(Text(data["changeDate"], style: _cellTextStyle)),
                      DataCell(Text(data["amount"], style: _cellTextStyle)),
                      DataCell(Text(data["centerPhone"], style: _cellTextStyle)),
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            print("فتح العنوان: ${data['centerAddress']}");
                          },
                          child: Text(
                            data["centerAddress"],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
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
                            color: data["status"] == "مازال" ? Colors.red : Colors.green,
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
    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white,
  );

  static const TextStyle _cellTextStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black,
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Egar extends StatelessWidget {
  const Egar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإيجارات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rents').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          // استخراج البيانات من Firestore
          var rentData = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // فرز البيانات حسب التاريخ (الأقدم أولًا)
          rentData.sort((a, b) => a["date"].compareTo(b["date"]));

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 15,
              dataRowHeight: 35,
              headingRowHeight: 40,
              border: TableBorder.all(color: Colors.black),
              columns: const [
                DataColumn(label: Text("العدد", style: _headerTextStyle)),
                DataColumn(label: Text("التاريخ", style: _headerTextStyle)),
                DataColumn(label: Text("القيمة الإيجارية", style: _headerTextStyle)),
                DataColumn(label: Text("مستحق الدفع", style: _headerTextStyle)),
                DataColumn(label: Text("الحالة", style: _headerTextStyle)),
              ],
              rows: rentData.asMap().entries.map((entry) {
                int index = entry.key + 1; // تحديد العدد تلقائيًا
                var data = entry.value;

                return DataRow(cells: [
                  DataCell(Text(index.toString(), style: _cellTextStyle)),
                  DataCell(Text(data["date"], style: _cellTextStyle)),
                  DataCell(Text(data["rent"].toString(), style: _cellTextStyle)),
                  DataCell(Text(data["due"].toString(), style: _cellTextStyle)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: (data["status"] == "تم الدفع") ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        data["status"],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black,
  );

  static const TextStyle _cellTextStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black,
  );
}

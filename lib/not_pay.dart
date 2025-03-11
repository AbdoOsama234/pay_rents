import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotPay extends StatelessWidget {
  const NotPay({Key? key}) : super(key: key);

  // 🔹 تحديث الحالة في Firestore عند الضغط على "ادفع الآن"
  void _markAsPaid(String docId) async {
    await FirebaseFirestore.instance.collection('rents').doc(docId).update({
      "status": "تم الدفع"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المتأخرات (المطلوب سدادها)")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rents').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          // 🔹 تصفية البيانات لاستبعاد "تم الدفع"
          var duePayments = snapshot.data!.docs
              .where((doc) => doc["status"] != "تم الدفع")
              .toList();

          if (duePayments.isEmpty) {
            return const Center(child: Text("لا توجد متأخرات مستحقة 🎉"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 8,
                dataRowHeight: 45,
                headingRowHeight: 45,
                border: TableBorder.all(color: Colors.black),
                columns: [
                  DataColumn(label: Text("العدد", style: _headerTextStyle)),
                  DataColumn(label: Text("التاريخ", style: _headerTextStyle)),
                  DataColumn(label: Text("القيمة الإيجارية", style: _headerTextStyle)),
                  DataColumn(label: Text("مستحق الدفع", style: _headerTextStyle)),
                  DataColumn(label: Text("الحالة", style: _headerTextStyle)),
                ],
                rows: duePayments.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var doc = entry.value;
                  var data = doc.data() as Map<String, dynamic>;

                  return DataRow(cells: [
                    DataCell(Text(index.toString(), style: _cellTextStyle)),
                    DataCell(Text(data["date"] ?? "غير معروف", style: _cellTextStyle)),
                    DataCell(Text(data["rent"]?.toString() ?? "0", style: _cellTextStyle)),
                    DataCell(Text(data["due"]?.toString() ?? "0", style: _cellTextStyle)),
                    DataCell(
                      GestureDetector(
                        onTap: () => _markAsPaid(doc.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "ادفع الآن",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  static const TextStyle _headerTextStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black,
  );

  static const TextStyle _cellTextStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black,
  );
}

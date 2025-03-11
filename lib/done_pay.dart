import 'package:flutter/material.dart';
import 'package:pay_rents/done_screens/egar.dart';
import 'package:pay_rents/done_screens/files.dart';
import 'package:pay_rents/done_screens/holiday.dart';
import 'package:pay_rents/done_screens/mkhalfat.dart';
import 'package:pay_rents/done_screens/oil.dart';

class DonePay extends StatefulWidget {
  @override
  _DonePayState createState() => _DonePayState();
}

class _DonePayState extends State<DonePay> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المدفوعات"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // يسمح بالتمرير في حال كثرة التبويبات
          tabs: [
            Tab(icon: Icon(Icons.apartment), text: "الإيجار"),
            Tab(icon: Icon(Icons.report), text: "المخالفات"),
            Tab(icon: Icon(Icons.folder), text: "المستندات"),
            Tab(icon: Icon(Icons.beach_access), text: "الإجازات"),
            Tab(icon: Icon(Icons.oil_barrel), text: "تغيير الزيت"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Egar(),
          Mkhalfat(),
          Files(),
          Holiday(),
          Oil(),
        ],
      ),
    );
  }

  Widget _buildTabContent(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

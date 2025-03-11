import 'package:flutter/material.dart';
import 'package:pay_rents/done_pay.dart';
import 'package:pay_rents/not_pay.dart';

import 'notifications_screens/main_notification.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DonePay(),
    NotPay(),
    MainNotification(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "المدفوعات",
           activeIcon: Icon(Icons.home, color: Colors.green),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.warning, ), label: "المطلوب سداده",
              activeIcon: Icon(Icons.warning, color: Colors.red,)

    ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "الاشعارات",
            activeIcon: Icon(Icons.notifications, color: Colors.blue),),
        ],
      ),
    );

  }
}

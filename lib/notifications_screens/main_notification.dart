import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainNotification extends StatefulWidget {
  const MainNotification({super.key});

  @override
  State<MainNotification> createState() => _MainNotificationState();
}

class _MainNotificationState extends State<MainNotification> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.notifications_active_sharp), text: "إشعارات السائق"),
            Tab(icon: Icon(Icons.notifications), text: "إشعارات الشركة"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList("driver_notifications"), // إشعارات السائق
          _buildCompanyNotifications(), // إشعارات الشركة + الدفع
        ],
      ),
    );
  }

  // 🔹 دالة إنشاء الإشعارات العامة
  Widget _buildNotificationList(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد إشعارات 📭", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
        }

        return _buildNotificationItems(snapshot.data!.docs);
      },
    );
  }

  // 🔹 دالة إنشاء إشعارات الشركة + الدفع
  Widget _buildCompanyNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('company_notifications').orderBy('date', descending: true).snapshots(),
      builder: (context, companySnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rents').where("status", isEqualTo: "تم الدفع").orderBy('date', descending: true).snapshots(),
          builder: (context, rentSnapshot) {
            if (companySnapshot.connectionState == ConnectionState.waiting || rentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<QueryDocumentSnapshot> companyNotifications = companySnapshot.data?.docs ?? [];
            List<QueryDocumentSnapshot> paidRentNotifications = rentSnapshot.data?.docs ?? [];

            // 🛠 طباعة عدد البيانات المسترجعة للتحقق
            debugPrint("📢 إشعارات الشركة: ${companyNotifications.length}");
            debugPrint("💰 إشعارات الدفع: ${paidRentNotifications.length}");

            if (companyNotifications.isEmpty && paidRentNotifications.isEmpty) {
              return const Center(child: Text("لا توجد إشعارات 📭", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
            }

            // 🔹 دمج الإشعارات وترتيبها حسب التاريخ
            var allNotifications = [...companyNotifications, ...paidRentNotifications];
            allNotifications.sort((a, b) {
              var dateA = (a.data() as Map<String, dynamic>)["date"] ?? "";
              var dateB = (b.data() as Map<String, dynamic>)["date"] ?? "";
              return dateB.compareTo(dateA); // ترتيب تنازلي
            });

            return _buildNotificationItems(allNotifications);
          },
        );
      },
    );
  }

  // 🔹 دالة عرض الإشعارات
  Widget _buildNotificationItems(List<QueryDocumentSnapshot> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        var data = notifications[index].data() as Map<String, dynamic>;

        bool isPaymentNotification = data.containsKey("due") && data.containsKey("rent");

        return ListTile(
          leading: Icon(
            isPaymentNotification ? Icons.attach_money : Icons.notifications,
            color: isPaymentNotification ? Colors.green : Colors.blue,
            size: 30,
          ),
          title: Text(
            isPaymentNotification ? "تم الدفع: ${data["rent"]} جنيه" : data["title"] ?? "عنوان غير متاح",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isPaymentNotification ? "المبلغ المدفوع: ${data["due"]} جنيه" : data["message"] ?? "محتوى غير متاح",
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            data["date"] ?? "",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        );
      },
    );
  }
}

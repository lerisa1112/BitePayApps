import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await NotificationService.fetchNotifications();

      if (!mounted) return;

      setState(() {
        notifications = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> clearAll() async {
    await NotificationService.clearNotifications();

    if (!mounted) return;

    setState(() {
      notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications cleared")),
    );
  }

  Future<void> deleteOne(String id) async {
    await NotificationService.deleteNotification(id);

    if (!mounted) return;

    setState(() {
      notifications.removeWhere((item) => item["_id"] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification deleted")),
    );
  }

  Future<void> refresh() async {
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          TextButton.icon(
            onPressed: clearAll,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text(
              "Clear All",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No Notifications 🎉",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )

              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isRead = n["isRead"] ?? false;
                      final id = n["_id"] ?? "";

                      return Dismissible(
                        key: Key(id + index.toString()),

                        direction: DismissDirection.endToStart,

                        onDismissed: (_) {
                          deleteOne(id);
                        },

                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border(
                              left: BorderSide(
                                color: isRead
                                    ? Colors.transparent
                                    : Colors.amber,
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),

                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),

                            leading: CircleAvatar(
                              backgroundColor: isRead
                                  ? Colors.grey.shade300
                                  : Colors.amber.shade100,
                              child: Icon(
                                Icons.notifications,
                                color: isRead ? Colors.grey : Colors.amber,
                              ),
                            ),

                            title: Text(
                              n["title"] ?? "No Title",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isRead ? Colors.grey : Colors.black,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                n["message"] ?? "",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => deleteOne(id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
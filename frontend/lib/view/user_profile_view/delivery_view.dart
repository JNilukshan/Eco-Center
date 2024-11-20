import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryView extends StatefulWidget {
  final String userId;

  const DeliveryView({super.key, required this.userId});

  @override
  _DeliveryViewState createState() => _DeliveryViewState();
}

class _DeliveryViewState extends State<DeliveryView> {
  List<Map<String, dynamic>> deliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeliveryHistory();
  }

  // Dummy data for deliveries
  Future<void> fetchDeliveryHistory() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      deliveries = [
        {
          'deliveryId': '672af219d2029ad6a26801d7',
          'driverName': 'Pasindu Sandeepa',
          'recipientName': 'Nilukshan Janith',
          'deliveryAmount': 2500,
          'deliveryDate': '2024-11-06T10:30:00Z',
          'orderDetails': {
            'orderId': '672adcb874b5fcb8cc2b80b1',
            'wholesalerName': 'Nilukshan Janith',
            'wholesalerAddress': 'Chilaw',
            'wholesalerPhone': '+1234567890',
            'createdAt': '2024-11-06T10:00:00Z',
            'message': 'New job',
          }
        },
        {
          'deliveryId': 'DEL002',
          'driverName': 'Kavundu Sankalpa',
          'recipientName': 'Chamara Jayashan',
          'deliveryAmount': 3000,
          'deliveryDate': '2024-11-05T14:00:00Z',
          'orderDetails': {
            'orderId': 'ORD002',
            'wholesalerName': 'Alicia Williams',
            'wholesalerAddress': '456 Elm Street, Townsville',
            'wholesalerPhone': '+0987654321',
            'createdAt': '2024-11-05T13:45:00Z',
            'message': 'Urgent delivery',
          }
        },
      ];

      deliveries.sort((a, b) {
        final dateA = DateTime.parse(a['deliveryDate']);
        final dateB = DateTime.parse(b['deliveryDate']);
        return dateB.compareTo(dateA);
      });

      isLoading = false;
    });
  }

  Future<void> deleteDelivery(String deliveryId) async {
    setState(() {
      deliveries
          .removeWhere((delivery) => delivery['deliveryId'] == deliveryId);
    });
  }

  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery History"),
        backgroundColor: const Color.fromARGB(255, 18, 53, 19),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveries.isEmpty
              ? const Center(child: Text("No deliveries found"))
              : ListView.builder(
                  itemCount: deliveries.length,
                  itemBuilder: (context, index) {
                    final delivery = deliveries[index];
                    final orderDetails = delivery['orderDetails'];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Delivery ID: ${delivery['deliveryId']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Total Amount: Rs. ${delivery['deliveryAmount']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Delivery Date: ${formatDate(delivery['deliveryDate'])}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Color.fromARGB(255, 6, 57, 11)),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Delete Delivery Record"),
                                          content: const Text(
                                              "Are you sure you want to delete this delivery record?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await deleteDelivery(
                                                    delivery['deliveryId']);
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Color.fromARGB(255, 16, 63, 26)),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              "Order Details:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text("Order ID: ${orderDetails['orderId']}"),
                            Text(
                                "Wholesaler Name: ${orderDetails['wholesalerName']}"),
                            Text(
                                "Wholesaler Address: ${orderDetails['wholesalerAddress']}"),
                            Text(
                                "Wholesaler Phone: ${orderDetails['wholesalerPhone']}"),
                            Text(
                                "Order Date: ${formatDate(orderDetails['createdAt'])}"),
                            Text("Message: ${orderDetails['message']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

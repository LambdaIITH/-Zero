import 'package:flutter/material.dart';

class BusTicketScreen extends StatelessWidget {
  const BusTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Ticket'),
      ),
      body: const Center(
        child: Text('Bus Ticket Screen'),
      ),
    );
  }
}

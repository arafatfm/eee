import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 120,
      child: Column(
        children: [
          const SizedBox(height: 100,),
          TextButton(
            child: const Text('Calendar'),
            onPressed: () {
              
            },
          ),
          TextButton(
            child: const Text('Attendance'),
            onPressed: () {
              
            },
          ),
          TextButton(
            child: const Text('Routine'),
            onPressed: () {
              
            },
          ),
          TextButton(
            child: const Text('E-books'),
            onPressed: () {
              
            },
          ),
        ],
      ),
    );
  }
}
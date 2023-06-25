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
              if(ModalRoute.of(context)?.settings.name == '/') {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
              
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
              if(ModalRoute.of(context)?.settings.name == '/routine') {
                Navigator.of(context).pop();
              } else if(ModalRoute.of(context)?.settings.name == '/') {
                Navigator.of(context).popAndPushNamed('/routine');
              } else {
                Navigator.of(context).pushReplacementNamed('/routine');
              }
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
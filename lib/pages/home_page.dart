import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: const Center(
        child: Text(
          'Page des Utilisateurs',
          style: TextStyle(
            fontSize: 16.0, // Normal text size
            color: Color(0xFF000000), // Black color
          ),
        ),
      ),
    );
  }
}
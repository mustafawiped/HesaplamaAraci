import 'package:flutter/material.dart';

class feedbackscreen extends StatefulWidget {
  @override
  feedbackState createState() => feedbackState();
}

class feedbackState extends State<feedbackscreen>
    with SingleTickerProviderStateMixin {
  Color colorTheme = Color.fromARGB(255, 199, 0, 169);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geri Bildirim"),
        backgroundColor: colorTheme,
      ),
      body: const Center(
        child: Text("inaktif"),
      ),
    );
  }
}

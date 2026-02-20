// lib/asmaul_husna_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List _asmaulHusna = [];
  bool _isLoading = true;

  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/Asmaul husna/asmaul_husna.json');
      final data = await json.decode(response);
      setState(() {
        _asmaulHusna = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading Asmaul Husna JSON: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Asmaul Husna', style: TextStyle(color: Color(0xFFF5F5F5))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
          : GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.0, 
              ),
              itemCount: _asmaulHusna.length,
              itemBuilder: (context, index) {
                final item = _asmaulHusna[index];
                return AsmaulHusnaCard(itemData: item);
              },
            ),
    );
  }
}

class AsmaulHusnaCard extends StatelessWidget {
  final Map<String, dynamic> itemData; 

  const AsmaulHusnaCard({super.key, required this.itemData});

  void _showDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                itemData['arabic'],
                style: const TextStyle(
                  fontFamily: 'LPMQ', 
                  fontSize: 32, 
                  color: Color(0xFF4DB6AC)
                ),
              ),
              const SizedBox(height: 8),
              Text(
                itemData['latin'],
                style: const TextStyle(
                  fontSize: 18, 
                  color: Color(0xFFF5F5F5), 
                  fontWeight: FontWeight.bold
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 32),
              const Text(
                'Arti:',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF4DB6AC), 
                  fontSize: 14
                ),
              ),
              const SizedBox(height: 8),
              Text(
                itemData['translation_id'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontStyle: FontStyle.italic, 
                  color: Color(0xFFE0E0E0), 
                  fontSize: 16
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      clipBehavior: Clip.antiAlias, 
      child: InkWell( 
        onTap: () => _showDetailBottomSheet(context), 
        child: Padding(
          padding: const EdgeInsets.all(12.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Text(
                itemData['arabic'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'LPMQ',
                  fontSize: 24, 
                  color: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                itemData['latin'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, 
                  color: Color(0xFFA0A0A0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
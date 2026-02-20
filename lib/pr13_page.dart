// lib/pr13_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pr13_detail_page.dart'; 

class Pr13Page extends StatefulWidget {
  const Pr13Page({super.key});

  @override
  State<Pr13Page> createState() => _Pr13PageState();
}

class _Pr13PageState extends State<Pr13Page> {
  List _pr13List = [];
  bool _isLoading = true;

  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/PR 13/pr13.json');
      final data = await json.decode(response);
      setState(() {
        _pr13List = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading Kumpulan Doa JSON: $e");
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
        title: const Text('PR 13', style: TextStyle(color: Color(0xFFF5F5F5))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
          : ListView.separated( 
              padding: const EdgeInsets.symmetric(vertical: 12.0), 
              itemCount: _pr13List.length,
              itemBuilder: (context, index) {
                final doa = _pr13List[index];

                return ListTile(
                  title: Text(
                    doa['title'] ?? 'PR-${doa['id']}', 
                    style: const TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF4DB6AC)), 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pr13DetailPage(doaData: doa), 
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2C2C2C), 
                thickness: 1,
                height: 1,
                indent: 16, 
                endIndent: 16,
              ),
            ),
    );
  }
}
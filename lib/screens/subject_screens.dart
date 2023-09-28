import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './chapters_units_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key? key});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Map<String, dynamic>>? subjects;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final response = await http.get(Uri.parse(
        'https://www.eschool2go.org/api/v1/project/ba7ea038-2e2d-4472-a7c2-5e4dad7744e3'));

    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> subjectMap = json.decode(response.body);
        subjects = subjectMap.entries
            .map((entry) => entry.value)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('List of Subjects')),
      ),
      body: subjects == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              // physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: subjects!.length,
              itemBuilder: (context, index) {
                Color randomColor =
                    Colors.primaries[index % Colors.primaries.length];
                return Card(
                  elevation: 6,
                  shadowColor: randomColor,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterUnitsScreen(
                              subject: subjects![index]['name']),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: randomColor,
                          child: Text(
                            subjects![index]['name'][0],
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subjects![index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

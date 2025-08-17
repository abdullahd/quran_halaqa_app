import 'package:flutter/material.dart';
import 'package:quran_halaqa_app/features/attendance/presentation/attendance_screen.dart';
import 'package:quran_halaqa_app/models/halaqa.dart';
import 'package:quran_halaqa_app/models/student.dart';

class HalaqaListScreen extends StatelessWidget {
  HalaqaListScreen({super.key});

  // --- بيانات مؤقتة للمرحلة الأولى ---
  final List<Halaqa> _dummyHalaqat = [
    Halaqa(
      id: 'h1',
      name: 'حلقة الفجر',
      students: [
        Student(id: 's1', name: 'أحمد كبير'),
        Student(id: 's2', name: 'عبدالحكيم يوسف'),
        Student(id: 's3', name: 'عمران أبوبكر'),
        Student(id: 's4', name: 'عبدالله محمد'),
        Student(id: 's5', name: 'عبدالمصور محمد'),
      ],
    ),
    Halaqa(
      id: 'h2',
      name: 'حلقة العصر',
      students: [
        Student(id: 's15', name: 'خالد يوسف'),
        Student(id: 's16', name: 'مصطفى محمد'),
        Student(id: 's17', name: 'أرشد الـأنصاري'),
        Student(id: 's11', name: 'فهد عبدالرحمن'),
      ],
    ),
    Halaqa(
      id: 'h3',
      name: 'حلقة المغرب',
      students: [
        Student(id: 's21', name: 'عبدالله يوسف'),
        Student(id: 's22', name: 'أحمد محمد'),
        Student(id: 's23', name: 'خالد ولبد'),
      ],
    ),
  ];
  // --- نهاية البيانات المؤقتة ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حلقاتي'),
      ),
      body: ListView.builder(
        itemCount: _dummyHalaqat.length,
        itemBuilder: (context, index) {
          final halaqa = _dummyHalaqat[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color.fromARGB(255, 150, 173, 151), // Lighter green
                child: const Icon(Icons.group,
                    color: Color.fromARGB(255, 11, 39, 22)), // Dark green
              ),
              title: Text(halaqa.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${halaqa.students.length} طلاب'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // التنقل إلى شاشة الحضور عند الضغط
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceScreen(halaqa: halaqa),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add halaqa functionality
        },
        backgroundColor: const Color.fromARGB(255, 192, 231, 194),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 31, 30, 30)),
      ),
    );
  }
}

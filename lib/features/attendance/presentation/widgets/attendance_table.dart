import 'package:flutter/material.dart';
import 'package:quran_halaqa_app/models/student.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart'; // Step 2: Import shared_preferences
import 'dart:convert'; // Step 3: Import for jsonEncode/jsonDecode (needed for saving/loading data)

// Enum لتمثيل حالات الحضور
enum AttendanceStatus { present, absent, excused, none }

class AttendanceTable extends StatefulWidget {
  final List<Student> students;
  final DateTime weekDate; // أي يوم في الأسبوع المطلوب عرضه

  const AttendanceTable(
      {super.key, required this.students, required this.weekDate});

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  // سنستخدم Map لحفظ حالات الحضور بشكل مؤقت في الذاكرة
  // المفتاح سيكون 'studentId-dateString'
  Map<String, AttendanceStatus> attendanceRecords = {};

  // Track whether there are unsaved changes so the user can explicitly save
  bool _hasUnsavedChanges = false;

  // Step 2: Load attendance data from shared_preferences when the widget starts
  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  // Step 2: Method to load attendance data
  Future<void> _loadAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved attendance map as a string (JSON)
    final savedData = prefs.getString('attendanceRecords');
    if (savedData != null) {
      // Decode the JSON string to a Map
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          (savedData.isNotEmpty)
              ? Map<String, dynamic>.from(await Future.value(
                  Map<String, dynamic>.from(jsonDecode(savedData))))
              : {});
      setState(() {
        attendanceRecords = decoded.map((key, value) => MapEntry(
              key,
              AttendanceStatus.values[value as int], // Convert int back to enum
            ));
      });
    }
  }

  // Step 2: Method to save attendance data
  Future<void> _saveAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the attendanceRecords map to a map of int values (enum index)
    final Map<String, int> toSave =
        attendanceRecords.map((key, value) => MapEntry(key, value.index));
    // Save as JSON string
    await prefs.setString('attendanceRecords', jsonEncode(toSave));
  }

  // دالة لتحديد لون الخلية بناءً على الحالة
  Color _getColorForStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.shade100;
      case AttendanceStatus.absent:
        return Colors.red.shade100;
      case AttendanceStatus.excused:
        return Colors.yellow.shade100;
      default:
        return Colors.transparent;
    }
  }

  // دالة لتحديد أيقونة الخلية بناءً على الحالة
  IconData? _getIconForStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check; // حاضر
      case AttendanceStatus.absent:
        return Icons.close; // غائب
      case AttendanceStatus.excused:
        return Icons.info_outline; // غائب بعذر
      default:
        return null;
    }
  }

  void _updateAttendance(String studentId, DateTime date) {
    final dateString = intl.DateFormat('yyyy-MM-dd').format(date);
    final key = '$studentId-$dateString';

    setState(() {
      final currentStatus = attendanceRecords[key] ?? AttendanceStatus.none;
      // الدورة: حاضر -> غائب -> غائب بعذر -> لا شيء
      if (currentStatus == AttendanceStatus.none) {
        attendanceRecords[key] = AttendanceStatus.present;
      } else if (currentStatus == AttendanceStatus.present) {
        attendanceRecords[key] = AttendanceStatus.absent;
      } else if (currentStatus == AttendanceStatus.absent) {
        attendanceRecords[key] = AttendanceStatus.excused;
      } else {
        attendanceRecords.remove(key);
      }
      // Mark that there are unsaved changes. User must press Save to persist.
      _hasUnsavedChanges = true;
    });
  }

  // Called by the Save button to persist changes and clear the unsaved flag
  Future<void> _onSavePressed() async {
    await _saveAttendanceRecords();
    setState(() {
      _hasUnsavedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ بيانات الحضور')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // حساب أيام الأسبوع بناءً على التاريخ المحدد
    final weekStart = widget.weekDate.subtract(
        Duration(days: widget.weekDate.weekday % 7)); // بداية الأسبوع (الأحد)
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Column(
      children: [
        // Row with Save button. Disabled when there are no unsaved changes.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _hasUnsavedChanges ? _onSavePressed : null,
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
              columns: [
                const DataColumn(
                    label: Text('الطالب',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                // إنشاء أعمدة التواريخ
                for (var day in weekDays)
                  DataColumn(
                    label: Text(
                      '${intl.DateFormat.E('ar').format(day)}\n${day.day}', // اسم اليوم + رقم اليوم
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
              rows: widget.students.map((student) {
                return DataRow(
                  cells: [
                    DataCell(Text(student.name)),
                    // إنشاء خلايا الحضور لكل يوم
                    for (var day in weekDays)
                      DataCell(
                        Container(
                          color: _getColorForStatus(
                            attendanceRecords[
                                    '${student.id}-${intl.DateFormat('yyyy-MM-dd').format(day)}'] ??
                                AttendanceStatus.none,
                          ),
                          child: Center(
                            child: Icon(
                              _getIconForStatus(
                                attendanceRecords[
                                        '${student.id}-${intl.DateFormat('yyyy-MM-dd').format(day)}'] ??
                                    AttendanceStatus.none,
                              ),
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        onTap: () {
                          // لا نسجل حضور في المستقبل
                          if (day.isBefore(
                              DateTime.now().add(const Duration(days: 0)))) {
                            _updateAttendance(student.id, day);
                          }
                        },
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

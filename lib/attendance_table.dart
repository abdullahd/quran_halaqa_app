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

  // Loads attendance data from local storage when the widget starts
  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  // Clears all attendance data from memory and local storage
  Future<void> _clearAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendanceRecords'); // Remove from storage
    setState(() {
      attendanceRecords.clear(); // Clear the local map
    });
  }

  // Loads attendance data from local storage
  Future<void> _loadAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('attendanceRecords'); // Get saved data
    if (savedData != null && savedData.isNotEmpty) {
      // Decode the JSON string to a Map<String, dynamic>
      final Map<String, dynamic> decoded = jsonDecode(savedData);
      setState(() {
        // Convert int values back to AttendanceStatus enum
        attendanceRecords = decoded.map((key, value) => MapEntry(
              key,
              AttendanceStatus.values[value as int],
            ));
      });
    }
  }

  // Saves attendance data to local storage whenever it changes
  Future<void> _saveAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the attendanceRecords map to a map of int values (enum index)
    final Map<String, int> toSave =
        attendanceRecords.map((key, value) => MapEntry(key, value.index));
    await prefs.setString(
        'attendanceRecords', jsonEncode(toSave)); // Save as JSON string
  }

  // Returns cell color based on attendance status
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

  // Returns cell icon based on attendance status
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

  // Returns the circle background color for the status (used for the round icon background)
  Color _getCircleColorForStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF14532D); // dark green
      case AttendanceStatus.absent:
        return Colors.redAccent; // red
      case AttendanceStatus.excused:
        return Colors.orangeAccent; // yellow/orange for excused
      default:
        return Colors.transparent; // no fill for 'none'
    }
  }

  // Updates attendance status for a student on a given date and saves the change
  // Cycles through: none → present → absent → excused → none
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

      _saveAttendanceRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    // حساب أيام الأسبوع بناءً على التاريخ المحدد
    // Normalize the provided weekDate to a date-only value (midnight)
    final normalizedWeekDate = DateTime(
        widget.weekDate.year, widget.weekDate.month, widget.weekDate.day);
    // Start of week (Sunday) based on the normalized date
    final weekStart = normalizedWeekDate
        .subtract(Duration(days: normalizedWeekDate.weekday % 7));
    // Generate 7 date-only days for the week
    final weekDays = List.generate(
      7,
      (index) => DateTime(weekStart.year, weekStart.month, weekStart.day)
          .add(Duration(days: index)),
    );

    // Builds the UI: reset button, confirmation dialog, and attendance table
    return Column(
      children: [
        // Button to reset all attendance records
        ElevatedButton(
          onPressed: () async {
            // Show confirmation dialog before clearing attendance
            final shouldClear = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                    'تأكيد إعادة التعيين'), // "Confirm Reset" in Arabic
                content: const Text(
                    'هل أنت متأكد أنك تريد إعادة تعيين جميع بيانات الحضور؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('إلغاء'), // Cancel
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('تأكيد'), // Confirm
                  ),
                ],
              ),
            );
            if (shouldClear == true) {
              _clearAttendanceRecords();
              // Show a success message after clearing attendance
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'تمت إعادة تعيين الحضور بنجاح!'), // "Attendance reset successfully!" in Arabic
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child:
              const Text('إعادة تعيين الحضور'), // "Reset Attendance" in Arabic
        ),
        // Attendance table
        SingleChildScrollView(
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
                      // Make the whole data cell circular and use status color as its fill.
                      Builder(
                        builder: (context) {
                          final status = attendanceRecords[
                                  '${student.id}-${intl.DateFormat('yyyy-MM-dd').format(day)}'] ??
                              AttendanceStatus.none;
                          final fillColor = status == AttendanceStatus.none
                              ? Colors.transparent
                              : _getCircleColorForStatus(status);
                          // Violet/purple based theme
                          final borderColor = fillColor == Colors.transparent
                              ? const Color(0xFFD1C4E9) // lavender border
                              : Colors.transparent;
                          final iconColor = fillColor == Colors.transparent
                              ? const Color(0xFF7C4DFF) // deep violet for empty
                              : Colors.white;
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getColorForStatus(status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: fillColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getIconForStatus(status),
                                color: fillColor == Colors.transparent
                                    ? Colors.black54
                                    : Colors.white,
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        // Compare date-only values so time-of-day doesn't affect the check
                        final today = DateTime.now();
                        final todayDate =
                            DateTime(today.year, today.month, today.day);
                        final dayDate = DateTime(day.year, day.month, day.day);
                        // Allow editing for today and past; block future dates
                        if (!dayDate.isAfter(todayDate)) {
                          _updateAttendance(student.id, day);
                        }
                      },
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

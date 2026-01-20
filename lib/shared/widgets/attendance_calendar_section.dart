import 'package:flutter/material.dart';
import 'month_dropdown.dart';
import 'line_calendar.dart';

class AttendanceCalendarSection extends StatefulWidget {
  const AttendanceCalendarSection({super.key});

  @override
  State<AttendanceCalendarSection> createState() =>
      _AttendanceCalendarSectionState();
}

class _AttendanceCalendarSectionState extends State<AttendanceCalendarSection> {
  // Default bulan saat ini
  String selectedMonthText = _monthToText(DateTime.now().month);

  // Tanggal yang dikirim ke LineCalendar
  DateTime selectedInitialDate = DateTime.now();

  static String _monthToText(int month) {
    const m = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return m[month - 1];
  }

  static int _textToMonth(String text) {
    const m = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return m.indexOf(text) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // MONTH DROPDOWN
        Center(
          child: MonthDropdown(
            initialMonth: selectedMonthText,
            onChanged: (monthText) {
              setState(() {
                selectedMonthText = monthText;

                // Ubah ke tanggal pertama bulan tsb
                int monthNum = _textToMonth(monthText);
                selectedInitialDate = DateTime(
                  DateTime.now().year,
                  monthNum,
                  1,
                );
              });
            },
          ),
        ),

        const SizedBox(height: 18),
        // LINE CALENDAR
        LineCalendar(
          initialDate: selectedInitialDate,
          onDateSelected: (date) {
            debugPrint("Tanggal dipilih: $date");
          },
        ),
      ],
    );
  }
}

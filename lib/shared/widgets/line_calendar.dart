import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class LineCalendar extends StatelessWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;

  const LineCalendar({super.key, this.initialDate, this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: FLineCalendar(
        initialSelection: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:forui/forui.dart';

// class LineCalendar extends StatelessWidget {
//   final DateTime? initialDate;
//   final Function(DateTime)? onDateSelected;

//   const LineCalendar({super.key, this.initialDate, this.onDateSelected});

//   @override
//   Widget build(BuildContext context) {
//     final DateTime today = DateTime.now();
//     final DateTime target = initialDate ?? today;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: FLineCalendar(
//         start: DateTime(2020),
//         end: DateTime(2050),

//         initialSelection: target,
//         initialScroll: target,
//         today: today,
//         toggleable: true,

//         onChange: (d) => onDateSelected?.call(d),

//         builder: (context, data, _) {
//           final isSelected = data.isSelection ?? false;
//           final isToday = data.isHighlight ?? false;

//           return Container(
//             padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: isSelected
//                   ? const Color(0xFF2E6CE4)
//                   : Colors.white.withOpacity(0.05),
//               border:
//                   isToday ? Border.all(color: Colors.yellow, width: 1.4) : null,
//             ),
//             child: Text(
//               data.date.day.toString(),
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isSelected
//                     ? Colors.white
//                     : isToday
//                         ? Colors.yellow
//                         : Colors.white.withOpacity(0.65),
//                 fontWeight:
//                     isSelected || isToday ? FontWeight.bold : FontWeight.w500,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

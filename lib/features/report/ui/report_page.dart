import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home/ui/home_page.dart';
import 'package:forui/forui.dart';
import '../../../shared/widgets/app_header.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    // Mock Data Grouped (Similar to AttendanceHistoryPage)
    final historyData = [
      {
        "date": DateTime.now(),
        "activities": [
          RecentActivity(
            time: "09:00 AM",
            location: "Office Entrance",
            imageUrl: "https://picsum.photos/200?1",
            description: "Check In",
          ),
          RecentActivity(
            time: "05:00 PM",
            location: "Office Exit",
            imageUrl: "https://picsum.photos/200?2",
            description: "Check Out",
          ),
        ],
      },
      {
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "activities": [
          RecentActivity(
            time: "08:55 AM",
            location: "Office Entrance",
            imageUrl: "https://picsum.photos/200?3",
            description: "Check In",
          ),
          RecentActivity(
            time: "05:10 PM",
            location: "Office Exit",
            imageUrl: "https://picsum.photos/200?4",
            description: "Check Out",
          ),
        ],
      },
      {
        "date": DateTime.now().subtract(const Duration(days: 2)),
        "activities": [
          RecentActivity(
            time: "09:12 AM",
            location: "Office Entrance",
            imageUrl: "https://picsum.photos/200?5",
            description: "Check In (Late)",
          ),
        ],
      },
      {
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "activities": [
          RecentActivity(
            time: "09:00 AM",
            location: "Office Entrance",
            imageUrl: "https://picsum.photos/200?1",
            description: "Check In",
          ),
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "My Reports",
              showAvatar: false,
              showBell: false,
              onBack: Navigator.canPop(context)
                  ? () => Navigator.pop(context)
                  : null,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Export Attendance",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Select date range to download your attendance history.",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 24),
                                // Date Range Picker Trigger
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "This Month",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FButton(
                                    onPress: () {},
                                    child: const Text("Download CSV"),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FButton(
                                    onPress: () {},
                                    // style: FButtonStyle.secondary,
                                    child: const Text("Download PDF"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "History",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // HISTORY LIST
                  // SliverPadding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   sliver: SliverList(
                  //     delegate: SliverChildBuilderDelegate((context, index) {
                  //       final group = historyData[index];
                  //       final date = group['date'] as DateTime;
                  //       final activities =
                  //           group['activities'] as List<RecentActivity>;

                  //       return Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           // DATE HEADER
                  //           Padding(
                  //             padding: const EdgeInsets.symmetric(vertical: 12),
                  //             child: Text(
                  //               DateFormat("EEEE, dd MMMM yyyy").format(date),
                  //               style: TextStyle(
                  //                 color: Colors.white.withValues(alpha: 0.6),
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w600,
                  //                 letterSpacing: 0.5,
                  //               ),
                  //             ),
                  //           ),
                  //           // LIST ITEMS
                  //           ...activities.map(
                  //             (activity) => Padding(
                  //               padding: const EdgeInsets.only(bottom: 12),
                  //               child: _HistoryItem(activity: activity),
                  //             ),
                  //           ),
                  //           const SizedBox(height: 8),
                  //         ],
                  //       );
                  //     }, childCount: historyData.length),
                  //   ),
                  // ),
                  // const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Use _buildRecentExportItem if needed, or remove if replacing with full history
}

class _HistoryItem extends StatelessWidget {
  final RecentActivity activity;

  const _HistoryItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xfffbfbff),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // TIME & INDICATOR
          Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xff0c202e),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xff5a64d6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // DASHED LINE SEPARATOR
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.location,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

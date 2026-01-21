import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/services/config_service.dart';
import '../../admin/bloc/admin_bloc.dart';
import '../../admin/bloc/admin_state.dart';
import '../../../shared/widgets/app_header.dart';

class AdminWorkingHoursPage extends StatefulWidget {
  const AdminWorkingHoursPage({super.key});

  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);
  static const kIconPrimary = Color(0xFF7C7FFF);

  @override
  State<AdminWorkingHoursPage> createState() => _AdminWorkingHoursPageState();
}

class _AdminWorkingHoursPageState extends State<AdminWorkingHoursPage> {
  bool _isLoading = false;
  String? _companyId;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _toleranceMinutes = 0; // Tolerance in minutes
  bool _applyToAll = true;
  final Set<String> _selectedUserIds = {};

  final ConfigService _configService = ConfigService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadInitialConfig();
  }

  Future<void> _loadInitialConfig() async {
    final bloc = context.read<AdminBloc>();
    _companyId = bloc.companyId;

    if (_companyId != null) {
      setState(() => _isLoading = true);
      try {
        final config = await _configService.getShiftConfig(_companyId!);
        setState(() {
          _startTime = _parseTime(config['start_time'] ?? '09:00');
          _endTime = _parseTime(config['end_time'] ?? '17:00');
          _toleranceMinutes = config['tolerance_time'] as int? ?? 0;
        });
      } catch (e) {
        debugPrint("Error loading shift config: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveChanges() async {
    if (_companyId == null) return;

    setState(() => _isLoading = true);
    try {
      final startStr = _formatTime(_startTime);
      final endStr = _formatTime(_endTime);

      if (_applyToAll) {
        // Update Global Config
        await _configService.updateShiftConfig(
          _companyId!,
          startStr,
          endStr,
          _toleranceMinutes,
        );
      } else {
        // Update Specific Users
        if (_selectedUserIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select at least one employee"),
            ),
          );
          return;
        }
        await _authService.batchUpdateUserShifts(
          _selectedUserIds.toList(),
          startStr,
          endStr,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Working hours updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving changes: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminWorkingHoursPage.kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Working Hours",
              showAvatar: false,
              showBell: false,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time Selection Container
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AdminWorkingHoursPage.kSurfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Shift Schedule",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AdminWorkingHoursPage.kTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _TimePickerRow(
                                  label: "Start Time",
                                  time: _startTime,
                                  onTap: () async {
                                    final t = await showTimePicker(
                                      context: context,
                                      initialTime: _startTime,
                                    );
                                    if (t != null) {
                                      setState(() => _startTime = t);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.white.withOpacity(0.05)),
                                const SizedBox(height: 16),
                                _TimePickerRow(
                                  label: "End Time",
                                  time: _endTime,
                                  onTap: () async {
                                    final t = await showTimePicker(
                                      context: context,
                                      initialTime: _endTime,
                                    );
                                    if (t != null) {
                                      setState(() => _endTime = t);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.white.withOpacity(0.05)),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Tolerance Time",
                                          style: TextStyle(
                                            color: AdminWorkingHoursPage
                                                .kTextSecondary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "$_toleranceMinutes min",
                                          style: const TextStyle(
                                            color: AdminWorkingHoursPage
                                                .kTextPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Slider(
                                      value: _toleranceMinutes.toDouble(),
                                      min: 0,
                                      max: 60,
                                      divisions: 12, // 5 min intervals
                                      activeColor:
                                          AdminWorkingHoursPage.kAccentColor,
                                      inactiveColor: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      label: "$_toleranceMinutes min",
                                      onChanged: (val) {
                                        setState(() {
                                          _toleranceMinutes = val.toInt();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Scope Selection
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AdminWorkingHoursPage.kSurfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                "Apply as Default (All Employees)",
                                style: TextStyle(
                                  color: AdminWorkingHoursPage.kTextPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: const Text(
                                "Updates the company's default working hours",
                                style: TextStyle(
                                  color: AdminWorkingHoursPage.kTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              value: _applyToAll,
                              activeThumbColor:
                                  AdminWorkingHoursPage.kAccentColor,
                              onChanged: (val) =>
                                  setState(() => _applyToAll = val),
                            ),
                          ),

                          if (!_applyToAll) ...[
                            const SizedBox(height: 24),
                            const Text(
                              "Select Employees",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AdminWorkingHoursPage.kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildEmployeeList(),
                          ],

                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AdminWorkingHoursPage.kAccentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final users = state.users;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            final isSelected = _selectedUserIds.contains(user.id);

            return Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminWorkingHoursPage.kAccentColor.withValues(alpha: 0.1)
                    : AdminWorkingHoursPage.kSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AdminWorkingHoursPage.kAccentColor
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: CheckboxListTile(
                value: isSelected,
                activeColor: AdminWorkingHoursPage.kAccentColor,
                checkColor: Colors.white,
                title: Text(
                  user.name,
                  style: const TextStyle(
                    color: AdminWorkingHoursPage.kTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  user.role,
                  style: TextStyle(
                    color: AdminWorkingHoursPage.kTextSecondary,
                    fontSize: 12,
                  ),
                ),
                secondary: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                  radius: 18,
                ),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedUserIds.add(user.id);
                    } else {
                      _selectedUserIds.remove(user.id);
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AdminWorkingHoursPage.kTextSecondary,
              fontSize: 15,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    color: AdminWorkingHoursPage.kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time_rounded,
                  color: AdminWorkingHoursPage.kIconPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

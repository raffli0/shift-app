import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/services/config_service.dart';
import '../../admin/bloc/admin_bloc.dart';
import '../../admin/bloc/admin_state.dart';
import '../models/admin_models.dart';
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
  final ConfigService _configService = ConfigService();
  final AuthService _authService = AuthService();
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _companyId = context.read<AdminBloc>().companyId;
  }

  void _showShiftDialog({Shift? shift}) {
    final adminBloc = context.read<AdminBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminWorkingHoursPage.kBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: adminBloc,
        child: _ShiftEditor(
          companyId: _companyId!,
          existingShift: shift,
          configService: _configService,
          authService: _authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_companyId == null) {
      return const Scaffold(body: Center(child: Text("Company ID not found")));
    }

    return Scaffold(
      backgroundColor: AdminWorkingHoursPage.kBgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShiftDialog(),
        backgroundColor: AdminWorkingHoursPage.kAccentColor,
        label: const Text(
          "Add Shift",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Shift Management",
              showAvatar: false,
              showBell: false,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _configService.streamShifts(_companyId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 48,
                            color: AdminWorkingHoursPage.kTextSecondary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No shifts found",
                            style: TextStyle(
                              color: AdminWorkingHoursPage.kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showShiftDialog(),
                            child: const Text(
                              "Create your first shift",
                              style: TextStyle(
                                color: AdminWorkingHoursPage.kAccentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final shifts = snapshot.data!
                      .map((data) => Shift.fromMap(data))
                      .toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: shifts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final shift = shifts[index];
                      return _ShiftCard(
                        shift: shift,
                        onTap: () => _showShiftDialog(shift: shift),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor:
                                  AdminWorkingHoursPage.kSurfaceColor,
                              title: const Text(
                                'Delete Shift?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'Are you sure you want to delete "${shift.name}"?',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(ctx, false),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _configService.deleteShift(
                              _companyId!,
                              shift.id,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final Shift shift;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ShiftCard({
    required this.shift,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminWorkingHoursPage.kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        title: Text(
          shift.name,
          style: const TextStyle(
            color: AdminWorkingHoursPage.kTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AdminWorkingHoursPage.kTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                "${shift.startTime} - ${shift.endTime}",
                style: const TextStyle(
                  color: AdminWorkingHoursPage.kTextSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: AdminWorkingHoursPage.kTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                "+${shift.toleranceMinutes} min",
                style: const TextStyle(
                  color: AdminWorkingHoursPage.kTextSecondary,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _ShiftEditor extends StatefulWidget {
  final String companyId;
  final Shift? existingShift;
  final ConfigService configService;
  final AuthService authService;

  const _ShiftEditor({
    required this.companyId,
    required this.existingShift,
    required this.configService,
    required this.authService,
  });

  @override
  State<_ShiftEditor> createState() => _ShiftEditorState();
}

class _ShiftEditorState extends State<_ShiftEditor> {
  late TextEditingController _nameCtrl;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _toleranceMinutes = 0;
  bool _isLoading = false;

  // Selection
  final Set<String> _selectedUserIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingShift?.name ?? '');
    if (widget.existingShift != null) {
      _startTime = _parseTime(widget.existingShift!.startTime);
      _endTime = _parseTime(widget.existingShift!.endTime);
      _toleranceMinutes = widget.existingShift!.toleranceMinutes;
    }
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Shift name is required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final shiftData = {
        'name': _nameCtrl.text,
        'start_time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
        'tolerance_time': _toleranceMinutes,
      };

      if (widget.existingShift != null) {
        await widget.configService.updateShift(
          widget.companyId,
          widget.existingShift!.id,
          shiftData,
        );
      } else {
        await widget.configService.addShift(widget.companyId, shiftData);
      }

      // Apply to selected users
      if (_selectedUserIds.isNotEmpty) {
        await widget.authService.batchUpdateUserShifts(
          _selectedUserIds.toList(),
          _formatTime(_startTime),
          _formatTime(_endTime),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shift saved and applied to ${_selectedUserIds.length} employees',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift saved'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AdminWorkingHoursPage.kBgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingShift == null ? "New Shift" : "Edit Shift",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form
                  _buildSectionTitle("Shift Details"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AdminWorkingHoursPage.kSurfaceColor,
                      labelText: "Shift Name (e.g., Morning Shift)",
                      labelStyle: const TextStyle(
                        color: AdminWorkingHoursPage.kTextSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          "Start Time",
                          _startTime,
                          (t) => setState(() => _startTime = t),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker(
                          "End Time",
                          _endTime,
                          (t) => setState(() => _endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tolerance
                  _buildSectionTitle(
                    "Attendance Tolerance: $_toleranceMinutes min",
                  ),
                  Slider(
                    value: _toleranceMinutes.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 12,
                    activeColor: AdminWorkingHoursPage.kAccentColor,
                    inactiveColor: Colors.white10,
                    onChanged: (v) =>
                        setState(() => _toleranceMinutes = v.toInt()),
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // User Assignment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Assign to Employees"),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectAll = !_selectAll;
                            if (_selectAll) {
                              final users = context
                                  .read<AdminBloc>()
                                  .state
                                  .users;
                              _selectedUserIds.addAll(users.map((u) => u.id));
                            } else {
                              _selectedUserIds.clear();
                            }
                          });
                        },
                        child: Text(_selectAll ? "Unselect All" : "Select All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AdminWorkingHoursPage.kSurfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BlocBuilder<AdminBloc, AdminState>(
                      builder: (context, state) {
                        if (state.users.isEmpty)
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No users found",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.users.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: Colors.white10),
                          itemBuilder: (ctx, i) {
                            final user = state.users[i];
                            final isSelected = _selectedUserIds.contains(
                              user.id,
                            );
                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: AdminWorkingHoursPage.kAccentColor,
                              checkColor: Colors.white,
                              title: Text(
                                user.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                user.role,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              secondary: CircleAvatar(
                                backgroundImage: NetworkImage(user.imageUrl),
                                radius: 16,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  if (v == true)
                                    _selectedUserIds.add(user.id);
                                  else
                                    _selectedUserIds.remove(user.id);
                                  _selectAll =
                                      _selectedUserIds.length ==
                                      state.users.length;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminWorkingHoursPage.kAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Save Shift",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AdminWorkingHoursPage.kTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: time);
            if (t != null) onChanged(t);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AdminWorkingHoursPage.kSurfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.access_time,
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift/shared/widgets/app_dialog.dart';
import 'package:shift/shared/widgets/app_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shift/features/auth/services/auth_service.dart';
import 'package:shift/features/leave/services/leave_service.dart';
import 'package:shift/features/auth/models/user_model.dart';
import 'package:shift/features/auth/bloc/auth_bloc.dart';

class NewLeaveFormPage extends StatefulWidget {
  const NewLeaveFormPage({super.key});

  @override
  State<NewLeaveFormPage> createState() => _NewLeaveFormPageState();
}

class _NewLeaveFormPageState extends State<NewLeaveFormPage> {
  final _reasonController = TextEditingController();
  final _leaveService = LeaveService();
  final _authService = AuthService();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'Sick Leave';
  bool _isLoading = false;

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  final _types = ['Sick Leave', 'Annual Leave', 'Unpaid Leave', 'Other'];

  Future<void> _submitRequest() async {
    if (_startDate == null ||
        _endDate == null ||
        _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Try to get user from AuthBloc state first if available
      UserModel? user;
      try {
        final authBloc = context.read<AuthBloc>();
        user = authBloc.state.user;
      } catch (_) {}

      // Fallback to service if Bloc not providing user
      user ??= await _authService.checkAuthStatus();

      if (user == null) {
        // Ultimate fallback: Firebase User (if Bloc/Firestore missing)
        final firebaseUser = _authService.currentUser;
        if (firebaseUser == null) throw Exception("User not authenticated");
        user = UserModel(
          id: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? "User",
          email: firebaseUser.email ?? "",
          role: "employee",
        );
      }

      await _leaveService.submitLeaveRequest(
        user: user,
        type: _selectedType,
        reason: _reasonController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        companyId: user.companyId,
      );

      if (mounted) {
        await AppDialog.showSuccess(
          context: context,
          title: "Leave request sent",
          message: "Your request is waiting for approval.",
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Strip "Exception: " prefix for cleaner display
        final message = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: "Request Leave", showAvatar: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "New Leave Request",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Fill in the details below to submit your leave request.",
                        style: TextStyle(fontSize: 14, color: kTextSecondary),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Leave Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: kSurfaceColor,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedType,
                                isExpanded: true,
                                dropdownColor: kSurfaceColor,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 16,
                                ),
                                items: _types.map((t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        color: kTextPrimary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedType = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _DateInput(
                              label: "Start Date",
                              value: _startDate,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _startDate = date);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DateInput(
                              label: "End Date",
                              value: _endDate,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: _startDate ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _endDate = date);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: "Reason",
                          labelStyle: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: "Enter reason for leave...",
                          hintStyle: const TextStyle(color: kTextSecondary),
                          filled: true,
                          fillColor: kSurfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kAccentColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _isLoading ? null : _submitRequest,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isLoading ? Colors.grey : kAccentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Submit Request",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateInput({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _NewLeaveFormPageState.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: _NewLeaveFormPageState.kSurfaceColor,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: _NewLeaveFormPageState.kTextSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat("MMM dd, yyyy").format(value!)
                        : "Select Date",
                    style: TextStyle(
                      color: value != null
                          ? _NewLeaveFormPageState.kTextPrimary
                          : _NewLeaveFormPageState.kTextSecondary,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

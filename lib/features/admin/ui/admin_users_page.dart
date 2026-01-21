import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../bloc/admin_event.dart'; // Import AdminEvent
import '../models/admin_models.dart'; // Import AdminUser
import '../../../shared/widgets/app_header.dart';
import 'admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F13), // Match new dark theme
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        backgroundColor: const Color(0xff7C7FFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "User Management",
              showAvatar: true,
              showBell: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff151821), // Dark surface
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search users by name or email...",
                            hintStyle: const TextStyle(
                              color: Color(0xFF9AA0AA),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF9AA0AA),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<AdminBloc, AdminState>(
                          builder: (context, state) {
                            // Filter logic
                            final filteredUsers = state.users.where((user) {
                              final name = user.name.toLowerCase();
                              final email = user.email.toLowerCase();
                              return name.contains(_searchQuery) ||
                                  email.contains(_searchQuery);
                            }).toList();

                            if (filteredUsers.isEmpty) {
                              return Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? "No users found."
                                      : "No matches for '$_searchQuery'",
                                  style: const TextStyle(
                                    color: Color(0xFF9AA0AA),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _UserListItem(
                                  user: user,
                                  onEdit: () =>
                                      _showUserForm(context, user: user),
                                  onDelete: () => _confirmDelete(context, user),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showUserForm(BuildContext context, {AdminUser? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (btmContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(btmContext).viewInsets.bottom,
        ),
        child: _UserForm(
          user: user,
          onSave: (newUser) {
            if (user == null) {
              context.read<AdminBloc>().add(AdminUserAdded(newUser));
            } else {
              context.read<AdminBloc>().add(AdminUserUpdated(newUser));
            }
            Navigator.pop(btmContext);
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete ${user.name}?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<AdminBloc>().add(AdminUserDeleted(user));
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserListItem({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F13), // Distinct dark card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final adminBloc = context.read<AdminBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: adminBloc,
                  child: AdminUserDetailPage(user: user),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FAvatar(
                  fallback: Text(user.name.substring(0, 2).toUpperCase()),
                  image: NetworkImage(user.imageUrl),
                  // style: FAvatarStyle.secondary, // Assuming ForUI has styles or default is fine
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFFEDEDED),
                        ),
                      ),
                      Text(
                        "${user.role} • ${user.email}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA0AA),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: user.isDestructive
                        ? const Color(0xFFE06C75).withOpacity(0.2)
                        : const Color(0xFF4CAF8C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.status,
                    style: TextStyle(
                      color: user.isDestructive
                          ? const Color(0xFFE06C75)
                          : const Color(0xFF4CAF8C),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF8A8F98)),
                  color: const Color(0xFF151821),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Color(0xFFE06C75)),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserForm extends StatefulWidget {
  final AdminUser? user;
  final Function(AdminUser) onSave;

  const _UserForm({this.user, required this.onSave});

  @override
  State<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<_UserForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _deptController;
  String _status = "Active";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? "");
    _emailController = TextEditingController(text: widget.user?.email ?? "");
    _roleController = TextEditingController(text: widget.user?.role ?? "");
    _deptController = TextEditingController(
      text: widget.user?.department ?? "",
    );
    _status = widget.user?.status ?? "Active";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.user == null ? "Add User" : "Edit User",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            FTextFormField(
              label: const Text("Name"),
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            FTextFormField(
              label: const Text("Email"),
              controller: _emailController,
              enabled:
                  widget.user ==
                  null, // Only editable for new users for linked Logic?
              // Actually, admin should be able to edit. But key is email for linking.
              // Let's allow edit.
            ),
            const SizedBox(height: 16),
            FTextFormField(
              label: const Text("Role"),
              controller: _roleController,
            ),
            const SizedBox(height: 16),
            FTextFormField(
              label: const Text("Department"),
              controller: _deptController,
            ),
            const SizedBox(height: 16),
            // Simple Status Dropdown (Simulated)
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: "Status"),
              items: [
                "Active",
                "Inactive",
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 24),
            FButton(
              onPress: () {
                final newUser = AdminUser(
                  id:
                      widget.user?.id ??
                      "", // Preserve ID if editing, empty if new
                  name: _nameController.text,
                  email: _emailController.text,
                  role: _roleController.text,
                  department: _deptController.text,
                  status: _status,
                  imageUrl:
                      widget.user?.imageUrl ??
                      "https://i.pravatar.cc/150?u=${_nameController.text}",
                  isDestructive: _status == "Inactive",
                );
                widget.onSave(newUser);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

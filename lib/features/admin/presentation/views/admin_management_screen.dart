import 'package:flutter/material.dart';
import 'package:trustseal_app/core/constants/app_constants.dart';
import '../../domain/entities/admin_entity.dart';
import '../../data/services/admin_service.dart';

class AdminManagementScreen extends StatefulWidget {
  final AdminService service;

  const AdminManagementScreen({super.key, required this.service});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<Admin> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final admins = await widget.service.getAllAdmins();
      setState(() {
        _admins = admins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading admins: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Management'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAdminDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAdmins),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAdmins,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                itemCount: _admins.length,
                itemBuilder: (context, index) {
                  final admin = _admins[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingM,
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryColor,
                          child: Text(
                            admin.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          admin.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(admin.email),
                            const SizedBox(height: AppConstants.paddingS),
                            Row(
                              children: [
                                _buildRoleChip(admin.role),
                                const SizedBox(width: AppConstants.paddingS),
                                _buildStatusChip(admin.isActive),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'deactivate':
                                _deactivateAdmin(admin);
                                break;
                              case 'edit':
                                _showEditAdminDialog(admin);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'deactivate',
                              child: Text(
                                admin.isActive ? 'Deactivate' : 'Activate',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildRoleChip(AdminRole role) {
    Color color;
    String label;

    switch (role) {
      case AdminRole.superAdmin:
        color = Colors.red;
        label = 'Super Admin';
        break;
      case AdminRole.reviewer:
        color = Colors.blue;
        label = 'Reviewer';
        break;
      case AdminRole.auditor:
        color = Colors.green;
        label = 'Auditor';
        break;
      case AdminRole.support:
        color = Colors.orange;
        label = 'Support';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    AdminRole selectedRole = AdminRole.reviewer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              DropdownButtonFormField<AdminRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: AdminRole.values.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  try {
                    await widget.service.createAdmin(
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin created successfully'),
                        ),
                      );
                      _loadAdmins();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating admin: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminDialog(Admin admin) {
    final nameController = TextEditingController(text: admin.name);
    final emailController = TextEditingController(text: admin.email);
    AdminRole selectedRole = admin.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              DropdownButtonFormField<AdminRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: AdminRole.values.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedAdmin = Admin(
                    id: admin.id,
                    name: nameController.text,
                    email: emailController.text,
                    role: selectedRole,
                    createdAt: admin.createdAt,
                    lastLoginAt: admin.lastLoginAt,
                    isActive: admin.isActive,
                  );

                  await widget.service.updateAdmin(updatedAdmin);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Admin updated successfully'),
                      ),
                    );
                    _loadAdmins();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating admin: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deactivateAdmin(Admin admin) async {
    try {
      await widget.service.deactivateAdmin(admin.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Admin ${admin.isActive ? 'deactivated' : 'activated'}',
            ),
          ),
        );
        _loadAdmins();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating admin: $e')));
      }
    }
  }
}

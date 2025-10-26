import 'package:flutter/material.dart';
import 'package:trustseal_app/core/widgets/role_guard.dart';
import '../../data/services/admin_service.dart';
import 'admin_dashboard_screen.dart';
import 'application_review_screen.dart';
import 'admin_management_screen.dart';
import 'vault_management_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  final AdminService service;

  const AdminNavigationScreen({super.key, required this.service});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboardScreen(service: widget.service),
      ApplicationReviewScreen(service: widget.service),
      AdminManagementScreen(service: widget.service),
      const VaultManagementScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: ['admin'],
      child: Scaffold(
        drawer: const RoleBasedNavigation(),
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              activeIcon: Icon(Icons.rate_review),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Management',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security_outlined),
              activeIcon: Icon(Icons.security),
              label: 'Vault',
            ),
          ],
        ),
      ),
      fallback: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to access the Admin Panel.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trustseal_app/core/widgets/role_guard.dart';
import 'package:trustseal_app/features/business_owners/data/services/business_owners_service.dart';
import 'business_owners_dashboard_screen.dart';
import 'project_application_form_screen.dart';
import 'vault_upload_screen.dart';

class BusinessOwnersNavigationScreen extends StatefulWidget {
  final BusinessOwnersService service;

  const BusinessOwnersNavigationScreen({super.key, required this.service});

  @override
  State<BusinessOwnersNavigationScreen> createState() =>
      _BusinessOwnersNavigationScreenState();
}

class _BusinessOwnersNavigationScreenState
    extends State<BusinessOwnersNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BusinessOwnersDashboardScreen(service: widget.service),
      ProjectApplicationFormScreen(service: widget.service),
      const VaultUploadScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: ['business'],
      child: Scaffold(
        drawer: const RoleBasedNavigation(),
        appBar: AppBar(
          title: const Text('Business Dashboard'),
          backgroundColor: const Color(0xFF3B82F6),
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
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'New Application',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security_outlined),
              activeIcon: Icon(Icons.security),
              label: 'Secure Vault',
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
                'You do not have permission to access the Business Dashboard.',
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

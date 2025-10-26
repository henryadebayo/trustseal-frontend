import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustseal_app/core/navigation/route_handler.dart';
import 'package:trustseal_app/features/users/presentation/views/home_screen.dart';
import 'package:trustseal_app/features/business_owners/data/storage/local_business_owners_storage.dart';
import 'package:trustseal_app/features/business_owners/data/services/business_owners_service.dart';
import 'package:trustseal_app/features/business_owners/presentation/views/business_owners_navigation_screen.dart';
import 'package:trustseal_app/features/admin/data/storage/local_admin_storage.dart';
import 'package:trustseal_app/features/admin/data/services/admin_service.dart';
import 'package:trustseal_app/features/admin/presentation/views/admin_navigation_screen.dart';
import 'package:trustseal_app/core/services/api_service.dart';
import 'package:trustseal_app/core/services/auth_service.dart';
import 'package:trustseal_app/core/services/business_owner_service.dart';
import 'package:trustseal_app/core/services/blockdag_service.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';
import 'package:trustseal_app/core/widgets/protected_route.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService.instance.initialize();

  // Initialize business owners storage
  final businessStorage = LocalBusinessOwnersStorage();
  await businessStorage.initialize();

  // Initialize business owners service
  final businessService = BusinessOwnersService(businessStorage);
  await businessService.initialize();

  // Initialize admin storage
  final adminStorage = LocalAdminStorage(businessService);
  await adminStorage.initialize();

  // Initialize admin service
  final adminService = AdminService(adminStorage);
  await adminService.initialize();

  // Initialize API services
  final authService = AuthService();
  final businessOwnerApiService = BusinessOwnerService();
  final blockDAGService = BlockDAGService();

  runApp(
    TrustSealApp(
      businessService: businessService,
      adminService: adminService,
      authService: authService,
      businessOwnerApiService: businessOwnerApiService,
      blockDAGService: blockDAGService,
    ),
  );
}

class TrustSealApp extends StatelessWidget {
  final BusinessOwnersService businessService;
  final AdminService adminService;
  final AuthService authService;
  final BusinessOwnerService businessOwnerApiService;
  final BlockDAGService blockDAGService;

  const TrustSealApp({
    super.key,
    required this.businessService,
    required this.adminService,
    required this.authService,
    required this.businessOwnerApiService,
    required this.blockDAGService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
              vertical: AppConstants.paddingM,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          filled: true,
          fillColor: AppConstants.surfaceColor,
        ),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        useMaterial3: true,
      ),
      home: const AuthAwareLandingPage(),
      onGenerateRoute: TrustSealRouteHandler.generateRoute,
      routes: {
        '/home': (context) => DashboardWrapper(
          userType: AuthManager.user,
          child: HomeScreen(
            businessService: businessService,
            adminService: adminService,
          ),
        ),
        '/admin': (context) => DashboardWrapper(
          userType: AuthManager.admin,
          child: ProtectedRoute(
            allowedRoles: [AuthManager.admin],
            child: AdminNavigationScreen(service: adminService),
          ),
        ),
        '/business': (context) => DashboardWrapper(
          userType: AuthManager.business,
          child: ProtectedRoute(
            allowedRoles: [AuthManager.business],
            child: BusinessOwnersNavigationScreen(service: businessService),
          ),
        ),
      },
    );
  }
}

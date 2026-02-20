import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/departments_screen.dart';
import 'screens/queue_position_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ai_arrival_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Constants
class LineMuktStyle {
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textGrey = Color(0xFF64748B);
  static const Color bgGrey = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQueue',
      theme: ThemeData(
        primaryColor: Color(0xFF00C9A7),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/departments': (context) => HomeScreen(),
        '/queue': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C9A7)),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return HomeScreen();
        }

        return LoginScreen();
      },
    );
  }

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DepartmentsScreen(),
    const QueuePositionScreen(isDarkMode: false),
    const AiArrivalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LineMuktStyle.bgGrey,
      body: Row(
        children: [
          // Using your sidebar code
          LineMuktSidebar(
            currentIndex: _selectedIndex,
            onChanged: (index) => setState(() => _selectedIndex = index),
          ),
          // Smooth content transition
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

// Your Sidebar Code (unchanged)
class LineMuktSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const LineMuktSidebar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: LineMuktStyle.border)),
      ),
      child: Column(
        children: [
          _buildBranding(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SidebarItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    isActive: currentIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  _SidebarItem(
                    icon: Icons.domain_rounded,
                    label: 'Departments',
                    isActive: currentIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                  _SidebarItem(
                    icon: Icons.group_rounded,
                    label: 'My Queue',
                    isActive: currentIndex == 2,
                    onTap: () => onChanged(2),
                  ),
                  _SidebarItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Arrival',
                    isActive: currentIndex == 3,
                    onTap: () => onChanged(3),
                  ),
                ],
              ),
            ),
          ),
          _buildUserCard(context),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0052CC)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10)],
            ),
            child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LineMukt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LineMuktStyle.textDark)),
              Text('HEALTHCARE', style: TextStyle(fontSize: 10, color: LineMuktStyle.textLight, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildUserCard(BuildContext context) {
  return FutureBuilder<Map<String, String>>(
    future: _getUserInfo(),
    builder: (context, snapshot) {
      final userName = snapshot.data?['fullName'] ?? 'User';
      // Remove this line - not needed
      // final userEmail = snapshot.data?['email'] ?? 'user@example.com';
      final userInitials = userName.isNotEmpty
          ? userName.split(' ').map((e) => e[0]).join().toUpperCase()
          : 'U';

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LineMuktStyle.bgGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LineMuktStyle.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              userInitials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            userName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: LineMuktStyle.textDark,
            ),
          ),
          subtitle: GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all data including token
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(fontSize: 11, color: LineMuktStyle.textLight),
            ),
          ),
        ),
      );
    },
  );
}

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString('fullName') ?? 'User',
      'email': prefs.getString('email') ?? 'user@example.com',
      'phone': prefs.getString('phone') ?? '',
    };
  }
}

// Individual Nav Item with built-in Hover & Animation
class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFFEFF6FF)
                  : (_isHovered ? LineMuktStyle.bgGrey : Colors.transparent),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: widget.isActive ? 24 : 0,
                  decoration: BoxDecoration(
                    color: LineMuktStyle.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  widget.icon,
                  color: widget.isActive ? LineMuktStyle.primaryBlue : LineMuktStyle.textLight,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isActive ? LineMuktStyle.primaryBlue : LineMuktStyle.textGrey,
                    fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
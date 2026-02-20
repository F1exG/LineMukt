import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'maps_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String nepalTime;
  late Timer timer;
  late Timer dataRefreshTimer;
  
  // Real-time data from API
  int totalQueuesJoined = 0;
  String averageWaitTime = '0 min';
  int completedVisits = 0;
  List<Map<String, dynamic>> recentActivities = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _updateNepalTime();
    _fetchUserDashboardData(); // Fetch initial data
    
    // Update Nepal time every second
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateNepalTime();
    });
    
    // Refresh dashboard data every 30 seconds
    dataRefreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _fetchUserDashboardData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    dataRefreshTimer.cancel();
    super.dispose();
  }

  void _updateNepalTime() {
    // Nepal is UTC+5:45
    final now = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 45));
    setState(() {
      nepalTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  // Fetch real-time data from backend
  Future<void> _fetchUserDashboardData() async {
    try {
      // Get token from secure storage (or localStorage for web)
      String? token = html.window.localStorage['auth_token'];
      
      if (token == null) {
        setState(() {
          errorMessage = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      // Fetch dashboard data from backend
      final response = await http.get(
        Uri.parse('http://192.168.1.79:5000/api/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          totalQueuesJoined = data['total_queues_joined'] ?? 0;
          averageWaitTime = data['average_wait_time'] ?? '0 min';
          completedVisits = data['completed_visits'] ?? 0;
          recentActivities = List<Map<String, dynamic>>.from(data['recent_activities'] ?? []);
          isLoading = false;
          errorMessage = null;
        });
        
        print('✅ Dashboard data fetched successfully');
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Session expired. Please login again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load dashboard data';
          isLoading = false;
        });
        print('❌ Error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timeout. Please check your connection.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
      print('❌ Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Welcome back! Here\'s your health summary.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // ✅ NEPAL TIME DISPLAY
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF00C9A7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF00C9A7).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Nepal Time',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        nepalTime,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C9A7),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            
            // ✅ ERROR MESSAGE DISPLAY
            if (errorMessage != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (errorMessage != null) SizedBox(height: 20),
            
            // ✅ LOADING STATE
            if (isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
                ),
              )
            else
              // Stats Cards - NOW WITH REAL DATA
              Row(
                children: [
                  _buildStatCard('Total Queues Joined', totalQueuesJoined.toString(), Color(0xFF00C9A7)),
                  SizedBox(width: 20),
                  _buildStatCard('Average Wait Time', averageWaitTime, Color(0xFF0066FF)),
                  SizedBox(width: 20),
                  _buildStatCard('Completed Visits', completedVisits.toString(), Color(0xFFFF6B6B)),
                ],
              ),
            
            SizedBox(height: 30),
            
            // Recent Activity - NOW WITH REAL DATA FROM API
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (recentActivities.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...recentActivities.asMap().entries.map((entry) {
                      int index = entry.key;
                      var activity = entry.value;
                      
                      return Column(
                        children: [
                          _buildActivityItem(
                            activity['department_name'] ?? 'Unknown',
                            activity['status'] ?? 'N/A',
                            activity['time_ago'] ?? 'Just now',
                            activity['emoji'] ?? '🏥',
                          ),
                          if (index < recentActivities.length - 1) Divider(),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Quick Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 20),
                 Row(
  children: [
    _buildActionButton('View Queue', Icons.visibility, Color(0xFF0066FF)),
    SizedBox(width: 15),
    _buildActionButton('Find Hospitals', Icons.location_on, Color(0xFF9C27B0), onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapsScreen()),
      );
    }),
    SizedBox(width: 15),
    _buildActionButton('Service Fees', Icons.description, Color(0xFFFF6B6B), onTap: () async {
      final uri = Uri.parse('https://csh.gov.np/pages/service-fees-48/');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open Service Fees page.')),
          );
        }
      }
    }),
  ],
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.trending_up, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, String icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 28)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

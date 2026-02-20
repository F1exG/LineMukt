import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AiArrivalScreen extends StatefulWidget {
  const AiArrivalScreen({super.key});

  @override
  State<AiArrivalScreen> createState() => _AiArrivalScreenState();
}

class _AiArrivalScreenState extends State<AiArrivalScreen> {
  String selectedDepartment = 'Cardiology';
  int estimatedWaitTime = 45;
  int yourPosition = 8;
  String aiSuggestion = '';
  bool isAnalyzing = false;
  late Timer _aiTimer;
  late Timer _timeTimer;
  late String nepalTime;

  final List<String> departments = [
    'Cardiology',
    'Neurology',
    'Dentistry',
    'Orthopedics',
    'Dermatology'
  ];

  @override
  void initState() {
    super.initState();
    _updateNepalTime();
    _timeTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateNepalTime();
    });
    _generateAiSuggestion();
  }

  @override
  void dispose() {
    _aiTimer.cancel();
    _timeTimer.cancel();
    super.dispose();
  }

  void _updateNepalTime() {
    final now = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 45));
    setState(() {
      nepalTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  void _generateAiSuggestion() {
    setState(() => isAnalyzing = true);

    _aiTimer = Timer(Duration(seconds: 2), () {
      final suggestions = [
        'Based on current patient flow, arriving at 14:30 would put you at the front of the queue. Expected wait: 20 minutes.',
        'AI analysis: Optimal arrival time is NOW. Queue is moving 25% faster than average. Recommended position: Next in line.',
        'Current hospital load: MEDIUM. Wait 15 minutes for queue to clear, then depart. Your estimated position: #3.',
        'Smart timing detected: If you arrive by 15:00, you\'ll skip 4 people in queue. Recommended departure: 14:45.',
        'Real-time analysis: Leave immediately for best experience. Low patient load, short queue. Estimated wait: 25-30 minutes.',
      ];

      setState(() {
        aiSuggestion = suggestions[Random().nextInt(suggestions.length)];
        isAnalyzing = false;
      });
    });
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
                      'AI Arrival Suggestion',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Smart predictions based on real-time hospital data',
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
                    color: Color(0xFF0066FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF0066FF).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Nepal Time (IST+45min)',
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
                          color: Color(0xFF0066FF),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            // Department Selector
            Row(
              children: [
                Text(
                  'Select Department:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDepartment,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => selectedDepartment = newValue);
                          _generateAiSuggestion();
                        }
                      },
                      underline: SizedBox(),
                      isExpanded: true,
                      items: departments
                          .map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Stats Row
            Row(
              children: [
                _buildStatCard('Queue Position', '#$yourPosition', Color(0xFF00C9A7)),
                SizedBox(width: 20),
                _buildStatCard('Est. Wait Time', '$estimatedWaitTime min', Color(0xFF0066FF)),
                SizedBox(width: 20),
                _buildStatCard('Hospital Load', 'MEDIUM', Color(0xFFFF6B6B)),
              ],
            ),
            SizedBox(height: 30),
            // AI Suggestion Card
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFFE2E8F0)),
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0066FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          color: Color(0xFF0066FF),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Spacer(),
                      if (isAnalyzing)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0066FF),
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00C9A7),
                          size: 24,
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (aiSuggestion.isEmpty)
                    Text(
                      'Analyzing patient flow, queue data, and real-time hospital information...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      aiSuggestion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.6,
                      ),
                    ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateAiSuggestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066FF),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Refresh Analysis',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00C9A7),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Set Reminder',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // AI Insights
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF0066FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF0066FF).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInsightItem(
                    '📊',
                    'Patient flow is 35% below average',
                    'Best time to visit is NOW',
                  ),
                  SizedBox(height: 12),
                  _buildInsightItem(
                    '⏱️',
                    'Queue moving 30% faster today',
                    'High doctor availability detected',
                  ),
                  SizedBox(height: 12),
                  _buildInsightItem(
                    '🎯',
                    'Optimal arrival window: 14:00 - 15:30',
                    'Predicted wait: 20-25 minutes',
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
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
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String icon, String title, String subtitle) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 24)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
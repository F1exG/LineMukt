import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.79:5000/api';

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      print('Register Response: ${response.statusCode}');
      print('Register Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', fullName);
        await prefs.setString('email', email);
        await prefs.setString('phone', phone);
        
        return {
          'success': true,
          'message': 'Registration successful',
          'data': data,
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          String errorMsg = 'Registration failed';
          
          if (data is Map) {
            if (data.containsKey('detail')) {
              final detail = data['detail'];
              if (detail is List) {
                errorMsg = detail.isNotEmpty ? detail[0]['msg'] ?? 'Registration failed' : 'Registration failed';
              } else if (detail is String) {
                errorMsg = detail;
              }
            }
          }
          
          return {
            'success': false,
            'message': errorMsg,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Registration failed: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final token = data['token'];
        
        if (token == null) {
          return {
            'success': false,
            'message': 'No token in response',
          };
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        // ✅ Save user info from response if available
        if (data.containsKey('full_name')) {
          await prefs.setString('fullName', data['full_name']);
        }
        if (data.containsKey('email')) {
          await prefs.setString('email', data['email']);
        }
        if (data.containsKey('phone')) {
          await prefs.setString('phone', data['phone']);
        }
        
        print('✅ Token saved: $token');
        
        return {
          'success': true,
          'message': 'Login successful',
          'token': token,
          'data': data,
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          String errorMsg = 'Login failed';
          
          if (data is Map) {
            if (data.containsKey('detail')) {
              final detail = data['detail'];
              if (detail is List) {
                errorMsg = detail.isNotEmpty ? detail[0]['msg'] ?? 'Login failed' : 'Login failed';
              } else if (detail is String) {
                errorMsg = detail;
              }
            }
          }
          
          return {
            'success': false,
            'message': errorMsg,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Login failed: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/departments'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Departments Response: ${response.statusCode}');
      print('Departments Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((dept) {
          return {
            'id': dept['id'],
            'name': dept['name'],
            'description': dept['description'],
            'icon': dept['icon'] ?? '🏥',
          };
        }).toList();
      } else {
        throw 'Failed to load departments';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  static Future<Map<String, dynamic>> joinQueue({
    required int departmentId,
    required int estimatedWait,
    required int confidence,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔍 Retrieved token: $token');

      if (token == null) {
        print('❌ No token found!');
        return {
          'success': false,
          'message': 'Not authenticated. Please login first.',
        };
      }

      print('📤 Sending request with Authorization: Bearer $token');

      final response = await http.post(
        Uri.parse('$baseUrl/queue/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'department_id': departmentId,
          'estimated_wait': estimatedWait,
          'confidence': confidence,
        }),
      );

      print('Join Queue Response: ${response.statusCode}');
      print('Join Queue Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Queue joined',
          'token': data['token'],
          'position': data['position'],
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          String errorMsg = 'Failed to join queue';
          
          if (data is Map) {
            if (data.containsKey('detail')) {
              final detail = data['detail'];
              if (detail is List) {
                errorMsg = detail.isNotEmpty ? detail[0]['msg'] ?? 'Failed to join queue' : 'Failed to join queue';
              } else if (detail is String) {
                errorMsg = detail;
              }
            }
          }
          
          return {
            'success': false,
            'message': errorMsg,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to join queue: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getQueuePosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/queue/position'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Queue Position Response: ${response.statusCode}');
      print('Queue Position Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'department': data['department'],
          'position': data['position'],
          'status': data['status'],
          'estimated_wait_time': data['estimated_wait_time'],
          'ai_confidence': data['ai_confidence'],
        };
      } else {
        return {
          'success': false,
          'message': 'Not in any queue',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
class AppConstants {
  // App Info
  static const String appName = 'LineMukt';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Queue Management System';
  
  // Default Values
  static const int defaultTokenNumber = 4000;
  static const double defaultCrowdDensity = 50.0;
  static const double defaultAIConfidence = 85.0;
  static const int defaultWaitTime = 15; // minutes
  
  // Animation Durations (milliseconds)
  static const int animationDurationShort = 300;
  static const int animationDurationMedium = 600;
  static const int animationDurationLong = 1000;
  
  // Time Constants
  static const int queueRefreshInterval = 5000; // 5 seconds
  static const int notificationDuration = 4000; // 4 seconds
  static const int tooltipDuration = 2000; // 2 seconds
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultCardRadius = 16.0;
  static const double defaultIconSize = 24.0;
  
  // Crowd Thresholds
  static const double lowCrowdThreshold = 33.0;
  static const double mediumCrowdThreshold = 66.0;
  static const double highCrowdThreshold = 100.0;
  
  // Wait Time Ranges (minutes)
  static const int minWaitTime = 5;
  static const int maxWaitTime = 120;
  static const int averageWaitTime = 15;
  
  // Department List
  static const List<String> departments = [
    'General OPD',
    'Orthopedic',
    'Cardiology',
    'Neurology',
    'Gynecology',
    'Pediatrics',
    'Dental',
    'Eye Care',
    'Emergency',
  ];

  // Department Icons (Emoji)
  static final Map<String, String> departmentIcons = {
    'General OPD': '👨‍⚕️',
    'Orthopedic': '🦴',
    'Cardiology': '❤️',
    'Neurology': '🧠',
    'Gynecology': '👶',
    'Pediatrics': '👧',
    'Dental': '🦷',
    'Eye Care': '👁️',
    'Emergency': '🚨',
  };

  // Priority Levels
  static const String priorityNormal = 'normal';
  static const String priorityUrgent = 'urgent';
  static const String priorityVIP = 'vip';

  // Status Types
  static const String statusWaiting = 'waiting';
  static const String statusServing = 'serving';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Notification Types
  static const String notificationTypeInfo = 'info';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeSuccess = 'success';
  static const String notificationTypeError = 'error';
  static const String notificationTypeAlert = 'alert';

  // API Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // milliseconds
  
  // Cache Configuration
  static const int cacheExpirationTime = 3600000; // 1 hour in milliseconds
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection error. Please check your internet.',
    'server_error': 'Server error. Please try again later.',
    'timeout_error': 'Request timeout. Please try again.',
    'invalid_token': 'Invalid token. Please get a new one.',
    'queue_full': 'Queue is full. Please try again later.',
    'invalid_input': 'Invalid input. Please check your data.',
    'unauthorized': 'Unauthorized access. Please login again.',
    'not_found': 'Resource not found.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'token_created': 'Token created successfully!',
    'queue_updated': 'Queue updated successfully!',
    'notification_sent': 'Notification sent!',
    'data_saved': 'Data saved successfully!',
    'operation_completed': 'Operation completed successfully!',
  };

  // Hospital Fee Categories
  static const List<String> feeCategories = [
    'OPD Consultation',
    'Specialist Consultation',
    'Lab Tests',
    'Imaging (X-ray, Ultrasound)',
    'CT Scan',
    'MRI',
    'Admission (General Bed)',
    'Admission (Private Room)',
    'ICU',
  ];

  // Peak Hours (24-hour format)
  static const List<int> peakHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];
  
  // Off-Peak Hours
  static const List<int> offPeakHours = [18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7];

  // API Endpoints (as alternatives to config)
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  // Regex Patterns
  static const String phonePattern = r'^[0-9]{10}$';
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String namePattern = r'^[a-zA-Z\s]+$';

  // Feature Flags
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = false;
  static const bool enableAnalytics = true;
  static const bool enableAIFeatures = true;

  // Date/Time Formatting
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
}

// Helper class for formatting
class FormatHelper {
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
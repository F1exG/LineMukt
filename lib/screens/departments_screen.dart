import 'package:flutter/material.dart';
import '../services/api_service.dart';

// --- Constants for a Unified Brand ---
class AppColors {
  static const primaryBlue = Color(0xFF0066FF);
  static const textDark = Color(0xFF1E293B);
  static const textGrey = Color(0xFF64748B);
  static const bgGrey = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
}

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  String selectedCategory = 'All Specialties';
  
  final List<String> categories = [
    'All Specialties', 'Surgery', 'Diagnostics', 'General Care', 'Critical Care'
  ];

  final List<Map<String, dynamic>> departmentData = [
    {'id': 1, 'name': 'CTVS', 'description': 'Cardiothoracic and Vascular Surgery', 'icon': '🫀', 'prefix': 'CT'},
    {'id': 2, 'name': 'Cardiology', 'description': 'Heart and Cardiovascular', 'icon': '❤️', 'prefix': 'CA'},
    {'id': 3, 'name': 'Clinical Genetics', 'description': 'Genetic Disorders', 'icon': '🧬', 'prefix': 'CG'},
    {'id': 4, 'name': 'Clinical Oncology', 'description': 'Cancer Treatment', 'icon': '🔬', 'prefix': 'CO'},
    {'id': 5, 'name': 'Dentistry', 'description': 'Dental Care', 'icon': '🦷', 'prefix': 'DE'},
    {'id': 6, 'name': 'Dermatology', 'description': 'Skin Care', 'icon': '🩹', 'prefix': 'DR'},
    {'id': 7, 'name': 'ENT', 'description': 'Ear, Nose and Throat', 'icon': '👂', 'prefix': 'EN'},
    {'id': 8, 'name': 'Endocrinology', 'description': 'Hormone and Metabolism', 'icon': '⚗️', 'prefix': 'ED'},
    {'id': 9, 'name': 'Family Medicine', 'description': 'General and Emergency Care', 'icon': '🚑', 'prefix': 'FM'},
    {'id': 10, 'name': 'Gastroenterology', 'description': 'Digestive System', 'icon': '🫔', 'prefix': 'GA'},
    {'id': 11, 'name': 'Hematology', 'description': 'Blood Disorders', 'icon': '🩸', 'prefix': 'HE'},
    {'id': 12, 'name': 'Medical Oncology', 'description': 'Medical Cancer Care', 'icon': '🧪', 'prefix': 'MO'},
    {'id': 13, 'name': 'Medicine', 'description': 'Internal Medicine', 'icon': '💊', 'prefix': 'ME'},
    {'id': 14, 'name': 'Nephrology', 'description': 'Kidney Care', 'icon': '🫘', 'prefix': 'NE'},
    {'id': 15, 'name': 'Neurology', 'description': 'Brain and Nervous System', 'icon': '🧠', 'prefix': 'NU'},
    {'id': 16, 'name': 'Gynecology', 'description': 'Women Health', 'icon': '👶', 'prefix': 'GY'},
    {'id': 17, 'name': 'Orthopedic Surgery', 'description': 'Bone and Joint Care', 'icon': '🦴', 'prefix': 'OR'},
    {'id': 18, 'name': 'Pain Clinic', 'description': 'Pain Management', 'icon': '😣', 'prefix': 'PC'},
    {'id': 19, 'name': 'Pediatrics', 'description': 'Child Care', 'icon': '👨‍👧', 'prefix': 'PE'},
    {'id': 20, 'name': 'Pulmonary', 'description': 'Lung and Respiratory', 'icon': '🫁', 'prefix': 'PU'},
    {'id': 21, 'name': 'Rheumatology', 'description': 'Joint and Autoimmune', 'icon': '🦵', 'prefix': 'RH'},
    {'id': 22, 'name': 'Spine', 'description': 'Spine Care', 'icon': '🔋', 'prefix': 'SP'},
    {'id': 23, 'name': 'Surgery', 'description': 'General Surgery', 'icon': '🔪', 'prefix': 'SU'},
    {'id': 24, 'name': 'Urology', 'description': 'Urinary System', 'icon': '💧', 'prefix': 'UR'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildCategoryFilters(),
            const SizedBox(height: 48),
            _buildDepartmentGrid(),
            const SizedBox(height: 100),
            const HospitalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Department',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: 600,
          child: Text(
            'Choose a specialized department to join the live queue. Our expert medical staff is ready to help.',
            style: TextStyle(fontSize: 18, color: AppColors.textGrey, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return Wrap(
      spacing: 12,
      children: categories.map((cat) {
        final isSelected = selectedCategory == cat;
        return FilterChip(
          label: Text(cat),
          selected: isSelected,
          onSelected: (_) => setState(() => selectedCategory = cat),
          backgroundColor: Colors.white,
          selectedColor: AppColors.primaryBlue,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.w600,
          ),
          shape: StadiumBorder(side: BorderSide(color: isSelected ? AppColors.primaryBlue : AppColors.border)),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildDepartmentGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int columns = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.8,
        ),
        itemCount: departmentData.length,
        itemBuilder: (context, index) => DepartmentCard(
          dept: departmentData[index],
          onJoinQueue: () => _joinQueue(departmentData[index]),
        ),
      );
    });
  }

  void _joinQueue(Map<String, dynamic> dept) async {
    try {
      final result = await ApiService.joinQueue(
        departmentId: dept['id'],
        estimatedWait: 50,
        confidence: 70,
      );
      
      if (result['success']) {
        final randomToken = (1000 + (DateTime.now().microsecond % 9000)).toString();
        final displayToken = '${dept['prefix']}-$randomToken';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Joined ${dept['name']}! Token: $displayToken'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DepartmentCard extends StatelessWidget {
  final Map<String, dynamic> dept;
  final VoidCallback onJoinQueue;
  
  const DepartmentCard({
    super.key,
    required this.dept,
    required this.onJoinQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(dept['icon'], style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(dept['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(dept['description'], textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
          const Spacer(),
          FilledButton(
            onPressed: onJoinQueue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Join Queue'),
          ),
        ],
      ),
    );
  }
}

class HospitalFooter extends StatelessWidget {
  const HospitalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.border);
  }
}
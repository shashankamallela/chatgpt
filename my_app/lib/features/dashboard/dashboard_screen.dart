import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<Map<String, dynamic>> educationalVideos = [
    {
      'title': 'Brush Your Teeth Song for Kids',
      'shortTitle': 'Brush Your Teeth Song',
      'subtitle': 'Animated brushing lesson',
      'duration': '4 min',
      'category': 'Brushing',
      'tag': 'Kids',
      'description':
          'A cheerful animated brushing song that helps children remember to brush their teeth every day.',
      'tip': 'Brush in small circles for two minutes, twice a day.',
      'file': 'https://www.youtube.com/watch?v=wCio_xVlgQ0',
      'icon': Icons.health_and_safety_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Why Do We Brush Our Teeth?',
      'shortTitle': 'Why Brush Teeth?',
      'subtitle': 'Cavity care for children',
      'duration': '5 min',
      'category': 'Cavity Care',
      'tag': 'Care',
      'description':
          'A child-friendly science video explaining plaque, germs, and why brushing helps protect teeth from cavities.',
      'tip': 'After sweets, drink water and brush when it is brushing time.',
      'file': 'https://www.youtube.com/watch?v=XbxsdbisXzU',
      'icon': Icons.bug_report_outlined,
      'color': Colors.green,
    },
    {
      'title': 'A Visit to the Dentist',
      'shortTitle': 'Dentist Visit',
      'subtitle': 'Friendly checkup guide',
      'duration': '6 min',
      'category': 'Dental Visit',
      'tag': 'Visit',
      'description':
          'A gentle animated video that helps children understand what happens at the dentist and feel less scared before a checkup.',
      'tip': 'A dentist visit is a tooth checkup, not something to fear.',
      'file': 'https://www.youtube.com/watch?v=ntx1Nn5C4nI',
      'icon': Icons.sentiment_satisfied_alt,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      drawer: _DashboardDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnalysisPanel(),
                    const SizedBox(height: 40),
                    const Text(
                      "Educational Videos",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final video in educationalVideos) ...[
                      GestureDetector(
                        onTap: () {
                          context.push('/video-player', extra: video);
                        },
                        child: _videoCard(video),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _videoCard(Map<String, dynamic> video) {
    final Color color = video['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              video['icon'] as IconData,
              color: color,
              size: 42,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['shortTitle'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video['subtitle'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        video['duration'] as String,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        video['tag'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 70,
              left: 24,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1D4ED8),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Oral Diet Dashboard",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          _drawerTile(
            context,
            Icons.video_collection_outlined,
            "Kids Dental Videos",
            "View 10 lessons",
            Colors.purple,
            '/videos-watched',
          ),
          _drawerTile(
            context,
            Icons.person_outline,
            "My Profile",
            "Edit your details",
            Colors.blue,
            '/my-profile',
          ),
          _drawerTile(
            context,
            Icons.history,
            "History",
            "Past activities",
            Colors.orange,
            '/history',
          ),
          _drawerTile(
            context,
            Icons.trending_up,
            "Daily Progress",
            "Track your goals",
            Colors.green,
            '/daily-progress',
          ),
          _drawerTile(
            context,
            Icons.water_drop_outlined,
            "Daily Water Intake",
            "Hydration tracker",
            Colors.cyan,
            '/daily-water',
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: _drawerIcon(Icons.logout, Colors.red),
            title: const Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Logout from app",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              context.go('/login');
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _drawerTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
  ) {
    return ListTile(
      leading: _drawerIcon(icon, color),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () {
        context.push(route);
      },
    );
  }

  static Widget _drawerIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String profileName = 'User';

  @override
  void initState() {
    super.initState();
    loadProfileName();
  }

  Future<void> loadProfileName() async {
    final currentEmail = await AuthStorage.currentEmail();

    if (currentEmail.isEmpty) {
      return;
    }

    final fallbackName = currentEmail.split('@').first;

    try {
      final result = await ApiService.fetchProfile(currentEmail);
      final profile = result['profile'];
      final name = profile is Map ? profile['name']?.toString().trim() : '';

      if (!mounted) return;

      setState(() {
        profileName = name == null || name.isEmpty ? fallbackName : name;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        profileName = fallbackName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 34,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _AnalysisPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.purple.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analysis",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/scan-food');
                  },
                  child: _analysisCard(
                    Icons.camera_alt_outlined,
                    "Scan Food",
                    "Use camera to scan",
                    Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/type-food');
                  },
                  child: _analysisCard(
                    Icons.edit_outlined,
                    "Type Food",
                    "Manually enter food",
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _analysisCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              size: 38,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

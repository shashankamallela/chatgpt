import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RiskAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> foodData;

  const RiskAnalysisScreen({
    super.key,
    required this.foodData,
  });

  @override
  Widget build(BuildContext context) {
    final risk = foodData['risk']?.toString() ?? 'Medium';
    final riskColor = _riskColor(risk);
    final summary = foodData['summary']?.toString() ??
        'Oral health risk was predicted from sugar, acidity, and food texture data.';
    final accuracyText = _accuracyText(foodData);
    final fat = foodData['fat']?.toString() ?? 'Medium';
    final waterText = _waterText(foodData);
    final recommendations = _recommendations(foodData);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "About Analysis",
                                  ),
                                  content: const Text(
                                    "This AI-powered analysis predicts oral health risks based on sugar level, acidity, ingredients, and nutritional impact of the food.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                      child: const Text(
                                        "OK",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Risk Analysis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      foodData['food'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (foodData['imageBytes'] != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            foodData['imageBytes'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    /// ABOUT ANALYSIS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6A11CB),
                            Color(0xFF2575FC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "About Analysis",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "This AI system predicts oral health risks using food ingredients, sugar levels, acidity, and nutrition patterns.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 17,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// RISK SCORE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: riskColor.withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: Text(
                                foodData['score'].toString(),
                                style: const TextStyle(
                                  fontSize: 90,
                                  fontWeight: FontWeight.bold,
                                ).copyWith(color: riskColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "$risk Risk",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            summary,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// QUICK INSIGHTS
                    Row(
                      children: [
                        Expanded(
                          child: _insightCard(
                            "Sugar",
                            foodData['sugar'],
                            Colors.red,
                            Icons.cake_outlined,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _insightCard(
                            "Acidity",
                            foodData['acidity'],
                            Colors.orange,
                            Icons.warning_amber,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _insightCard(
                            "Fat",
                            fat,
                            Colors.deepPurple,
                            Icons.local_fire_department_outlined,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _insightCard(
                            "Water",
                            waterText,
                            Colors.blue,
                            Icons.water_drop_outlined,
                          ),
                        ),
                      ],
                    ),

                    if (accuracyText.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _insightCard(
                        "Accuracy",
                        accuracyText,
                        Colors.blue,
                        Icons.verified_outlined,
                      ),
                    ],

                    const SizedBox(height: 30),

                    _recommendationPanel(recommendations),

                    const SizedBox(height: 40),

                    /// VIEW REPORT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF2563EB,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),
                        onPressed: () {
                          context.push(
                            '/detailed-report',
                            extra: foodData,
                          );
                        },
                        child: const Text(
                          "View Detailed Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BACK TO DASHBOARD
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),
                        onPressed: () {
                          context.go('/dashboard');
                        },
                        child: const Text(
                          "Back To Dashboard",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _insightCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  static Widget _recommendationPanel(List<String> recommendations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: Colors.amber,
                size: 30,
              ),
              SizedBox(width: 12),
              Text(
                "Recommendations",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final recommendation in recommendations) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static String _waterText(Map<String, dynamic> foodData) {
    final value = foodData['water_ml'];

    if (value is num) {
      return '${value.round()} ml';
    }

    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return '350 ml';
    }

    return '${parsed.round()} ml';
  }

  static List<String> _recommendations(Map<String, dynamic> foodData) {
    final value = foodData['recommendations'];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    final fallback = foodData['recommendation']?.toString();
    if (fallback != null && fallback.isNotEmpty) {
      return [fallback];
    }

    return [
      'Drink water after eating and keep sugary or fried foods to smaller portions.',
    ];
  }

  static String _accuracyText(Map<String, dynamic> foodData) {
    final value = foodData['accuracy'];

    if (value is num) {
      return '${value.round()}%';
    }

    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return '';
    }

    return '${parsed.round()}%';
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoodDetectedScreen extends StatelessWidget {
  final Map<String, dynamic> foodData;

  const FoodDetectedScreen({
    super.key,
    required this.foodData,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyText = _accuracyText(foodData);
    final accuracyLabel =
        foodData.containsKey('image_accuracy') ? 'Identification' : 'Accuracy';
    final needsReview = foodData['needs_review'] == true;
    final imageWarning = foodData['image_warning']?.toString() ?? '';

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
                      Color(0xFF06B6D4),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20),
                    const Text(
                      "Food Detected",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
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
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 260,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                            ),
                            child: foodData['imageBytes'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.memory(
                                      foodData['imageBytes'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 100,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            foodData['food'],
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Risk: ${foodData['risk']}",
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Score: ${foodData['score']}",
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          if (accuracyText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              "$accuracyLabel: $accuracyText",
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ],
                          if (needsReview && imageWarning.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                imageWarning,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF2563EB,
                          ),
                        ),
                        onPressed: () {
                          context.push(
                            '/risk-analysis',
                            extra: foodData,
                          );
                        },
                        child: const Text(
                          "Predict Risk",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (needsReview) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/type-food');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            "Type Food Name",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

  static String _accuracyText(Map<String, dynamic> foodData) {
    final value = foodData['image_accuracy'] ?? foodData['accuracy'];

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

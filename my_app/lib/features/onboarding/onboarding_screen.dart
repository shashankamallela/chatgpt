import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [

    {
      "title": "Track Your Oral Health",
      "description":
          "Monitor your food habits and improve your dental health with AI powered analysis.",
      "icon": Icons.health_and_safety,
      "color": Colors.blue,
    },

    {
      "title": "Smart Food Detection",
      "description":
          "Scan foods instantly and identify ingredients affecting oral health.",
      "icon": Icons.food_bank_outlined,
      "color": Colors.orange,
    },

    {
      "title": "AI Risk Analysis",
      "description":
          "Get personalized recommendations and detailed oral health reports.",
      "icon": Icons.analytics_outlined,
      "color": Colors.green,
    },

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [

              Align(

                alignment: Alignment.topRight,

                child: TextButton(

                  onPressed: () {

                    context.go('/terms');

                  },

                  child: const Text(

                    "Skip",

                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              Expanded(

                child: PageView.builder(

                  controller: _pageController,

                  itemCount: onboardingData.length,

                  onPageChanged: (index) {

                    setState(() {

                      currentPage = index;

                    });
                  },

                  itemBuilder: (context, index) {

                    return Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Container(

                          height: 260,
                          width: 260,

                          decoration: BoxDecoration(

                            color: onboardingData[index]["color"]
                                .withOpacity(0.1),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(

                            onboardingData[index]["icon"],

                            size: 120,

                            color: onboardingData[index]["color"],
                          ),
                        ),

                        const SizedBox(height: 60),

                        Text(

                          onboardingData[index]["title"],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(

                          onboardingData[index]["description"],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6B7280),
                            height: 1.6,
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: List.generate(

                  onboardingData.length,

                  (index) {

                    return AnimatedContainer(

                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(horizontal: 5),

                      height: 10,

                      width: currentPage == index ? 32 : 10,

                      decoration: BoxDecoration(

                        color: currentPage == index
                            ? Colors.blue
                            : Colors.grey.shade300,

                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(

                width: double.infinity,
                height: 65,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),

                  onPressed: () {

                    if (currentPage < onboardingData.length - 1) {

                      _pageController.nextPage(

                        duration: const Duration(milliseconds: 300),

                        curve: Curves.easeInOut,
                      );

                    } else {

                      context.go('/terms');

                    }

                  },

                  child: Text(

                    currentPage == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
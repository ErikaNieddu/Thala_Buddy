import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class GuideScreen extends StatefulWidget {
  static const route = '/guide/';
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);

  final List<Map<String, dynamic>> guideData = [
    {
      "title": "Daily Health Insights",
      "description": "Please note: the app analyzes your vitals based on data collected from the previous day.\n\nTrack your Effort Index, Heart Rate Reserve, and Sleep Score to understand your body's response.",
      "animation": "assets/home.json",
      "customScale": 1.0,
    },
    {
      "title": "Plan Your Therapies",
      "description": "Easily schedule and keep track of your upcoming transfusion sessions and medical check-ups in one place.",
      "animation": "assets/calendar.json",
      "customScale": 1.4,
    },
    {
      "title": "Travel Safely",
      "description": "Explore an interactive map to locate specialized thalassemia centers across Europe whenever you travel.",
      "animation": "assets/travel.json",
      "customScale": 1.4,
    },
    {
      "title": "Share Clinical Reports",
      "description": "Generate a 30-day PDF summary of your clinical data in seconds, ready to be shared with your hematologist.",
      "animation": "assets/report.json",
      "customScale": 1.4,
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _finishGuide(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('hasSeenGuide', true);

    bool hasSeenOnboarding = sp.getBool('hasSeenOnboarding') ?? false;

    if (context.mounted) {
      if (hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/home/');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == guideData.length - 1;
    bool isFirstPage = _currentPage == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isLastPage ? 0.0 : 1.0,
                child: TextButton(
                  onPressed: isLastPage ? null : () => _finishGuide(context),
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: guideData.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return AnimatedGuideSlide(
                    title: guideData[index]["title"],
                    description: guideData[index]["description"],
                    animationPath: guideData[index]["animation"],
                    customScale: guideData[index]["customScale"],
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity: isFirstPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: isFirstPage ? null : () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                        );
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      guideData.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isLastPage) {
                        _finishGuide(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      height: 52,
                      width: isLastPage ? 140 : 100,
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: isLastPage
                            ? [BoxShadow(color: primaryRed.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))]
                            : [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                        },
                        child: Text(
                          isLastPage ? "Get Started" : "Next",
                          key: ValueKey<bool>(isLastPage),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 10 : 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryRed : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class AnimatedGuideSlide extends StatelessWidget {
  final String title;
  final String description;
  final String animationPath;
  final double customScale;
  final bool isActive;

  const AnimatedGuideSlide({
    super.key,
    required this.title,
    required this.description,
    required this.animationPath,
    required this.customScale,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? (1.0 * customScale) : (0.8 * customScale),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: SizedBox(
                  height: screenHeight * 0.30,
                  width: double.infinity,
                  child: Lottie.asset(
                    animationPath,
                    fit: BoxFit.contain,
                    repeat: isActive,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 700),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
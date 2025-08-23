import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../authentication/views/register_page.dart';
import 'intro_page1.dart';
import 'intro_page2.dart';
import 'intro_page3.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _introPageController = PageController();
  final List<Widget> _introPages = [
    const IntroPage1(),
    const IntroPage2(),
    const IntroPage3(),
  ];
  bool onLastPage = false;
  late final int _totalPages;

  void _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true); // Save the flag

    if (!mounted) return; // only use context if still valid

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _totalPages = _introPages.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: PageView(
              controller: _introPageController,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == _totalPages - 1);
                });
              },
              children: _introPages,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Dot Indicator
                  SmoothPageIndicator(
                    controller: _introPageController,
                    count: _totalPages,
                    effect: const ExpandingDotsEffect(
                      // Example effect
                      activeDotColor: Colors.white,
                      dotColor: Colors.grey,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Get Started Button displayed only on last page
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: onLastPage
                        ? ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          )
                        : const SizedBox(height: 52),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

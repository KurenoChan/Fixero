import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            'assets/images/intro/intro1.jpg',
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),

        SizedBox(height: 20),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Tired of\n',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 25,
                  height: 1.2,
                ),
              ),

              TextSpan(
                text: 'Job Confusion?',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ]
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Track jobs, assign tasks, and stay organized — all in one app.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                color: Colors.white54
            ),
          ),
        ),
      ],
    );
  }
}

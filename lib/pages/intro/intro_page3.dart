import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            'assets/images/intro/intro3.jpg',
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
                  text: '\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    height: 1.2,
                  ),
                ),

                TextSpan(
                  text: 'Welcome to Fixero',
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
            'Your smart mobile tool for running efficient workshops.',
            textAlign: TextAlign.justify,
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
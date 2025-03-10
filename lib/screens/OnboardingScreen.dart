import 'package:flutter/material.dart';

import '../models/OnboardingView1.dart';
import 'account_type_screen.dart';
import 'login_screen.dart';
import 'on_boarding_screen1.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                OnboardingView1(
                  image: 'assets/images/onBordaring1.PNG',
                  title: 'Your life is easier with electronic payment',
                  description:
                      'Our app is very easy to use, even if you are new to technology.',
                ),
                OnboardingView1(
                  image: 'assets/images/onBordaring2.PNG',
                  title:
                      'Live your life simply, and let us take care of your payment',
                  description:
                      'Pay your bills, purchase your needs, and get what you want with just a few simple clicks.',
                ),
                OnboardingView1(
                  image: 'assets/images/onBordaring3.PNG',
                  title: 'Your money is at your fingertips in complete safety',
                  description:
                      'Our application is specially designed for elderly people to facilitate their daily lives.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 40),
            child: Row(
              children: List.generate(3, (index) => buildDot(index, context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AccountTypeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99),
                    minimumSize: const Size(100, 46),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Start Now',
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountTypeScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingPage(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    }
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: _currentPage == index ? 25 : 10,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFF308A99) : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}



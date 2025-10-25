import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, -0.02),
      end: const Offset(0, 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user == null ? const LoginScreen() : const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.3; 
    final verticalSpacing = size.height * 0.04;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8F8CEB), Color(0xFF6A5AE0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _animation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.15,
                        child: _buildImageBox(
                          'assets/images/cover-image.jpg',
                          imageSize,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Transform.scale(
                        scale: 1.1,
                        child: _buildImageBox(
                          'assets/images/cover-image2.jpg',
                          imageSize,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Transform.rotate(
                        angle: 0.15,
                        child: _buildImageBox(
                          'assets/images/cover-image.jpg',
                          imageSize,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing * 2),

                Text(
                  "Task Manager",
                  style: TextStyle(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),

                SizedBox(height: verticalSpacing * 1.5),

                const SpinKitCircle(color: Colors.white, size: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBox(String path, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: size * 0.1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}

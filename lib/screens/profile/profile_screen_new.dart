import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔥 Background blur gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff1a1a2e),
                  Color(0xff0f3460),
                  Color(0xff16213e),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🔥 Top Cards (blur images)
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 Profile Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔥 Name + Verified
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Kristin Watson",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified, color: Colors.blue, size: 18)
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 🔥 Online
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(radius: 4, backgroundColor: Colors.green),
                      SizedBox(width: 6),
                      Text("Online",
                          style: TextStyle(color: Colors.green, fontSize: 12))
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 🔥 Bio
                  const Text(
                    "I'm a generous and girl, hope my enthusiasm add more color to your life...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleBtn(Icons.call),
                      const SizedBox(width: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          "Message",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 16),
                      _circleBtn(Icons.person_add),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔥 Sections
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Friends Flow",
                          style: TextStyle(color: Colors.white)),
                      Text("Mutual Groups",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔥 Grid images
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

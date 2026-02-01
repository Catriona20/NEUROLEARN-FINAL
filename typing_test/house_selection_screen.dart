import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/house_config.dart';
import 'widgets/sparkles_overlay.dart';
import 'typing_test_screen.dart';

class HouseSelectionScreen extends StatelessWidget {
  const HouseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Stack(
          children: [
            const SparklesOverlay(count: 50),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    Text(
                      '⚡ Choose Your House ⚡',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.georgia(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        shadows: [
                          const Shadow(
                            color: Color(0x80FFD700),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '"It is our choices that show what we truly are, far more than our abilities."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.georgia(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 50),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: HouseConfig.houses.length,
                      itemBuilder: (context, index) {
                        final house = HouseConfig.houses[index];
                        return _HouseCard(house: house);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseCard extends StatefulWidget {
  final HouseConfig house;

  const _HouseCard({required this.house});

  @override
  State<_HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<_HouseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TypingTestScreen(house: widget.house),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()..translate(0, _isHovered ? -10.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.house.primaryColor,
              width: 3,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.house.primaryColor.withOpacity(0.6),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.house.icon,
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.house.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.georgia(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.house.primaryColor,
                          shadows: [
                            const Shadow(
                              color: Colors.black54,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.house.trait,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.georgia(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

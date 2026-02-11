import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  
  // Part 1: Pulse Control Animation
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💖 Cupid\'s Canvas 💖'), centerTitle: true),
      // Part 2: Romantic Background Gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFFFFF1F1), Color(0xFFFFCDD2)],
            radius: 1.0,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Emoji Selection
            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold))))
                  .toList(),
              onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            
            // Step 3: Display the Love (Asset Image)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.asset('assets/images/love_icon.png', height: 50),
            ),

            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: HeartEmojiPainter(type: selectedEmoji),
                  ),
                ),
              ),
            ),
            
            // Pulse Speed Control
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Slider(
                label: "Pulse Speed",
                value: _controller.duration!.inMilliseconds.toDouble(),
                min: 300,
                max: 2000,
                onChanged: (val) {
                  setState(() {
                    _controller.duration = Duration(milliseconds: val.toInt());
                    _controller.repeat(reverse: true);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Love Trail (Glowing Aura)
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    final heartPath = _getHeartPath(center);
    canvas.drawPath(heartPath, glowPaint);

    // Heart base with Linear Gradient
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.red, Colors.pinkAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(heartPath, paint);

    // Face features
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 35, center.dy - 15), 12, eyePaint);
    canvas.drawCircle(Offset(center.dx + 35, center.dy - 15), 12, eyePaint);
    
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 30),
      0.2, 2.8, false, mouthPaint
    );

    // Part 2: Party Heart festive details
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 130)
        ..lineTo(center.dx - 50, center.dy - 60)
        ..lineTo(center.dx + 50, center.dy - 60)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
      
      // Confetti using a loop
      final random = math.Random(42);
      for (int i = 0; i < 15; i++) {
        final confettiPaint = Paint()..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
        canvas.drawCircle(
          Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
          4,
          confettiPaint
        );
      }
    }
  }

  Path _getHeartPath(Offset center) {
    return Path()
      ..moveTo(center.dx, center.dy + 80)
      ..cubicTo(center.dx + 130, center.dy - 10, center.dx + 80, center.dy - 140, center.dx, center.dy - 50)
      ..cubicTo(center.dx - 80, center.dy - 140, center.dx - 130, center.dy - 10, center.dx, center.dy + 80)
      ..close();
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => true;
}
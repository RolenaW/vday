import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool isPulsing = false;
  bool showBalloons = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed && isPulsing) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePulse() {
    setState(() => isPulsing = !isPulsing);

    if (isPulsing) {
      _controller.forward();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  void launchBalloons() {
    setState(() => showBalloons = true);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showBalloons = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Color(0xFFFFCDD2), Color(0xFFD32F2F)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),

            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedEmoji = value ?? selectedEmoji),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: togglePulse,
                  child: Text(
                      isPulsing ? 'Stop Pulse 💓' : 'Start Pulse 💓'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: launchBalloons,
                  child: const Text('Balloon Celebration 🎈'),
                ),
              ],
            ),

            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter:
                            HeartEmojiPainter(type: selectedEmoji),
                      ),
                    ),
                  ),

                  if (showBalloons)
                    const Positioned.fill(
                      child: BalloonOverlay(),
                    ),
                ],
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

    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10,
          center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120,
          center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    /// Love Trail Glow
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawPath(heartPath, glowPaint);

    /// Gradient Heart Fill
    final rect = Rect.fromCenter(
        center: center, width: 220, height: 220);

    final gradient = LinearGradient(
      colors: type == 'Party Heart'
          ? [Colors.pinkAccent, Colors.orange]
          : [Colors.redAccent, Colors.pink],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawPath(heartPath, fillPaint);

    /// Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(
        Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    /// Smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
        0,
        pi,
        false,
        mouthPaint);

    /// Sparkles
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final dx = center.dx + cos(angle) * 140;
      final dy = center.dy + sin(angle) * 140;

      canvas.drawLine(
          Offset(dx - 5, dy), Offset(dx + 5, dy), sparklePaint);
      canvas.drawLine(
          Offset(dx, dy - 5), Offset(dx, dy + 5), sparklePaint);
    }

    /// Party Confetti
    if (type == 'Party Heart') {
      final confettiPaint = Paint();

      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.yellow
      ];

      for (int i = 0; i < 20; i++) {
        confettiPaint.color = colors[i % colors.length];

        final x = Random().nextDouble() * size.width;
        final y = Random().nextDouble() * size.height;

        if (i % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 4, confettiPaint);
        } else {
          final path = Path()
            ..moveTo(x, y)
            ..lineTo(x + 6, y + 10)
            ..lineTo(x - 6, y + 10)
            ..close();
          canvas.drawPath(path, confettiPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BalloonOverlay extends StatelessWidget {
  const BalloonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(12, (index) {
        final random = Random();
        return Positioned(
          left: random.nextDouble() * 300,
          bottom: -50,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 500),
            duration: Duration(seconds: 3 + random.nextInt(2)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -value),
                child: child,
              );
            },
            child: Icon(
              Icons.circle,
              size: 30,
              color: Colors.primaries[index % Colors.primaries.length],
            ),
          ),
        );
      }),
    );
  }
}

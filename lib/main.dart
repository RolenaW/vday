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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// Emoji Selector
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) =>
                setState(() => selectedEmoji = value ?? selectedEmoji),
          ),

          const SizedBox(height: 12),

          /// Pulse Button
          ElevatedButton(
            onPressed: () {
              setState(() {
                isPulsing = !isPulsing;
              });

              if (isPulsing) {
                _controller.forward();
              } else {
                _controller.stop();
                _controller.reset();
              }
            },
            child: Text(isPulsing ? 'Stop Pulse 💓' : 'Start Pulse 💓'),
          ),

          const SizedBox(height: 16),

          /// Heart Display
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: HeartEmojiPainter(type: selectedEmoji),
                ),
              ),
            ),
          ),
        ],
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
    final paint = Paint()..style = PaintingStyle.fill;

    /// Heart Base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10,
          center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120,
          center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color = type == 'Party Heart'
        ? const Color(0xFFF48FB1)
        : const Color(0xFFE91E63);

    canvas.drawPath(heartPath, paint);

    /// Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    /// Smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
        0,
        3.14,
        false,
        mouthPaint);

    /// Sweet Heart Extras
    if (type == 'Sweet Heart') {
      final blushPaint =
          Paint()..color = Colors.pinkAccent.withOpacity(0.4);

      canvas.drawCircle(
          Offset(center.dx - 50, center.dy + 10), 12, blushPaint);
      canvas.drawCircle(
          Offset(center.dx + 50, center.dy + 10), 12, blushPaint);
    }

    /// Party Heart Extras
    if (type == 'Party Heart') {
      /// Party Hat
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 120)
        ..lineTo(center.dx - 50, center.dy - 40)
        ..lineTo(center.dx + 50, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      /// Hat Ball
      canvas.drawCircle(
          Offset(center.dx, center.dy - 120),
          8,
          Paint()..color = Colors.red);

      /// Confetti
      final confettiPaint = Paint()..style = PaintingStyle.fill;
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.yellow
      ];

      for (int i = 0; i < 20; i++) {
        confettiPaint.color = colors[i % colors.length];
        canvas.drawCircle(
          Offset(
            (size.width * (i % 5) / 5) + 30,
            (size.height * (i ~/ 5) / 4) + 20,
          ),
          5,
          confettiPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}

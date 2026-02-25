import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' as painting;
import '../game/stick_adventure_game.dart';

class Player extends PositionComponent with HasGameReference<StickAdventureGame> {
  static const moveSpeed = 200.0;
  static const jumpForce = -12.0;
  static const gravity = 0.6;
  static const headRadius = 8.0;
  static const bodyLength = 20.0;
  static const limbLength = 15.0;

  Vector2 velocity = Vector2.zero();
  bool isGrounded = false;
  bool facingRight = true;
  double _animTime = 0;

  Player() : super(size: Vector2(20, 50), anchor: Anchor.bottomCenter);

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  void applyInput(double dt, bool left, bool right, bool jump) {
    velocity.x = 0;
    if (left) {
      velocity.x = -moveSpeed;
      facingRight = false;
    }
    if (right) {
      velocity.x = moveSpeed;
      facingRight = true;
    }
    if (jump && isGrounded) {
      velocity.y = jumpForce;
      isGrounded = false;
    }
    if (!isGrounded) velocity.y += gravity;

    position.x += velocity.x * dt;
    position.y += velocity.y;

    final groundY = game.groundY;
    if (position.y >= groundY) {
      position.y = groundY;
      velocity.y = 0;
      isGrounded = true;
    }
    if (position.x < 0) position.x = 0;
  }

  void applyIdleMove(double dx) {
    position.x += dx;
    if (position.x < 0) position.x = 0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final isWalking = velocity.x.abs() > 10 || game.idleManager.active;
    final legSwing = isWalking ? math.sin(_animTime * 8) * 8 : 0.0;
    final armSwing = isWalking ? math.sin(_animTime * 8) * 6 : 0.0;

    // Relative to bottom-center anchor
    final cx = size.x / 2;
    final baseY = size.y;

    // Head
    canvas.drawCircle(
      Offset(cx, baseY - bodyLength - headRadius),
      headRadius,
      paint,
    );

    // Body
    canvas.drawLine(
      Offset(cx, baseY - bodyLength),
      Offset(cx, baseY),
      paint,
    );

    // Arms
    final path = Path()
      ..moveTo(cx - limbLength, baseY - bodyLength + 5 + armSwing)
      ..lineTo(cx, baseY - bodyLength + 3)
      ..lineTo(cx + limbLength, baseY - bodyLength + 5 - armSwing);
    canvas.drawPath(path, paint);

    // Legs
    final legs = Path()
      ..moveTo(cx - limbLength * 0.7 + legSwing, baseY + limbLength)
      ..lineTo(cx, baseY)
      ..lineTo(cx + limbLength * 0.7 - legSwing, baseY + limbLength);
    canvas.drawPath(legs, paint);

    // Auto indicator
    if (game.idleManager.active) {
      final textPaint = TextPaint(
        style: const painting.TextStyle(
          color: Color(0xFF44ff88),
          fontSize: 8,
          fontFamily: 'monospace',
        ),
      );
      textPaint.render(
        canvas,
        'AUTO',
        Vector2(cx - 10, baseY - bodyLength - headRadius - 14),
      );
    }
  }
}

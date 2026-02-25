import 'package:flutter/material.dart';
import '../game/stick_adventure_game.dart';

class GameJoystick extends StatefulWidget {
  final StickAdventureGame game;

  const GameJoystick({super.key, required this.game});

  @override
  State<GameJoystick> createState() => _GameJoystickState();
}

class _GameJoystickState extends State<GameJoystick> {
  Offset _joystickPos = Offset.zero;
  bool _joystickActive = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left side: movement joystick
        Positioned(
          left: 20,
          bottom: 20,
          child: GestureDetector(
            onPanStart: (d) {
              setState(() { _joystickActive = true; _joystickPos = Offset.zero; });
            },
            onPanUpdate: (d) {
              setState(() {
                _joystickPos = Offset(
                  d.localPosition.dx - 60,
                  d.localPosition.dy - 60,
                );
                final dist = _joystickPos.distance;
                if (dist > 40) {
                  _joystickPos = _joystickPos / dist * 40;
                }
              });
              widget.game.inputLeft = _joystickPos.dx < -10;
              widget.game.inputRight = _joystickPos.dx > 10;
            },
            onPanEnd: (_) {
              setState(() { _joystickActive = false; _joystickPos = Offset.zero; });
              widget.game.inputLeft = false;
              widget.game.inputRight = false;
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Transform.translate(
                  offset: _joystickPos,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _joystickActive
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right side: action buttons
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: 'JUMP',
                color: Colors.blue,
                onTapDown: () => widget.game.inputJump = true,
                onTapUp: () => widget.game.inputJump = false,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    label: 'CATCH',
                    color: Colors.amber,
                    onTapDown: () => widget.game.inputCatch = true,
                    onTapUp: () => widget.game.inputCatch = false,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    label: 'ATK',
                    color: Colors.red,
                    onTapDown: () => widget.game.inputAttack = true,
                    onTapUp: () => widget.game.inputAttack = false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

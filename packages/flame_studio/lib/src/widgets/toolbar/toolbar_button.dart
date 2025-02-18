import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolbarButton extends ConsumerStatefulWidget {
  const ToolbarButton({
    required this.icon,
    this.onClick,
    this.disabled = false,
    super.key,
  });

  final void Function()? onClick;
  final Path icon;
  final bool disabled;

  @override
  _ToolbarButtonState createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends ConsumerState<ToolbarButton> {
  bool _isHovered = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: _ToolbarButtonPainter(
        widget.disabled,
        _isHovered,
        _isActive,
        widget.icon,
        ref.watch(themeProvider),
      ),
    );

    return AspectRatio(
      aspectRatio: 1.25,
      child: widget.disabled
          ? painter
          : MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isActive = true),
                onTapCancel: () => setState(() => _isActive = false),
                onTapUp: (_) {
                  if (_isActive) {
                    widget.onClick?.call();
                  }
                  setState(() => _isActive = false);
                },
                child: painter,
              ),
            ),
    );
  }

  @override
  void didUpdateWidget(ToolbarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon ||
        widget.disabled != oldWidget.disabled) {
      _isActive = false;
      _isHovered = false;
    }
  }
}

class _ToolbarButtonPainter extends CustomPainter {
  _ToolbarButtonPainter(
    this.isDisabled,
    this.isHovered,
    this.isActive,
    this.icon,
    this.theme,
  );

  final bool isDisabled;
  final bool isHovered;
  final bool isActive;
  final Path icon;
  final Theme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 20.0;
    canvas.save();
    canvas.scale(size.height / 20.0);

    final radius = Radius.circular(theme.buttonRadius);
    final color = isDisabled
        ? theme.buttonDisabledColor
        : isActive
            ? theme.buttonActiveColor
            : isHovered
                ? theme.buttonHoverColor
                : theme.buttonColor;
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width / scale, 20.0, radius),
      Paint()..color = color,
    );

    final textColor = isDisabled
        ? theme.buttonDisabledTextColor
        : isActive
            ? theme.buttonActiveTextColor
            : isHovered
                ? theme.buttonHoverTextColor
                : theme.buttonTextColor;
    canvas.translate(size.width / scale / 2, 10);
    canvas.drawPath(icon, Paint()..color = textColor);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ToolbarButtonPainter old) {
    return isHovered != old.isHovered ||
        isActive != old.isActive ||
        isDisabled != old.isDisabled ||
        icon != old.icon;
  }
}

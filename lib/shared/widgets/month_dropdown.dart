import 'dart:ui';
import 'package:flutter/material.dart';

class MonthDropdown extends StatefulWidget {
  final String initialMonth;
  final Function(String)? onChanged;

  const MonthDropdown({super.key, required this.initialMonth, this.onChanged});

  @override
  State<MonthDropdown> createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<MonthDropdown>
    with SingleTickerProviderStateMixin {
  late String selectedMonth;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  final List<String> months = const [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];

  String? hovered;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    // Fade-in
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Subtle scale (0.98 -> 1.0)
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(_fade);

    // No slide needed for human feel
    _slide = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _overlay();
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _close() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _overlay() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final pos = box.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + size.width / 2 - 80, // center dropdown
        top: pos.dy + size.height + 8,
        width: 160,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale, // bounce!
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: months.map((m) {
                          final isHovered = hovered == m;
                          final isSelected = selectedMonth == m;

                          return MouseRegion(
                            onEnter: (_) => setState(() => hovered = m),
                            onExit: (_) => setState(() => hovered = null),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedMonth = m);
                                widget.onChanged?.call(m);
                                _close();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : isHovered
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.black.withValues(alpha: 0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                selectedMonth,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

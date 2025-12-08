import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/habit.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  final bool showDragHandle;
  final int? index;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onTap,
    this.showDragHandle = false,
    this.index,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showConfetti = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleComplete() {
    if (!isCompletedToday) {
      setState(() => _showConfetti = true);
      _controller.forward();
      widget.onComplete();
    }
  }

  bool get isCompletedToday {
    if (widget.habit.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = widget.habit.lastCompletedDate!;
    final lastCompletedDay = DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    );
    return lastCompletedDay.isAtSameMomentAs(today);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Semantics(
            button: true,
            label:
                'Hábito: ${widget.habit.name}, Duración: ${widget.habit.durationMinutes} minutos, Racha actual: ${widget.habit.currentStreak}, Estado: ${isCompletedToday ? "completado hoy" : "pendiente"}',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.habit.icon,
                  style: const TextStyle(fontSize: 24),
                  semanticsLabel: 'Icono del hábito ${widget.habit.name}',
                ),
              ),
              title: Text(
                widget.habit.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                semanticsLabel: 'Nombre del hábito: ${widget.habit.name}',
              ),
              subtitle: Text(
                '${widget.habit.durationMinutes} min • Racha: ${widget.habit.currentStreak} 🔥',
                semanticsLabel:
                    'Duración: ${widget.habit.durationMinutes} minutos, Racha actual: ${widget.habit.currentStreak} días',
              ),
              trailing: widget.showDragHandle
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: isCompletedToday
                              ? 'Hábito ya completado hoy'
                              : 'Completar hábito',
                          child: _AnimatedCheckButton(
                            isCompleted: isCompletedToday,
                            onTap: isCompletedToday ? null : _handleComplete,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          label: 'Arrastrar para reordenar hábito',
                          child: ReorderableDragStartListener(
                            index: widget.index ?? 0,
                            child: const Icon(
                              Icons.drag_indicator,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Semantics(
                      button: true,
                      label: isCompletedToday
                          ? 'Hábito ya completado hoy'
                          : 'Completar hábito',
                      child: _AnimatedCheckButton(
                        isCompleted: isCompletedToday,
                        onTap: isCompletedToday ? null : _handleComplete,
                      ),
                    ),
              onTap: widget.onTap,
            ),
          ),
        ),
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                controller: _controller,
                fit: BoxFit.cover,
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedCheckButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback? onTap;

  const _AnimatedCheckButton({required this.isCompleted, required this.onTap});

  @override
  State<_AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<_AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onTap == null) return;

    await _controller.forward();
    await _controller.reverse();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isCompleted ? 'Hábito completado' : 'Completar hábito',
      child: GestureDetector(
        onTap: widget.isCompleted
            ? null
            : () {
                HapticFeedback.lightImpact();
                _handleTap();
              },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted ? Colors.green : Colors.transparent,
              border: widget.isCompleted
                  ? null
                  : Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: widget.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        ),
      ),
    );
  }
}

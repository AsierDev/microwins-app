import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/services/achievement_service.dart' as achievement;
import '../../../../core/notifications/notification_service.dart';
import '../../../../l10n/app_localizations.dart';

class AchievementNotification extends StatefulWidget {
  final achievement.Badge badge;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.badge,
    this.onDismiss,
  });

  @override
  State<AchievementNotification> createState() =>
      _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Iniciar animaciones
    _slideController.forward();
    _controller.forward();

    // Auto-dismiss después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });

    // Mostrar notificación del sistema para logros importantes
    _showSystemNotification();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: AnimatedOpacity(
              opacity: _fadeAnimation.value,
              duration: const Duration(milliseconds: 300),
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.badge.rarity.color.withOpacity(0.9),
                widget.badge.rarity.color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.badge.rarity.color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Animación de confeti
              Expanded(
                flex: 2,
                child: Lottie.asset(
                  'assets/animations/confetti.json',
                  controller: _controller,
                  height: 120,
                  fit: BoxFit.contain,
                  repeat: false,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Información del logro
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.badge.type.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.gamificationAchievementUnlocked,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.badge.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.badge.description,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badge.rarity.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de cerrar
              GestureDetector(
                onTap: () {
                  widget.onDismiss?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra una notificación del sistema para logros importantes
  void _showSystemNotification() {
    // Solo mostrar notificaciones del sistema para logros raros o superiores
    if (widget.badge.rarity.index >= achievement.BadgeRarity.rare.index) {
      final notificationService = NotificationService();

      // Mostrar notificación inmediata para logros importantes
      notificationService.showImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: AppLocalizations.of(context)!.gamificationNewAchievementUnlocked,
        body: '${widget.badge.name} - ${widget.badge.description}',
      );
    }
  }
}

/// Widget para mostrar múltiples notificaciones de logros apiladas
class AchievementNotificationStack extends StatefulWidget {
  final List<achievement.Badge> newBadges;
  final VoidCallback? onAllDismissed;

  const AchievementNotificationStack({
    super.key,
    required this.newBadges,
    this.onAllDismissed,
  });

  @override
  State<AchievementNotificationStack> createState() =>
      _AchievementNotificationStackState();
}

class _AchievementNotificationStackState
    extends State<AchievementNotificationStack> {
  final List<achievement.Badge> _shownBadges = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _showNextBadge();
  }

  void _showNextBadge() {
    if (_currentIndex < widget.newBadges.length) {
      setState(() {
        _shownBadges.add(widget.newBadges[_currentIndex]);
      });
      _currentIndex++;
    } else if (widget.onAllDismissed != null) {
      widget.onAllDismissed!();
    }
  }

  void _handleBadgeDismissed() {
    setState(() {
      _shownBadges.clear();
    });
    _showNextBadge();
  }

  @override
  Widget build(BuildContext context) {
    if (_shownBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    final notifications = <Widget>[];

    // Badges anteriores que se están desvaneciendo
    for (int i = 0; i < _shownBadges.length; i++) {
      final badge = _shownBadges[i];
      notifications.add(
        Positioned(
          top: 100.0 + (i * 120.0),
          left: 0,
          right: 0,
          child: AchievementNotification(
            badge: badge,
            onDismiss: () {
              setState(() {
                _shownBadges.removeAt(i);
              });
            },
          ),
        ),
      );
    }

    // Badge actual
    if (_currentIndex < widget.newBadges.length) {
      notifications.add(
        AchievementNotification(
          badge: widget.newBadges[_currentIndex],
          onDismiss: _handleBadgeDismissed,
        ),
      );
    }

    return Stack(children: notifications);
  }
}

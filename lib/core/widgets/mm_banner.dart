import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum BannerVariant { offline, error, success }

class MmBanner extends StatefulWidget {
  const MmBanner({
    super.key,
    required this.variant,
    required this.message,
    this.onDismiss,
  });

  final BannerVariant variant;
  final String message;
  final VoidCallback? onDismiss;

  @override
  State<MmBanner> createState() => _MmBannerState();
}

class _MmBannerState extends State<MmBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationMed,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss?.call());
  }

  @override
  Widget build(BuildContext context) {
    final (bg, icon) = switch (widget.variant) {
      BannerVariant.offline => (Colors.amber.shade700, Icons.wifi_off),
      BannerVariant.error => (Colors.red.shade700, Icons.error_outline),
      BannerVariant.success => (Colors.green.shade700, Icons.check_circle_outline),
    };

    return SlideTransition(
      position: _slide,
      child: Material(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMd,
            vertical: DesignTokens.spaceSm,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: DesignTokens.iconMd),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: DesignTokens.typeMd,
                  ),
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _dismiss,
                  iconSize: DesignTokens.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

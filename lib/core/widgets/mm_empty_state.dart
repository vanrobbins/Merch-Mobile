import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmEmptyState extends StatelessWidget {
  const MmEmptyState({
    super.key,
    required this.icon,
    required this.headline,
    this.body,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String headline;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Text(
              headline.toUpperCase(),
              style: const TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: DesignTokens.spaceSm),
              Text(
                body!,
                style: const TextStyle(
                  fontSize: DesignTokens.typeMd,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: DesignTokens.spaceLg),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                ),
                child: Text(ctaLabel!.toUpperCase()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

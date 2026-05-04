import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_eyebrow.dart';
import 'catalog_provider.dart';

class ProductTemplateScreen extends ConsumerWidget {
  const ProductTemplateScreen({super.key});

  static const _builtins = [
    _TemplateDef('builtin_shirt_ss',  'Short Sleeve',  'Tops',        'shirt_ss'),
    _TemplateDef('builtin_shirt_ls',  'Long Sleeve',   'Tops',        'shirt_ls'),
    _TemplateDef('builtin_tank_top',  'Tank Top',      'Tops',        'tank_top'),
    _TemplateDef('builtin_pant',      'Pant',          'Bottoms',     'pant'),
    _TemplateDef('builtin_short',     'Short',         'Bottoms',     'short'),
    _TemplateDef('builtin_jacket',    'Jacket',        'Outerwear',   'jacket'),
    _TemplateDef('builtin_dress',     'Dress',         'Tops',        'dress'),
    _TemplateDef('builtin_skirt',     'Skirt',         'Bottoms',     'skirt'),
    _TemplateDef('builtin_bag',       'Bag',           'Accessories', 'bag'),
    _TemplateDef('builtin_hat',       'Hat',           'Accessories', 'hat'),
    _TemplateDef('builtin_bra',       'Bra',           'Tops',        'bra'),
    _TemplateDef('builtin_shoe',      'Shoe',          'Accessories', 'shoe'),
    _TemplateDef('builtin_other',     'Other',         'Other',       'other'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAsync = ref.watch(productTemplatesProvider);
    final customTemplates = customAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('PRODUCT TEMPLATES')),
      body: CustomScrollView(
        slivers: [
          // Built-in templates section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                DesignTokens.spaceMd,
                DesignTokens.spaceMd,
                DesignTokens.spaceXs,
              ),
              child: MmEyebrow('BUILT-IN', padding: EdgeInsets.zero),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: DesignTokens.spaceSm,
                mainAxisSpacing: DesignTokens.spaceSm,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TemplateTile(template: _builtins[i]),
                childCount: _builtins.length,
              ),
            ),
          ),
          // Custom templates section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                DesignTokens.spaceLg,
                DesignTokens.spaceMd,
                DesignTokens.spaceXs,
              ),
              child: MmEyebrow('CUSTOM', padding: EdgeInsets.zero),
            ),
          ),
          if (customAsync.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (customTemplates.isEmpty)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: DesignTokens.spaceMd),
                  Icon(Icons.style_outlined, size: 36, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: DesignTokens.spaceSm),
                  const MmEyebrow('NO CUSTOM TEMPLATES', padding: EdgeInsets.zero),
                ],
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: DesignTokens.spaceSm,
                  mainAxisSpacing: DesignTokens.spaceSm,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final t = customTemplates[i];
                    return _TemplateTile(
                      template: _TemplateDef(t.id, t.name, t.category, t.silhouetteType),
                    );
                  },
                  childCount: customTemplates.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.spaceLg)),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});
  final _TemplateDef template;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/silhouettes/${template.silhouette}.svg',
                colorFilter: const ColorFilter.mode(AppTheme.primary, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            template.name,
            style: const TextStyle(
              fontSize: DesignTokens.typeSm,
              fontWeight: DesignTokens.weightBold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            template.category,
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateDef {
  const _TemplateDef(this.id, this.name, this.category, this.silhouette);
  final String id;
  final String name;
  final String category;
  final String silhouette;
}

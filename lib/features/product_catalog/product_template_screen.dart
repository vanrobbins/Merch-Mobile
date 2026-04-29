import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class ProductTemplateScreen extends StatelessWidget {
  const ProductTemplateScreen({super.key});

  static const _templates = [
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PRODUCT TEMPLATES')),
      body: GridView.builder(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: DesignTokens.spaceSm,
          mainAxisSpacing: DesignTokens.spaceSm,
          childAspectRatio: 0.85,
        ),
        itemCount: _templates.length,
        itemBuilder: (context, i) => _TemplateTile(template: _templates[i]),
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

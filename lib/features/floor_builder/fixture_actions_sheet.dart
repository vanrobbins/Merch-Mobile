import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'floor_builder_provider.dart';

class FixtureActionsSheet extends StatefulWidget {
  const FixtureActionsSheet({
    super.key,
    required this.fixtureId,
    required this.currentLabel,
    required this.fixtureType,
    required this.wallAdjacent,
    required this.notifier,
  });
  final String fixtureId;
  final String currentLabel;
  final String fixtureType;
  final bool wallAdjacent;
  final FloorBuilderNotifier notifier;

  @override
  State<FixtureActionsSheet> createState() => _FixtureActionsSheetState();
}

class _FixtureActionsSheetState extends State<FixtureActionsSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentLabel);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'FIXTURE OPTIONS',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              fontSize: DesignTokens.typeMd,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Label',
              border: UnderlineInputBorder(),
            ),
          ),
          if (widget.fixtureType == 'partition') ...[
            const SizedBox(height: DesignTokens.spaceSm),
            OutlinedButton(
              onPressed: () {
                widget.notifier.toggleWallAdjacent(widget.fixtureId);
                Navigator.pop(context);
              },
              child: Text(widget.wallAdjacent ? 'MARK AS FREE-STANDING' : 'MARK AS WALL-ADJACENT'),
            ),
          ],
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.notifier.renameFixture(widget.fixtureId, _ctrl.text);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                  child: const Text('RENAME'),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.notifier.rotateFixture(widget.fixtureId),
                  icon: const Icon(Icons.rotate_right, size: 16),
                  label: const Text('ROTATE'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                  onPressed: () {
                    widget.notifier.deleteFixture(widget.fixtureId);
                    Navigator.pop(context);
                  },
                  child: const Text('DELETE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

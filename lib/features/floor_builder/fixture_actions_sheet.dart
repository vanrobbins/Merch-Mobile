import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_bottom_sheet.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_text_field.dart';
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
    return MmBottomSheet(
      title: 'Fixture Options',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MmTextField(
            label: 'Label',
            controller: _ctrl,
            maxLength: 60,
          ),
          if (widget.fixtureType == 'partition') ...[
            const SizedBox(height: DesignTokens.spaceSm),
            MmButton.outlined(
              label: widget.wallAdjacent
                  ? 'Mark as Free-Standing'
                  : 'Mark as Wall-Adjacent',
              onPressed: () {
                widget.notifier.toggleWallAdjacent(widget.fixtureId);
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: MmButton.outlined(
                  label: 'Rename',
                  onPressed: () {
                    widget.notifier.renameFixture(widget.fixtureId, _ctrl.text);
                    Navigator.pop(context);
                  },
                ),
              ),
              if (widget.fixtureType != 'wall') ...[
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: MmButton.outlined(
                    label: 'Rotate',
                    icon: Icons.rotate_right,
                    onPressed: () =>
                        widget.notifier.rotateFixture(widget.fixtureId),
                  ),
                ),
              ],
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: MmButton.destructive(
                  label: 'Delete',
                  onPressed: () {
                    widget.notifier.deleteFixture(widget.fixtureId);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

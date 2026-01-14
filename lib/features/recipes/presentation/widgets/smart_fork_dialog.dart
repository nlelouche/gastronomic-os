import 'package:flutter/material.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';

class SmartForkDialog extends StatefulWidget {
  final String originalTitle;

  const SmartForkDialog({super.key, required this.originalTitle});

  @override
  State<SmartForkDialog> createState() => _SmartForkDialogState();
}

class _SmartForkDialogState extends State<SmartForkDialog> {
  final TextEditingController _customController = TextEditingController();
  String? _selectedIntent;
  List<String> _intents = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final l10n = AppLocalizations.of(context)!;
      _intents = [
        l10n.forkIntentVegan,
        l10n.forkIntentGlutenFree,
        l10n.forkIntentLowCarb,
        l10n.forkIntentSpicy,
        l10n.forkIntentKids,
        l10n.forkIntentExperiment,
      ];
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.forkTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.smartForkPrompt(widget.originalTitle), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _intents.map((intent) {
                final isSelected = _selectedIntent == intent;
                return ChoiceChip(
                  label: Text(intent),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedIntent = selected ? intent : null;
                      if (selected) {
                         // Auto-generate title based on intent
                         if (intent == l10n.forkIntentExperiment) {
                            _customController.text = '${widget.originalTitle} ${l10n.forkRemixSuffix}';
                         } else {
                            _customController.text = '$intent ${widget.originalTitle}';
                         }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customController,
              decoration: InputDecoration(
                labelText: l10n.smartForkNewTitleLabel,
                hintText: l10n.smartForkTitleHint, // Replaced placeholder hint usage for simplicity or generic
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        PrimaryButton(
          label: l10n.smartForkBtn,
          onPressed: () {
            if (_customController.text.isNotEmpty) {
              Navigator.pop(context, _customController.text);
            }
          },
        ),
      ],
    );
  }
}

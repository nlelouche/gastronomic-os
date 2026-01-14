import 'package:flutter/material.dart';
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
  
  final List<String> _intents = [
    'Make it Vegan',
    'Make it Gluten-Free',
    'Low Carb Adaptation',
    'Spicier Version',
    'Kid-Friendly',
    'Just Experimenting',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fork Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why are you forking "${widget.originalTitle}"?', style: Theme.of(context).textTheme.bodyMedium),
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
                         if (intent == 'Just Experimenting') {
                            _customController.text = '${widget.originalTitle} (Remix)';
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
              decoration: const InputDecoration(
                labelText: 'New Recipe Title',
                hintText: 'e.g. Grandma\'s Secret Version',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          label: 'Fork Recipe',
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

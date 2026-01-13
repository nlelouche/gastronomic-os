import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/data/clinical_citations.dart';

class FormattedRecipeText extends StatelessWidget {
  static const String infoLabel = 'More Info';

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const FormattedRecipeText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    if (!text.contains('[cite:')) {
      return Text(text, style: style, textAlign: textAlign);
    }

    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\[cite: ([\d, ]+)\]');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final idsStr = match.group(1);
      if (idsStr != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _CitationBadge(idsStr: idsStr, context: context),
          ),
        );
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}

class _CitationBadge extends StatelessWidget {
  final String idsStr;
  final BuildContext context;

  const _CitationBadge({required this.idsStr, required this.context});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showCitationDialog(context, idsStr),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                FormattedRecipeText.infoLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCitationDialog(BuildContext context, String idsStr) {
    final ids = idsStr.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    final List<Map<String, String>> citations = [];

    for (final id in ids) {
      if (ClinicalCitations.data.containsKey(id)) {
        citations.add({
          'id': id.toString(),
          'text': ClinicalCitations.data[id]!,
        });
      }
    }

    if (citations.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    FormattedRecipeText.infoLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...citations.map((citation) => Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "REF: ${citation['id']}",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      citation['text']!,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    if (citation != citations.last)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

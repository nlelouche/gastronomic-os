import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class AvatarSelector extends StatefulWidget {
  final String? currentAvatarPath;
  final ValueChanged<String?> onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatarPath,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  final ImagePicker _picker = ImagePicker();

  // Mock Presets for now
  final List<String> _presets = [
    'preset_dad',
    'preset_mom',
    'preset_boy',
    'preset_girl',
    'preset_grandpa',
    'preset_grandma',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        widget.onAvatarSelected(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.onboardingAvatarTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimens.spaceS),
        SizedBox(
          height: 80,
          width: double.maxFinite,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 1. Camera Option
              _buildOption(
                context,
                icon: Icons.camera_alt,
                color: theme.colorScheme.primaryContainer,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: AppDimens.spaceS),
              
              // 2. Gallery Option
              _buildOption(
                context,
                icon: Icons.photo_library,
                color: theme.colorScheme.secondaryContainer,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: AppDimens.spaceS),

              // 3. Presets
              ..._presets.map((preset) => Padding(
                padding: const EdgeInsets.only(right: AppDimens.spaceS),
                child: GestureDetector(
                  onTap: () => widget.onAvatarSelected(preset),
                  child: _buildAvatarPreview(preset, isSelected: widget.currentAvatarPath == preset),
                ),
              )),
            ],
          ),
        ),
        if (widget.currentAvatarPath != null) ...[
             const SizedBox(height: AppDimens.spaceM),
             Center(
               child: Stack(
                 children: [
                   _buildAvatarPreview(widget.currentAvatarPath!, size: 100, isSelected: true),
                   Positioned(
                     right: 0,
                     top: 0,
                     child: IconButton(
                       icon: const Icon(Icons.close, color: Colors.red),
                       onPressed: () => widget.onAvatarSelected(null),
                     ),
                   )
                 ],
               ),
             ),
        ]
      ],
    );
  }

  Widget _buildOption(BuildContext context, {required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildAvatarPreview(String path, {double size = 60, bool isSelected = false}) {
    final theme = Theme.of(context);
    Widget content;

    if (path.startsWith('preset_')) {
      // Mock rendering for presets
      IconData icon;
      Color color;
      switch(path) {
        case 'preset_dad': icon = Icons.man; color = Colors.blue.shade200; break;
        case 'preset_mom': icon = Icons.woman; color = Colors.pink.shade200; break;
        case 'preset_boy': icon = Icons.boy; color = Colors.blue.shade100; break;
        case 'preset_girl': icon = Icons.girl; color = Colors.pink.shade100; break;
        case 'preset_grandpa': icon = Icons.elderly; color = Colors.grey.shade400; break;
        case 'preset_grandma': icon = Icons.elderly_woman; color = Colors.purple.shade200; break;
        default: icon = Icons.face; color = Colors.grey;
      }
      content = CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: Icon(icon, size: size * 0.6, color: Colors.white),
      );
    } else {
      // Local File
      content = CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(path)),
      );
    }

    return Container(
      decoration: isSelected ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 3),
      ) : null,
      child: content,
    );
  }
}

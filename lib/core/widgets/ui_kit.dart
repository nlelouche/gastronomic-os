import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Import AppTheme to ensure consistency if needed, though Shadcn handles its own
// We will wrap Shadcn widgets or create custom ones that match our FlexColorScheme

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Mapping Material Theme colors to Shadcn-like button
    // ShadcnUI uses its own theme data, but we can style standard buttons to look simpler 
    // or use ShadcnButton directly if configured. 
    // For now, let's create a "Unicorn" styled Material button that fits the theme.
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final DecorationImage? backgroundImage;

  const AppCard({
    super.key, 
    required this.child, 
    this.padding, 
    this.onTap,
    this.backgroundColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        image: backgroundImage,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimens.paddingCard),
            child: child,
          ),
        ),
      ),
    );
  }
}

enum PillType { allergy, lifestyle, diet, neutral }

class SemanticPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final PillType type;

  const SemanticPill({
    super.key,
    required this.label,
    this.icon,
    this.type = PillType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case PillType.allergy:
        color = const Color(0xFFFF453A);
        break;
      case PillType.lifestyle:
        color = const Color(0xFF30D158);
        break;
      case PillType.diet:
        color = const Color(0xFF0A84FF);
        break;
      case PillType.neutral:
      default:
        color = Theme.of(context).colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchBadge extends StatelessWidget {
  final double score; // 0.0 to 100.0

  const MatchBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final percent = score / 100;
    
    // Determine color based on score
    Color color = const Color(0xFFCCFF00); // Neon Lime
    if (percent < 0.7) color = Colors.orange;
    if (percent < 0.4) color = Colors.red;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '${score.toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// A container that emits a colored glow, simulating neon lighting.
/// Ideal for high-emphasis cards or featured items.
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity; // 0.0 to 1.0 (subtle to radio-active)
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.intensity = 0.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If it's light mode, we might want to darken the glow nicely or keep it.
    // For "Neon", dark themes work best, but let's make it adaptive.
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Base background
        borderRadius: borderRadius,
        boxShadow: [
          // The "Glow" - Outer soft light
          BoxShadow(
            color: glowColor.withOpacity(0.25 * intensity), // Lower opacity for elegance
            blurRadius: 16 * intensity, // Tighter blur for "High Res" feel
            spreadRadius: 0, // No negative spread, just natural falloff
            offset: const Offset(0, 4),
          ),
          // Inner/Sharper shadow for depth
          BoxShadow(
            color: glowColor.withOpacity(0.15 * intensity),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        // Subtle Border to define edges against the glow
        border: Border.all(
          color: glowColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }
}

/// A premium glassmorphism container with gradient borders and shine.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Gradient? borderGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.08,
    this.borderRadius,
    this.padding,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    
    // Performance Optimization: If blur is 0, skip expensive BackdropFilter entirely
    // and just use the semi-transparent overlay.
    Widget content = Container(
      decoration: BoxDecoration(
        // Stronger fill if blur is disabled to simulate glass
        color: Theme.of(context).colorScheme.surface.withOpacity(blur > 0 ? opacity : opacity + 0.1),
        borderRadius: br,
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Container(
         // Inner gradient for "sheen"
         decoration: BoxDecoration(
           borderRadius: br,
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Colors.white.withOpacity(0.2), 
               Colors.white.withOpacity(0.0),
               Colors.white.withOpacity(0.0),
               Colors.white.withOpacity(0.05),
             ],
             stops: const [0.0, 0.4, 0.6, 1.0],
           ),
         ),
         padding: padding,
         child: child,
      ),
    );

    if (blur > 0) {
      return ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: br,
        child: content,
      );
    }
  }
}

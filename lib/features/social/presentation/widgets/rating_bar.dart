import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final ValueChanged<int>? onRatingChanged;

  const RatingBar({
     super.key,
     required this.rating,
     this.maxRating = 5,
     this.size = 20,
     this.color,
     this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
         final starIndex = index + 1;
         IconData iconData;
         
         if (rating >= starIndex) {
           iconData = Icons.star;
         } else if (rating >= starIndex - 0.5) {
           iconData = Icons.star_half;
         } else {
           iconData = Icons.star_border;
         }

         return GestureDetector(
           onTap: onRatingChanged != null ? () => onRatingChanged!(starIndex) : null,
           child: Icon(iconData, color: activeColor, size: size),
         );
      }),
    );
  }
}

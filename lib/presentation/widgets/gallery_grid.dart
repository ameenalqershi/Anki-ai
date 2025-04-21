import 'package:flutter/material.dart';

class GalleryGrid extends StatelessWidget {
  final List<String> images;
  const GalleryGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final itemCount = images.length.clamp(1, 4);
    return SizedBox(
      width: 210,
      child: GridView.count(
        crossAxisCount: itemCount >= 3 ? 2 : 1,
        shrinkWrap: true,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        physics: const NeverScrollableScrollPhysics(),
        children:
            images.take(4).map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                ),
              );
            }).toList(),
      ),
    );
  }
}

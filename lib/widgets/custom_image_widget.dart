import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a network image
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              SizedBox(
                width: width,
                height: height,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                  ),
                ),
              );
        },
      );
    }

    // Check if it's an SVG (this would need flutter_svg package)
    if (imagePath.endsWith('.svg')) {
      // For now, show a placeholder since we need to handle SVG differently
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.image,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Handle local asset images
    try {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              SizedBox(
                width: width,
                height: height,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                ),
              );
        },
      );
    } catch (e) {
      return errorWidget ??
          SizedBox(
            width: width,
            height: height,
            child: Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            ),
          );
    }
  }
}
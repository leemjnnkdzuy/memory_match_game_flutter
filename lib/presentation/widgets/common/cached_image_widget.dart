import 'package:flutter/material.dart';
import '../../../services/image_cache_service.dart';

class CachedImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CachedImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imageCacheService = ImageCacheService();
    
    if (!imageCacheService.allImagesReady) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey, size: 32),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Image.asset(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.red[200],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red, size: 32),
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return SizedBox(
            width: width,
            height: height,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

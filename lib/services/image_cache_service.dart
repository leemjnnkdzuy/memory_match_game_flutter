import 'package:flutter/material.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  bool _allImagesLoaded = false;

  Future<void> preloadImage(String imagePath, BuildContext context) async {
    try {
      final imageProvider = AssetImage(imagePath);
      await precacheImage(imageProvider, context);
    } catch (e) {
      print('Failed to preload $imagePath: $e');
    }
  }

  void markAllImagesLoaded() {
    _allImagesLoaded = true;
  }

  bool get allImagesReady => _allImagesLoaded;

  void clearCache() {
    _allImagesLoaded = false;
  }

  Map<String, dynamic> getCacheInfo() {
    return {
      'allImagesReady': _allImagesLoaded,
      'cacheType': 'Flutter built-in PNG cache',
    };
  }
}

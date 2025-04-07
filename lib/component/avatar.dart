import 'dart:html';
import 'dart:ui_web';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final double width;
  final String? imageUrl;

  const UserAvatar({super.key, this.imageUrl = '', required this.width});

  @override
  Widget build(BuildContext context) {
    String photoSource = imageUrl ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(width),
      child: CachedNetworkImage(
        imageUrl: photoSource,
        width: width,
        height: width,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          print("Error loading image: $error");
          return Image.asset(
            'assets/images/profile.png',
            width: width,
            height: width,
            fit: BoxFit.cover,
          );
        },
        placeholder: (context, url) => Container(
          width: width,
          height: width,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    ); 
  }
}

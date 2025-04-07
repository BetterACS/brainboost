import 'dart:html';
import 'dart:ui_web';

import 'package:cached_network_image/cached_network_image.dart';
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
      child: Image(image: CachedNetworkImageProvider(photoSource))
    ); 
  }
}

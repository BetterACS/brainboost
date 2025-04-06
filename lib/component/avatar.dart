import 'dart:html';
import 'dart:ui_web';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// some other libraries

class UserAvatar extends StatelessWidget {
  final double width;
  final String? imageUrl;

  const UserAvatar({super.key, this.imageUrl = '', required this.width});

  @override
  Widget build(BuildContext context) {
    String photoSource = imageUrl ?? '';

    if (photoSource.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(width),
        child: Image.asset(
          "assets/images/profile.jpg",
          width: width,
          height: width,
          fit: BoxFit.cover,
        ),
      );
    }

    if (kIsWeb) {
      platformViewRegistry.registerViewFactory(photoSource, (_) {
        final element = ImageElement();

        element.src = photoSource;
        element.style.width = '100%';
        element.style.height = '100%';

        return element;
      });

      return ClipRRect(
          borderRadius: BorderRadius.circular(width),
          child: SizedBox(
              width: width,
              height: width,
              child: HtmlElementView(
                viewType: photoSource,
              )));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(width),
      child: CachedNetworkImage(
          imageUrl: photoSource,
          width: width,
          height: width,
          placeholder: (context, url) => CircularProgressIndicator(
                // color: SuperTheme.lightThemeColors['mainYellow'],
              ),
          errorWidget: (context, url, error) => Image.asset(
                "assets/images/profile.jpg",
                width: width,
                height: width,
              )),
    );
  }
}

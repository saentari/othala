import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/unsplash_image.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';

// ImageTile displayed in StaggeredGridView.
class ImageTile extends StatefulWidget {
  final UnsplashImage? image;
  final String? walletImageId;
  final int walletIndex;

  const ImageTile(this.image, this.walletImageId, this.walletIndex, {Key? key})
      : super(key: key);

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  // Adds rounded corners to a given [widget].
  Widget addRoundedCorners(Widget widget) =>
      // Wrap in ClipRRect to achieve rounded corners.
      ClipRRect(borderRadius: BorderRadius.circular(12), child: widget);

  // Returns a placeholder to show until an image is loaded.
  Widget buildImagePlaceholder({UnsplashImage? image}) => Container(
        color: image != null
            ? Color(int.parse(image.getColor().substring(1, 7), radix: 16) +
                0x64000000)
            : Colors.grey[200],
      );

  // Returns a error placeholder to show until an image is loaded.
  Widget buildImageErrorWidget() => Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400])));

  @override
  Widget build(BuildContext context) {
    final WalletManager walletManager = WalletManager(Hive.box('walletBox'));

    return InkWell(
      onTap: () async {
        await walletManager.setWalletBackground(
            widget.walletIndex, widget.image!);
        if (!mounted) return;
        Navigator.pop(context);
      },
      // Hero Widget for Hero animation with [ImagePage].
      child: widget.image != null
          ? Hero(
              tag: widget.image!.getId(),
              child: addRoundedCorners(
                Stack(fit: StackFit.expand, children: [
                  Positioned(
                    child: CachedNetworkImage(
                      imageUrl: widget.image!.getSmallUrl(),
                      placeholder: (context, url) =>
                          buildImagePlaceholder(image: widget.image),
                      errorWidget: (context, url, obj) =>
                          buildImageErrorWidget(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 8.0) / 2,
                      color: customDarkBackground.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.image!.getUser().getName(),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.walletImageId == widget.image!.getId(),
                    child: const Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: customYellow,
                        size: 28,
                      ),
                    ),
                  ),
                ]),
              ),
            )
          : buildImagePlaceholder(),
    );
  }
}

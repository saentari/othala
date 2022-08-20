import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/unsplash_image.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
// import '../screens/image_screen.dart';

/// ImageTile displayed in StaggeredGridView.
class ImageTile extends StatelessWidget {
  final UnsplashImage? image;
  final String? walletImageId;
  final int walletIndex;

  const ImageTile(this.image, this.walletImageId, this.walletIndex, {Key? key})
      : super(key: key);

  /// Adds rounded corners to a given [widget].
  Widget _addRoundedCorners(Widget widget) =>
      // wrap in ClipRRect to achieve rounded corners
      ClipRRect(borderRadius: BorderRadius.circular(12), child: widget);

  /// Returns a placeholder to show until an image is loaded.
  Widget _buildImagePlaceholder({UnsplashImage? image}) => Container(
        color: image != null
            ? Color(int.parse(image.getColor().substring(1, 7), radix: 16) +
                0x64000000)
            : Colors.grey[200],
      );

  /// Returns a error placeholder to show until an image is loaded.
  Widget _buildImageErrorWidget() => Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400])));

  @override
  Widget build(BuildContext context) {
    final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));

    return InkWell(
      onTap: () async {
        await _walletManager.changeWalletBackgroundImage(walletIndex, image!);
        Navigator.pop(context);
        // item onclick
        // if (image != null) {
        //   Navigator.of(context).push(
        //     MaterialPageRoute<Null>(
        //       builder: (BuildContext context) =>
        //           // open [ImagePage] with the given image
        //           ImagePage(image!.getId(), image!.getFullUrl()),
        //     ),
        //   );
        // }
      },
      // Hero Widget for Hero animation with [ImagePage]
      child: image != null
          ? Hero(
              tag: image!.getId(),
              child: _addRoundedCorners(
                Stack(fit: StackFit.expand, children: [
                  Positioned(
                    child: CachedNetworkImage(
                      imageUrl: image!.getSmallUrl(),
                      placeholder: (context, url) =>
                          _buildImagePlaceholder(image: image),
                      errorWidget: (context, url, obj) =>
                          _buildImageErrorWidget(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 8.0) / 2,
                      color: kDarkBackgroundColor.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          image!.getUser().getName(),
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
                    visible: walletImageId == image!.getId(),
                    child: const Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: kYellowColor,
                        size: 28,
                      ),
                    ),
                  ),
                ]),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }
}

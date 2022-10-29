import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/unsplash_image.dart';
import '../../models/wallet.dart';
import '../../services/unsplash_image_provider.dart';
import '../../widgets/image_tile.dart';

class WalletBackgroundViewModel extends ChangeNotifier {
  late Wallet wallet;
  late int walletIndex;

  // Stores the current page index for the api requests.
  int page = 0, totalPages = -1;

  // Stores the currently loaded loaded images.
  List<UnsplashImage> unsplashImages = [];

  // States whether there is currently a task running loading images.
  bool loadingImages = false;

  // Stored the currently searched keyword.
  String? keyword;

  void initialise(BuildContext context) {
    walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    var box = Hive.box('walletBox');
    if (walletIndex < box.length) {
      wallet = box.getAt(walletIndex);
    }

    // initial image Request
    loadImages(keyword: 'nature');
    notifyListeners();
  }

  // Requests a list of [UnsplashImage] for a given [keyword].
  //
  // If the given [keyword] is null, trending images are loaded.
  loadImages({String? keyword}) async {
    // Check if there is currently a loading task running.
    if (loadingImages) {
      // There is currently a task running.
      return;
    }
    // Check if all pages are already loaded.
    if (totalPages != -1 && page >= totalPages) {
      // All pages already loaded.
      return;
    }
    // Set loading state.
    //
    // Delay setState, otherwise: Unhandled Exception: setState()
    // or markNeedsBuild() called during build.
    await Future.delayed(const Duration(microseconds: 1));

    // Set loading.
    loadingImages = true;
    // Check if new search.
    if (this.keyword != keyword) {
      // Clear images and reset page counter for new search.
      unsplashImages = [];
      page = 0;
    }
    // Keyword null.
    this.keyword = keyword;
    // Update the state.
    notifyListeners();

    // Load images.
    List<UnsplashImage>? images;
    if (keyword != null && keyword.isNotEmpty) {
      // Load images from the next page with a keyword.
      List res = await UnsplashImageProvider.loadImagesWithKeyword(keyword,
          page: ++page);
      // Set totalPages.
      totalPages = res[0];
      // Set images.
      images = res[1];
    } else {
      // Load images from the next page of trending images.
      images = (await UnsplashImageProvider.loadImages(page: ++page))
          .cast<UnsplashImage>();
    }
    // Done loading.
    loadingImages = false;
    // Set new loaded images.
    unsplashImages.addAll(images!);
    // Update the state.
    notifyListeners();
  }

  // Returns the grid that displays images.
  //
  // [orientation] can be used to adjust the grid column count.
  Widget buildImageGrid(BuildContext context, int walletIndex,
      {orientation = Orientation.portrait}) {
    // Calculate [columnCount] based on orientation.
    var columnCount = orientation == Orientation.portrait ? 2 : 3;
    // Return staggered grid.
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverStaggeredGrid.countBuilder(
        // Set column count.
        crossAxisCount: columnCount,
        itemCount: unsplashImages.length,
        // Set itemBuilder.
        itemBuilder: (BuildContext context, int index) =>
            buildImageItemBuilder(context, index, walletIndex),
        staggeredTileBuilder: (int index) =>
            buildStaggeredTile(context, unsplashImages[index], columnCount),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
    );
  }

  // Returns a FutureBuilder to load a [UnsplashImage] for a given [index].
  Widget buildImageItemBuilder(
      BuildContext context, int imageIndex, int walletIndex) {
    return FutureBuilder(
      // Pass image loader.
      future: loadImage(imageIndex),
      builder: (context, snapshot) {
        // Image loaded return [_ImageTile].
        UnsplashImage? image;
        if (snapshot.data != null) {
          image = snapshot.data as UnsplashImage;
        }
        return ImageTile(image, wallet.imageId, walletIndex);
      },
    );
  }

  // Returns a StaggeredTile for a given [image].
  StaggeredTile buildStaggeredTile(
      BuildContext context, UnsplashImage image, int columnCount) {
    // Calculate image aspect ratio.
    var aspectRatio =
        image.getHeight().toDouble() / image.getWidth().toDouble();
    // Calculate column width.
    var columnWidth = MediaQuery.of(context).size.width / columnCount;
    // Not using [StaggeredTile.fit(1)] because during loading StaggeredGrid is really jumpy.
    return StaggeredTile.extent(1, aspectRatio * columnWidth);
  }

  // Asynchronously loads a [UnsplashImage] for a given [index].
  Future<UnsplashImage?> loadImage(int index) async {
    // Check if new images need to be loaded.
    if (index >= unsplashImages.length - 2) {
      // Reached the end of the list. Try to load more images.
      loadImages(keyword: keyword);
    }
    return index < unsplashImages.length ? unsplashImages[index] : null;
  }
}

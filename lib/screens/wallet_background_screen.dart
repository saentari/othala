import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othala/widgets/safe_area.dart';

import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/unsplash_image_provider.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/image_tile.dart';
import '../widgets/loading_indicator.dart';

class WalletBackgroundScreen extends StatefulWidget {
  const WalletBackgroundScreen({Key? key}) : super(key: key);

  @override
  WalletBackgroundScreenState createState() => WalletBackgroundScreenState();
}

class WalletBackgroundScreenState extends State<WalletBackgroundScreen> {
  late Wallet _wallet;

  /// Stores the current page index for the api requests.
  int page = 0, totalPages = -1;

  /// Stores the currently loaded loaded images.
  List<UnsplashImage> _images = [];

  /// States whether there is currently a task running loading images.
  bool loadingImages = false;

  /// Stored the currently searched keyword.
  String? keyword;

  @override
  void initState() {
    super.initState();
    // initial image Request
    _loadImages(keyword: 'nature');
  }

  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    return ValueListenableBuilder(
        valueListenable: Hive.box('walletBox').listenable(),
        builder: (context, Box box, widget2) {
          if (walletIndex < box.length) {
            _wallet = box.getAt(walletIndex);
          }
          return SafeAreaX(
            appBar: AppBar(
              centerTitle: true,
              title: titleIcon,
              backgroundColor: kBlackColor,
              automaticallyImplyLeading: false,
            ),
            bottomBar: GestureDetector(
              onTap: () => {Navigator.pop(context)},
              child: const CustomFlatButton(
                textLabel: 'Cancel',
                buttonColor: kDarkBackgroundColor,
                fontColor: kWhiteColor,
              ),
            ),
            child: OrientationBuilder(
              builder: (context, orientation) => CustomScrollView(
                slivers: [
                  //Grid view with all the images
                  _buildImageGrid(walletIndex, orientation: orientation),

                  // loading indicator at the bottom of the list
                  const SliverToBoxAdapter(
                    child: LoadingIndicator(kDarkNeutral5Color),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Requests a list of [UnsplashImage] for a given [keyword].
  //
  // If the given [keyword] is null, trending images are loaded.
  _loadImages({String? keyword}) async {
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
    setState(() {
      // Set loading.
      loadingImages = true;
      // Check if new search.
      if (this.keyword != keyword) {
        // Clear images and reset page counter for new search.
        _images = [];
        page = 0;
      }
      // Keyword null.
      this.keyword = keyword;
    });

    // Load images.
    List<UnsplashImage>? images;
    if (keyword == null) {
      // Load images from the next page of trending images.
      images = (await UnsplashImageProvider.loadImages(page: ++page))
          .cast<UnsplashImage>();
    } else {
      // Load images from the next page with a keyword.
      List res = await UnsplashImageProvider.loadImagesWithKeyword(keyword,
          page: ++page);
      // Set totalPages.
      totalPages = res[0];
      // Set images.
      images = res[1];
    }

    // Update the state.
    setState(() {
      // Done loading.
      loadingImages = false;
      // Set new loaded images.
      _images.addAll(images!);
    });
  }

  // Returns the grid that displays images.
  //
  // [orientation] can be used to adjust the grid column count.
  Widget _buildImageGrid(walletIndex, {orientation = Orientation.portrait}) {
    // Calculate [columnCount] based on orientation.
    int columnCount = orientation == Orientation.portrait ? 2 : 3;
    // Return staggered grid.
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverStaggeredGrid.countBuilder(
        // Set column count.
        crossAxisCount: columnCount,
        itemCount: _images.length,
        // Set itemBuilder.
        itemBuilder: (BuildContext context, int index) =>
            _buildImageItemBuilder(index, walletIndex),
        staggeredTileBuilder: (int index) =>
            _buildStaggeredTile(_images[index], columnCount),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
    );
  }

  // Returns a FutureBuilder to load a [UnsplashImage] for a given [index].
  Widget _buildImageItemBuilder(int imageIndex, int walletIndex) {
    return FutureBuilder(
      // Pass image loader.
      future: _loadImage(imageIndex),
      builder: (context, snapshot) {
        // Image loaded return [_ImageTile].
        UnsplashImage? image;
        if (snapshot.data != null) {
          image = snapshot.data as UnsplashImage;
        }
        return ImageTile(image, _wallet.imageId, walletIndex);
      },
    );
  }

  // Returns a StaggeredTile for a given [image].
  StaggeredTile _buildStaggeredTile(UnsplashImage image, int columnCount) {
    // Calculate image aspect ratio.
    double aspectRatio =
        image.getHeight().toDouble() / image.getWidth().toDouble();
    // Calculate column width.
    double columnWidth = MediaQuery.of(context).size.width / columnCount;
    // Not using [StaggeredTile.fit(1)] because during loading StaggeredGrid is really jumpy.
    return StaggeredTile.extent(1, aspectRatio * columnWidth);
  }

  // Asynchronously loads a [UnsplashImage] for a given [index].
  Future<UnsplashImage?> _loadImage(int index) async {
    // Check if new images need to be loaded.
    if (index >= _images.length - 2) {
      // Reached the end of the list. Try to load more images.
      _loadImages(keyword: keyword);
    }
    return index < _images.length ? _images[index] : null;
  }
}

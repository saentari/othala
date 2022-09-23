import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othala/models/unsplash_image.dart';

import '../models/wallet.dart';
import '../services/unsplash_image_provider.dart';
import '../themes/theme_data.dart';
import '../widgets/image_tile.dart';
import '../widgets/loading_indicator.dart';

class WalletBackgroundScreen extends StatefulWidget {
  const WalletBackgroundScreen({Key? key}) : super(key: key);

  // const WalletBackgroundScreen(this.walletIndex, {Key? key}) : super(key: key);
  //
  // final int walletIndex;

  @override
  _WalletBackgroundScreenState createState() => _WalletBackgroundScreenState();
}

class _WalletBackgroundScreenState extends State<WalletBackgroundScreen> {
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
    final _walletIndex = ModalRoute.of(context)!.settings.arguments as int;
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: Hive.box('walletBox').listenable(),
          builder: (context, Box box, widget2) {
            if (_walletIndex < box.length) {
              _wallet = box.getAt(_walletIndex);
            }
            return Scaffold(
              body: OrientationBuilder(
                builder: (context, orientation) => CustomScrollView(
                  slivers: [
                    //App bar
                    _buildSearchAppBar(),

                    //Grid view with all the images
                    _buildImageGrid(_walletIndex, orientation: orientation),

                    // loading indicator at the bottom of the list
                    const SliverToBoxAdapter(
                      child: LoadingIndicator(kDarkNeutral5Color),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  /// Requests a list of [UnsplashImage] for a given [keyword].
  /// If the given [keyword] is null, trending images are loaded.
  _loadImages({String? keyword}) async {
    // check if there is currently a loading task running
    if (loadingImages) {
      // there is currently a task running
      return;
    }
    // check if all pages are already loaded
    if (totalPages != -1 && page >= totalPages) {
      // all pages already loaded
      return;
    }
    // set loading state
    // delay setState, otherwise: Unhandled Exception: setState() or markNeedsBuild() called during build.
    await Future.delayed(const Duration(microseconds: 1));
    setState(() {
      // set loading
      loadingImages = true;
      // check if new search
      if (this.keyword != keyword) {
        // clear images for new search
        _images = [];
        // reset page counter
        page = 0;
      }
      // keyword null
      this.keyword = keyword;
    });

    // load images
    List<UnsplashImage>? images;
    if (keyword == null) {
      // load images from the next page of trending images
      images = (await UnsplashImageProvider.loadImages(page: ++page))
          .cast<UnsplashImage>();
    } else {
      // load images from the next page with a keyword
      List res = await UnsplashImageProvider.loadImagesWithKeyword(keyword,
          page: ++page);
      // set totalPages
      totalPages = res[0];
      // set images
      images = res[1];
    }

    // TODO: handle errors

    // update the state
    setState(() {
      // done loading
      loadingImages = false;
      // set new loaded images
      _images.addAll(images!);
    });
  }

  /// Returns the SearchAppBar.
  Widget _buildSearchAppBar() {
    return SliverAppBar(
      title: SvgPicture.asset(
        'assets/icons/logo.svg',
        color: kYellowColor,
        height: 40.0,
      ),
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  /// Returns the grid that displays images.
  /// [orientation] can be used to adjust the grid column count.
  Widget _buildImageGrid(walletIndex, {orientation = Orientation.portrait}) {
    // calc columnCount based on orientation
    int columnCount = orientation == Orientation.portrait ? 2 : 3;
    // return staggered grid
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverStaggeredGrid.countBuilder(
        // set column count
        crossAxisCount: columnCount,
        itemCount: _images.length,
        // set itemBuilder
        itemBuilder: (BuildContext context, int index) =>
            _buildImageItemBuilder(index, walletIndex),
        staggeredTileBuilder: (int index) =>
            _buildStaggeredTile(_images[index], columnCount),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
    );
  }

  /// Returns a FutureBuilder to load a [UnsplashImage] for a given [index].
  Widget _buildImageItemBuilder(int imageIndex, int walletIndex) {
    return FutureBuilder(
      // pass image loader
      future: _loadImage(imageIndex),
      builder: (context, snapshot) {
        // image loaded return [_ImageTile]
        UnsplashImage? _image;
        if (snapshot.data != null) {
          _image = snapshot.data as UnsplashImage;
        }
        return ImageTile(_image, _wallet.imageId, walletIndex);
      },
    );
  }

  /// Returns a StaggeredTile for a given [image].
  StaggeredTile _buildStaggeredTile(UnsplashImage image, int columnCount) {
    // calc image aspect ration
    double aspectRatio =
        image.getHeight().toDouble() / image.getWidth().toDouble();
    // calc columnWidth
    double columnWidth = MediaQuery.of(context).size.width / columnCount;
    // not using [StaggeredTile.fit(1)] because during loading StaggeredGrid is really jumpy.
    return StaggeredTile.extent(1, aspectRatio * columnWidth);
  }

  /// Asynchronously loads a [UnsplashImage] for a given [index].
  Future<UnsplashImage?> _loadImage(int index) async {
    // check if new images need to be loaded
    if (index >= _images.length - 2) {
      // Reached the end of the list. Try to load more images.
      _loadImages(keyword: keyword);
    }
    return index < _images.length ? _images[index] : null;
  }
}

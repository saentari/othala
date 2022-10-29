import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import 'loading_view_model.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoadingViewModel>.nonReactive(
      viewModelBuilder: () => LoadingViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => Container(
        color: customDarkBackground,
        child: SafeArea(
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                left: 8.0,
                right: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Center(child: logoTextIcon),
                  const Spacer(),
                  const Text(
                    'Your keys, your bitcoin.\n100% open-source & open-design',
                    style: TextStyle(
                        color: customDarkNeutral7,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:azan_app/ads/banner_ad_widget.dart';
import 'package:flutter/material.dart';

class StickyBottomBannerAd extends StatelessWidget {
  const StickyBottomBannerAd({super.key, this.topSpacing = 8});

  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: topSpacing),
          const Align(
            alignment: Alignment.center,
            child: BannerAdWidget(),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/promo_card_widget.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final double height;
  const NativeAdWidget({super.key, this.height = 120});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget>
    with SingleTickerProviderStateMixin {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _adFailed = false;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  static String get _adUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2247696110'
          : const String.fromEnvironment('ADMOB_NATIVE_AD_UNIT_ANDROID',
              defaultValue: 'ca-app-pub-3940256099942544/2247696110');
    } else {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/3986624511'
          : const String.fromEnvironment('ADMOB_NATIVE_AD_UNIT_IOS',
              defaultValue: 'ca-app-pub-3940256099942544/3986624511');
    }
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: AppDimensions.animationDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    if (!ref.read(isPremiumProvider)) {
      _loadAd();
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'glassCardAd',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isAdLoaded = true);
            _slideController.forward();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _isAdLoaded = false;
              _adFailed = true;
            });
          }
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return const SizedBox.shrink();
    final isOnline = ref.watch(isOnlineProvider);
    if (_adFailed || !isOnline) return PromoCardWidget(height: widget.height);

    final colors = Theme.of(context).colorScheme;

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: !_isAdLoaded || _nativeAd == null
          ? null
          : SlideTransition(
              position: _slideAnimation,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppDimensions.borderRadiusAll,
                    child: AdWidget(ad: _nativeAd!),
                  ),
                  Positioned(
                    top: 4,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Anzeige',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

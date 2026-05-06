import UIKit
import Flutter
import google_mobile_ads
import GoogleMobileAds

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let factory = GlassCardNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self, factoryId: "glassCardAd", nativeAdFactory: factory
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class GlassCardNativeAdFactory: FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]?
  ) -> GADNativeAdView? {
    let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)
    guard let adView = nibObjects?.first as? GADNativeAdView else {
      return nil
    }

    (adView.headlineView as? UILabel)?.text = nativeAd.headline
    (adView.bodyView as? UILabel)?.text = nativeAd.body
    adView.bodyView?.isHidden = nativeAd.body == nil

    (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    adView.iconView?.isHidden = nativeAd.icon == nil

    adView.nativeAd = nativeAd
    return adView
  }
}

import Foundation
import google_mobile_ads
import GoogleMobileAds

class GlassCardNativeAdFactory: FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [String: Any]? = nil
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

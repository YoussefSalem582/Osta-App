import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Key flows Secrets.xcconfig -> Info.plist(GMSApiKey) -> here, so no literal
    // ever lands in source. Unlike Android (which just renders blank tiles), the
    // Maps iOS SDK throws an uncaught GMSServicesException the moment a
    // GMSMapView is built without a key — so a missing key is fatal, and the
    // assert makes it fail at launch with the fix rather than on the map tab.
    let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
    if !mapsApiKey.isEmpty, !mapsApiKey.hasPrefix("$(") {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      assertionFailure(
        "MAPS_API_KEY missing. Create ios/Flutter/Secrets.xcconfig (git-ignored) "
          + "containing MAPS_API_KEY=<key>. Without it the map tab crashes."
      )
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

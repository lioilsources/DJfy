import AVFoundation
import AVKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Party mode: the phone is the source, AirPlay/Bluetooth speakers are just
    // outputs. `.playback` keeps audio going with the screen locked and
    // allows AirPlay 2 routing.
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DjfyAirPlay") {
      registrar.register(AirPlayButtonFactory(), withId: "djfy/airplay")
    }
  }
}

/// `AVRoutePickerView` exposed to Flutter as the `djfy/airplay` platform view.
final class AirPlayButtonFactory: NSObject, FlutterPlatformViewFactory {
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    AirPlayButtonView(frame: frame)
  }
}

final class AirPlayButtonView: NSObject, FlutterPlatformView {
  private let picker: AVRoutePickerView

  init(frame: CGRect) {
    picker = AVRoutePickerView(frame: frame)
    picker.tintColor = UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.6)
    picker.activeTintColor = UIColor(red: 0, green: 0.9, blue: 1, alpha: 1)
    picker.backgroundColor = .clear
    super.init()
  }

  func view() -> UIView { picker }
}

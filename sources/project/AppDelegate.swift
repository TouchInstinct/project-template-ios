import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private(set) lazy var appWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)

        self.window = window

        return window
    }()

    static var shared: AppDelegate {
        let delegate = UIApplication.shared.delegate

        guard let appDelegate = delegate as? AppDelegate else {
            fatalError("Cannot cast \(type(of: delegate)) to AppDelegate")
        }

        return appDelegate
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])
        return true
    }
}

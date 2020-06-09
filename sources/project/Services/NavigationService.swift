import UIKit

enum NavigationService {
    static var appWindow: UIWindow {
        return AppDelegate.shared.appWindow
    }
}

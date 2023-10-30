import Turbo
import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigationController = UINavigationController()
    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"

        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        return session
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        visit()
    }

    private func visit() {
        let url = URL(string: "https://turbo-native-demo.glitch.me")!
        let controller = VisitableViewController(url: url)
        session.visit(controller, action: .advance)
        navigationController.pushViewController(controller, animated: true)
    }
}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: VisitProposal) {
        let controller = VisitableViewController(url: proposal.url)
        session.visit(controller, options: proposal.options)
        navigationController.pushViewController(controller, animated: true)
    }

    func session(_ session: Turbo.Session, didFailRequestForVisitable visitable: Turbo.Visitable, error: Error) {
        if let turboError = error as? TurboError {
            switch turboError {
            case .http(let statusCode):
                // Display or handle the HTTP error code
                print(error)
                print(statusCode)
                print("status code")
            case .networkFailure, .timeoutFailure:
                // Display appropriate error messages
                print(error)
                print("Network or timeout failure")
            case .contentTypeMismatch:
                print(error)
                print("Content Type Mismatch")
            case .pageLoadFailure:
                print("page load failure?")
                print(error)
                print(turboError.localizedDescription)
            }
        } else {
            // Display the network failure or retry the visit
            print("In the Else?")
        }

    }

    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle dead web view.
    }
}

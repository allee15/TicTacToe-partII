//
//  Navigation.swift
//  x&0Game
//
//  Created by Alexia Aldea on 20.04.2024.
//

import Foundation
import UIKit
import SwiftUI
import SafariServices

protocol NavigationDestination {
    var tag: String? { get }
}

fileprivate struct ViewDestination: NavigationDestination {
    var tag: String?
    var view: AnyView
}

extension View {
    func asDestination() -> NavigationDestination {
        return ViewDestination(view: AnyView(self))
    }
}

protocol NavigationHost: NSObject, ObservableObject {
    func replaceNavigationStack(_ views: [NavigationDestination], animated: Bool)
    func push(_ dest: NavigationDestination, animated: Bool)
    func push(_ dest: BaseNavigationController, animated: Bool)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func removeFromStack(tag: String)
    
    func presentModal(
        _ dest: NavigationDestination,
        animated: Bool,
        completion: (() -> (Void))?,
        controllerConfig: ((UIViewController) -> Void)?
    )
    
    func presentPopup(
        _ dest: NavigationDestination,
        animated: Bool,
        completion: (() -> (Void))?
    )
    
    func dismissModal(animated: Bool, completion: (() -> (Void))?)
}

final class Navigation: NSObject {
    @Published private(set) var currentTag: String?
    @Published private(set) var stackSize: Int = 1
    
    let navigationController: UINavigationController
    
    override init() {
        navigationController = UINavigationController(rootViewController: UIViewController())
        super.init()
        navigationController.delegate = self
    }
    
    convenience init(root: NavigationDestination) {
        self.init()
        replaceNavigationStack([root], animated: false)
    }
}

class BaseNavigationController: UIViewController {
    weak var navigation: Navigation!
}

extension Navigation: NavigationHost {
    
    func replaceNavigationStack(_ views: [NavigationDestination], animated: Bool) {
        let controllers: [ViewWrapperController] = views.compactMap {
             if let dest = $0 as? ViewDestination {
                return wrapView(dest)
            } else {
                return nil
            }
        }
        navigationController.setViewControllers(controllers, animated: animated)
    }
    
    func push(_ dest: NavigationDestination, animated: Bool) {
        if let dest = dest as? ViewDestination {
            navigationController.pushViewController(wrapView(dest), animated: animated)
        }
    }
    
    func push(_ dest: BaseNavigationController, animated: Bool) {
        dest.navigation = self
        navigationController.pushViewController(dest, animated: animated)
    }
    
    func pop(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    func removeFromStack(tag: String) {
        navigationController.viewControllers.removeAll {
            if let controller = $0 as? NavigationDestination {
                return controller.tag == tag
            } else {
                return false
            }
        }
    }
    
    func presentModal(
        _ dest: NavigationDestination,
        animated: Bool,
        completion: (() -> (Void))?,
        controllerConfig: ((UIViewController) -> Void)?
    ) {
        guard let view = dest as? ViewDestination else {return}
        let controller = wrapView(view)
        controller.view.backgroundColor = .clear
        controllerConfig?(controller)
        navigationController.dismiss(animated: true) {
            self.navigationController.present(controller, animated: animated, completion: completion)
        }
    }
    
    
    func presentPopup(
        _ dest: NavigationDestination,
        animated: Bool,
        completion: (() -> (Void))?,
        controllerConfig: ((UIViewController) -> Void)?
    ) {
        self.presentModal(dest, animated: animated, completion: completion) { viewWrapperController in
            viewWrapperController.modalTransitionStyle = .crossDissolve
            viewWrapperController.modalPresentationStyle = .overFullScreen
            controllerConfig?(viewWrapperController)
        }
    }
    
    func presentPopup(
        _ dest: NavigationDestination,
        animated: Bool,
        completion: (() -> (Void))?
    ) {
        self.presentPopup(dest, animated: animated, completion: completion, controllerConfig: nil)
    }
    
    func dismissModal(animated: Bool, completion: (() -> (Void))?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
    
    private func wrapView(_ dest: ViewDestination) -> ViewWrapperController {
        return ViewWrapperController(tag: dest.tag, rootView: AnyView(dest.view.environmentObject(self)))
    }
}

struct NavigationHostView: UIViewControllerRepresentable {
    let navigation: Navigation
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return navigation.navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

extension Navigation: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.stackSize = navigationController.viewControllers.count
        if let controller = viewController as? NavigationDestination {
            currentTag = controller.tag
        } else {
            currentTag = nil
        }
    }
}

fileprivate class ViewWrapperController: UIHostingController<AnyView>, NavigationDestination {
    private(set) var tag: String?
    
    init(tag: String?, rootView: AnyView) {
        super.init(rootView: AnyView(rootView.navigationBarHidden(true)))
        self.tag = tag
    }
    
    override func viewWillAppear(_ animated: Bool) {}
    
    override func viewWillDisappear(_ animated: Bool) {}
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension Navigation {
    func openURLinSafariController(url: URL) {
        let root = UIApplication.shared.windows.first?.rootViewController
        root?.present(SFSafariViewController.init(url: url), animated: true, completion: nil)
    }
}


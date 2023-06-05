//
//  SceneDelegate.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        guard let window = window else { return }
        
        let networkManager = NetworkManager()
        let locationManager = LocationManager()
        let viewModel = ViewModel(networkManager: networkManager,
                                  locationManager: locationManager)
        let viewController = ViewController(viewModel: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}


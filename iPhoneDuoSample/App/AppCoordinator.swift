//
//  AppCoordinator.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/21/2026.
//  
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let viewModel = IntroViewModel()
        let viewController = IntroViewController(viewModel: viewModel)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

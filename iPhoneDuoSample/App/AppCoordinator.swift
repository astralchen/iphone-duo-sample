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

import Combine
import Foundation
import UIKit

final class AppCoordinator {
    private var cancellables: Set<AnyCancellable> = []
    
    private let window: UIWindow
    private let navigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let viewModel = IntroViewModel()
        let viewController = IntroViewController(viewModel: viewModel)
        
        viewModel.navigationPath
            .sink { [weak self] path in
                self?.navigateToPath(path)
            }.store(in: &cancellables)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func navigateToPath(_ path: IntroNavigationPath) {
        switch path {
        case .reservedRegions:
            let viewModel = ReservedRegionViewModel()
            let viewController = ReservedRegionViewController(viewModel: viewModel)
            viewController.navigationItem.title = "Reserved Regions"
            
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

//
//  BaseViewController.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

class BaseViewController<ViewModelType>: UIViewController {
    private var didInitialize: Bool = false
    
    let viewModel: ViewModelType

    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard !didInitialize else { return }
        
        didInitialize = true
        
        viewDidInitialize()
    }
    
    open func viewDidInitialize() {
        // Override
    }
}

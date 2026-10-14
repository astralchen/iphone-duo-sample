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
        
        // 首次进入视图层级后再初始化布局，使子类能够使用当前容器的尺寸、Safe Area 和 traits。
        // 后续再次显示页面时保留已有视图与约束，避免重复添加。
        guard !didInitialize else { return }
        
        didInitialize = true
        
        viewDidInitialize()
    }
    
    /// 在页面首次即将显示时构建视图和初始约束；后续尺寸变化由子类自行处理。
    open func viewDidInitialize() {
        // Override
    }
}

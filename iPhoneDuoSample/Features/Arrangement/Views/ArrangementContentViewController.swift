//
//  ArrangementContentViewController.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SnapKit
import UIKit

final class ArrangementContentViewController: UIViewController {
    private let color: UIColor
    private let text: String

    init(color: UIColor, text: String) {
        self.color = color
        self.text = text
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let box = UIView()
        box.backgroundColor = color.withAlphaComponent(0.15)
        box.layer.borderColor = color.cgColor
        box.layer.borderWidth = 2
        box.layer.cornerRadius = 16
        view.addSubview(box)
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = text
        label.textColor = color
        box.addSubview(label)
        
        // 以内嵌页面自己的 Safe Area 为边界，使卡片留白随系统容器分配的区域调整。
        box.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

#if DEBUG
#Preview("内容组件 · Primary", traits: .fixedLayout(width: 390, height: 300)) {
    let viewModel = ArrangementViewModel()
    let controller = ArrangementContentViewController(
        color: viewModel.primaryContentColor,
        text: viewModel.primaryContentText
    )
    controller.view.backgroundColor = .systemBackground
    return controller
}

#Preview("内容组件 · Secondary", traits: .fixedLayout(width: 390, height: 300)) {
    let viewModel = ArrangementViewModel()
    let controller = ArrangementContentViewController(
        color: viewModel.secondaryContentColor,
        text: viewModel.secondaryContentText
    )
    controller.view.backgroundColor = .systemBackground
    return controller
}
#endif

//
//  ArrangementViewController.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/21/2026.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Combine
import SnapKit
import UIKit

final class ArrangementViewController: BaseViewController<ArrangementViewModel> {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.text = "UIArrangementViewController is not available on this device."
        return label
    }()
    
    private var isLandscape: Bool { view.bounds.width > view.bounds.height }
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    override func viewDidInitialize() {
        if #available(iOS 27.1, *) {
            let primaryContentViewController = ArrangementContentViewController(color: viewModel.primaryContentColor, text: viewModel.primaryContentText)
            let secondaryContentViewController = ArrangementContentViewController(color: viewModel.secondaryContentColor, text: viewModel.secondaryContentText)
            
            let viewController = UIArrangementViewController()
            viewController.setViewController(primaryContentViewController, for: .primary)
            viewController.setViewController(secondaryContentViewController, for: .secondary)
            
            addChild(viewController)
            view.addSubview(viewController.view)
            viewController.view.frame = view.bounds
            viewController.didMove(toParent: self)
        } else {
            view.addSubview(textLabel)
            
            textLabel.snp.makeConstraints { make in
                make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(16)
                make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
                make.center.equalToSuperview()
            }
        }
    }
}

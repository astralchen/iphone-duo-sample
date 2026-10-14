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
            // 将两个内容控制器交给系统容器，由容器决定 primary、secondary 的排列方式。
            viewController.setViewController(primaryContentViewController, for: .primary)
            viewController.setViewController(secondaryContentViewController, for: .secondary)
            
            // 按控制器包含关系的顺序嵌入子页面，确保生命周期与环境信息能够传递。
            addChild(viewController)
            view.addSubview(viewController.view)
            // 初始 frame 覆盖父视图；各内容页面再使用自己的 Safe Area 设置内部留白。
            viewController.view.frame = view.bounds
            viewController.didMove(toParent: self)
        } else {
            view.addSubview(textLabel)
            
            // 回退说明允许多行显示；左右边界限制宽度，中心约束负责整体定位。
            textLabel.snp.makeConstraints { make in
                make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(16)
                make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
                make.center.equalToSuperview()
            }
        }
    }
}

#if DEBUG

#Preview("Arrangement · 竖屏", traits: .portrait) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View"
    )
}

#Preview("Arrangement · 横屏", traits: .landscapeLeft) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View"
    )
}

#Preview("Arrangement · Regular 宽屏横向布局", traits: .fixedLayout(width: 1024, height: 768)) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View",
        variant: .regular
    )
}

#Preview("Arrangement · 深色", traits: .portrait) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View",
        variant: .dark
    )
}

#Preview("Arrangement · 辅助功能大字体", traits: .portrait) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View",
        variant: .accessibility
    )
}

#Preview("Arrangement · RTL", traits: .portrait) {
    PreviewSupport.page(
        ArrangementViewController(viewModel: ArrangementViewModel()),
        title: "Arrangement View",
        variant: .rightToLeft
    )
}

#endif

//
//  IntroViewController.swift
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

final class IntroViewController: BaseViewController<IntroViewModel> {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var primaryStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, textLabel, statusLabel])
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .center
        return view
    }()
    
    private lazy var secondaryStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [reservedRegionsButton, arrangementViewButton])
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private lazy var reservedRegionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reserved Regions", for: .normal)
        button.addTarget(self, action: #selector(reservedRegionsButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var arrangementViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Arrangement View", for: .normal)
        button.addTarget(self, action: #selector(arrangementViewButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // 以页面实际可用尺寸判断横向布局，兼容窗口尺寸与设备方向不一致的情况。
    private var isLandscape: Bool { view.bounds.width > view.bounds.height }
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        bindViewModel()
    }
    
    override func viewDidInitialize() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(primaryStack)
        contentView.addSubview(secondaryStack)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 当前内容容器按滚动视图的 Safe Area 四边定位并留白，布局基准是可见区域。
        // 这里没有通过 contentLayoutGuide 建立随内容增长的滚动高度。
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.safeAreaLayoutGuide).inset(16)
            make.top.bottom.equalTo(scrollView.safeAreaLayoutGuide).inset(16)
        }
        
        if #available(iOS 27.1, *) {
            let interaction = UIHingeInteraction { [weak self] _, update in
                guard let hinge = update.hinge else {
                    self?.viewModel.updateHingeStatus(.unavailable)
                    return
                }
                
                self?.viewModel.updateHingeStatus(.active(angle: hinge.angle, status: hinge.status.description))
            }
            view.addInteraction(interaction)
        } else {
            viewModel.updateHingeStatus(.unavailable)
        }
        
        // 窗口环境变化也可能改变 size class，需重新选择布局分支。
        registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]) { [weak self] (traitEnvironment: Self, previousTraitCollection) in
            self?.updateLayout()
        }
        
        updateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 转场开始时 view.bounds 可能仍是旧尺寸，直接使用目标尺寸选择横竖布局。
        updateLayout(forLandscape: size.width > size.height)
    }

    //
    // MARK: - View model bindings
    //

    private func bindViewModel() {
        let outputs = viewModel.outputs
        
        outputs.content
            .sink { [weak self] content in
                self?.updateContent(content)
            }.store(in: &cancellables)
    }
    
    private func updateContent(_ content: IntroContent) {
        titleLabel.text = content.title
        textLabel.text = content.text
        statusLabel.text = content.hingeText
    }
    
    /// 根据水平 size class 和容器宽高关系，重新设置介绍区与操作区的位置。
    private func updateLayout(forLandscape: Bool? = nil) {
        let forLandscape: Bool = forLandscape ?? isLandscape
        let isRegular: Bool = traitCollection.horizontalSizeClass == .regular
        
        // 仅 Regular 横向容器采用左右排列；其余情况采用上下排列。
        // remakeConstraints 移除上一分支的约束，避免切换后两套定位规则同时生效。
        // 边界与内容顺序使用 required，理想居中使用 high，空间不足时允许偏离中心。
        if isRegular {
            primaryStack.snp.remakeConstraints { make in
                if forLandscape {
                    // centerX 的 0.5 倍对应容器宽度的 1/4，使介绍区位于左半区中心。
                    make.leading.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.width.equalToSuperview().multipliedBy(0.5)
                    make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.centerX.equalToSuperview().multipliedBy(0.5).priority(.high)
                    make.centerY.equalToSuperview().priority(.high)
                } else {
                    // centerY 的 0.5 倍对应容器高度的 1/4，使介绍区位于上半区中心。
                    make.top.greaterThanOrEqualToSuperview().priority(.required)
                    make.centerY.equalToSuperview().multipliedBy(0.5).priority(.high)
                    make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
                }
            }
            secondaryStack.snp.remakeConstraints { make in
                if forLandscape {
                    // 1.5 倍中心坐标对应宽度的 3/4；leading 下界约束两个区域不重叠。
                    make.leading.greaterThanOrEqualTo(primaryStack.snp.trailing).priority(.required)
                    make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.centerX.equalToSuperview().multipliedBy(1.5).priority(.high)
                    make.centerY.equalToSuperview().priority(.high)
                    make.trailing.lessThanOrEqualToSuperview().priority(.required)
                } else {
                    // 操作区优先位于下半区中心，并始终排在介绍区下方。
                    make.top.greaterThanOrEqualTo(primaryStack.snp.bottom).priority(.required)
                    make.centerY.equalToSuperview().multipliedBy(1.5).priority(.high)
                    make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
                    make.bottom.lessThanOrEqualToSuperview().priority(.required)
                }
            }
        } else {
            // Compact 宽度下即使容器横向显示，也保持上下排列，避免压缩文字的可用宽度。
            primaryStack.snp.remakeConstraints { make in
                make.top.greaterThanOrEqualToSuperview().priority(.required)
                make.centerY.equalToSuperview().multipliedBy(0.5).priority(.high)
                make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            }
            secondaryStack.snp.remakeConstraints { make in
                make.top.greaterThanOrEqualTo(primaryStack.snp.bottom).priority(.required)
                make.centerY.equalToSuperview().multipliedBy(1.5).priority(.high)
                make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
                make.bottom.lessThanOrEqualToSuperview().priority(.required)
            }
        }
    }
    
    @objc private func reservedRegionsButtonTap() {
        viewModel.processReservedRegionButtonTap()
    }
    
    @objc private func arrangementViewButtonTap() {
        viewModel.processArrangementViewButtonTap()
    }
}

#if DEBUG

#Preview("首页 · 竖屏", traits: .portrait) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel())
    )
}

#Preview("首页 · 横屏", traits: .landscapeLeft) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel())
    )
}

#Preview("首页 · Regular 宽屏横向布局", traits: .fixedLayout(width: 1024, height: 768)) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel()),
        variant: .regular
    )
}

#Preview("首页 · 深色", traits: .portrait) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel()),
        variant: .dark
    )
}

#Preview("首页 · 辅助功能大字体", traits: .portrait) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel()),
        variant: .accessibility
    )
}

#Preview("首页 · RTL", traits: .portrait) {
    PreviewSupport.page(
        IntroViewController(viewModel: IntroViewModel()),
        variant: .rightToLeft
    )
}

#endif

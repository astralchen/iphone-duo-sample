//
//  ReservedRegionViewController.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/21/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SnapKit
import UIKit

final class ReservedRegionViewController: BaseViewController<ReservedRegionViewModel> {
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .leading
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Reserved regions are not available on this device."
        label.numberOfLines = 0
        return label
    }()
    
    private var isLandscape: Bool { view.bounds.width > view.bounds.height }
    private var reservedRegionViews: [UIView] = []
    private var didInitialize: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidInitialize() {
        view.addSubview(contentStack)
        
        if #available(iOS 27.1, *) {
            rebuildReservedRegionViews()
            
            // 铰链状态更新后重新读取区域及其激活状态，刷新示意覆盖层。
            let interaction = UIHingeInteraction { [weak self] _, _ in
                self?.rebuildReservedRegionViews()
            }
            view.addInteraction(interaction)
        }
        
        updateContent()
        updateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 等尺寸转场结束后再查询区域 frame，使覆盖层使用转场后的几何信息。
        coordinator.animateAlongsideTransition(in: view, animation: { _ in }) { [weak self] _ in
            self?.updateLayout(forLandscape: size.width > size.height)
            
            if #available(iOS 27.1, *) {
                self?.rebuildReservedRegionViews()
            }
        }
    }
    
    private func updateContent() {
        if #available(iOS 27.1, *) {
            let activeRegionLegendView = ReservedRegionLegendView()
            let inactiveRegionLegendView = ReservedRegionLegendView()
            
            activeRegionLegendView.update(text: "Active Region", color: viewModel.activeRegionColor)
            inactiveRegionLegendView.update(text: "Inactive Region", color: viewModel.inactiveRegionColor)
            
            contentStack.addArrangedSubview(activeRegionLegendView)
            contentStack.addArrangedSubview(inactiveRegionLegendView)
            
        } else {
            contentStack.addArrangedSubview(textLabel)
        }
    }
    
    /// 按容器环境放置图例；高优先级边界约束优先于理想居中位置。
    private func updateLayout(forLandscape: Bool? = nil) {
        let isRegular: Bool = traitCollection.horizontalSizeClass == .regular
        let forLandscape: Bool = forLandscape ?? isLandscape
        
        if #available(iOS 27.1, *) {
            if isRegular {
                // Regular 环境将图例放在后半区：横向为右半区，纵向为下半区。
                // 中心坐标乘以 1.5 对应整幅宽度或高度的 3/4 位置。
                contentStack.snp.remakeConstraints { make in
                    if forLandscape {
                        make.leading.greaterThanOrEqualTo(view.snp.centerX).priority(.required)
                        make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(16).priority(.required)
                        make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                        make.centerX.equalToSuperview().multipliedBy(1.5).priority(.high)
                        make.centerY.equalToSuperview().priority(.high)
                        make.trailing.lessThanOrEqualToSuperview().priority(.required)
                    } else {
                        make.top.greaterThanOrEqualTo(view.snp.centerY).priority(.required)
                        make.centerY.equalToSuperview().multipliedBy(1.5).priority(.high)
                        make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
                        make.bottom.lessThanOrEqualToSuperview().priority(.required)
                    }
                }
            } else {
                // Compact 环境优先居中，并通过 Safe Area 四边的不等式限制图例范围。
                contentStack.snp.remakeConstraints { make in
                    make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.center.equalToSuperview().priority(.high)
                }
            }
        } else {
            // 不支持 Reserved Regions 时，回退说明使用同样的 Safe Area 边界与居中策略。
            contentStack.snp.remakeConstraints { make in
                make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                make.center.equalToSuperview().priority(.high)
            }
        }
    }
    
    @available(iOS 27.1, *)
    private func rebuildReservedRegionViews() {
        // 同时展示分隔区域和遮挡区域；包含未激活区域，以便对比不同铰链状态。
        let regions = view.reservedRegions(kind: .division, options: .includeInactive) +
                        view.reservedRegions(kind: .occlusion, options: .includeInactive)
        
        // 区域数量和位置都可能变化，每次整体替换覆盖层，避免遗留旧 frame。
        reservedRegionViews.forEach { view in
            view.removeFromSuperview()
        }
        reservedRegionViews.removeAll()
        
        print("Regions:")
        for region in regions {
            // 查询与绘制都使用同一个 view 的坐标空间，直接采用区域 frame。
            // 这些视图用于可视化系统区域，不参与图例的 Auto Layout 定位。
            let regionView = UIView(frame: region.frame)
            regionView.backgroundColor = region.isActive ? viewModel.activeRegionColor : viewModel.inactiveRegionColor
            view.addSubview(regionView)
            print("  Active:", region.isActive, "frame", region.frame)
            
            reservedRegionViews.append(regionView)
        }
        print("")
    }
}

#if DEBUG

#Preview("Reserved Regions · 竖屏", traits: .portrait) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions"
    )
}

#Preview("Reserved Regions · 横屏", traits: .landscapeLeft) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions"
    )
}

#Preview("Reserved Regions · Regular 宽屏横向布局", traits: .fixedLayout(width: 1024, height: 768)) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions",
        variant: .regular
    )
}

#Preview("Reserved Regions · 深色", traits: .portrait) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions",
        variant: .dark
    )
}

#Preview("Reserved Regions · 辅助功能大字体", traits: .portrait) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions",
        variant: .accessibility
    )
}

#Preview("Reserved Regions · RTL", traits: .portrait) {
    PreviewSupport.page(
        ReservedRegionViewController(viewModel: ReservedRegionViewModel()),
        title: "Reserved Regions",
        variant: .rightToLeft
    )
}

#endif

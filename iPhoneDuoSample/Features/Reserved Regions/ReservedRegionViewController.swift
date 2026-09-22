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
    
    private func updateLayout(forLandscape: Bool? = nil) {
        let isRegular: Bool = traitCollection.horizontalSizeClass == .regular
        let forLandscape: Bool = forLandscape ?? isLandscape
        
        if #available(iOS 27.1, *) {
            if isRegular {
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
                contentStack.snp.remakeConstraints { make in
                    make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.center.equalToSuperview().priority(.high)
                }
            }
        } else {
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
        let regions = view.reservedRegions(kind: .division, options: .includeInactive) +
                        view.reservedRegions(kind: .occlusion, options: .includeInactive)
        
        reservedRegionViews.forEach { view in
            view.removeFromSuperview()
        }
        reservedRegionViews.removeAll()
        
        print("Regions:")
        for region in regions {
            let regionView = UIView(frame: region.frame)
            regionView.backgroundColor = region.isActive ? viewModel.activeRegionColor : viewModel.inactiveRegionColor
            view.addSubview(regionView)
            print("  Active:", region.isActive, "frame", region.frame)
            
            reservedRegionViews.append(regionView)
        }
        print("")
    }
}

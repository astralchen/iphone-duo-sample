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
        
        registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]) { [weak self] (traitEnvironment: Self, previousTraitCollection) in
            self?.updateLayout()
        }
        
        updateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
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
    
    private func updateLayout(forLandscape: Bool? = nil) {
        let forLandscape: Bool = forLandscape ?? isLandscape
        let isRegular: Bool = traitCollection.horizontalSizeClass == .regular
        
        if isRegular {
            primaryStack.snp.remakeConstraints { make in
                if forLandscape {
                    make.leading.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.width.equalToSuperview().multipliedBy(0.5)
                    make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.centerX.equalToSuperview().multipliedBy(0.5).priority(.high)
                    make.centerY.equalToSuperview().priority(.high)
                } else {
                    make.top.greaterThanOrEqualToSuperview().priority(.required)
                    make.centerY.equalToSuperview().multipliedBy(0.5).priority(.high)
                    make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
                }
            }
            secondaryStack.snp.remakeConstraints { make in
                if forLandscape {
                    make.leading.greaterThanOrEqualTo(primaryStack.snp.trailing).priority(.required)
                    make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(16).priority(.required)
                    make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16).priority(.required)
                    make.centerX.equalToSuperview().multipliedBy(1.5).priority(.high)
                    make.centerY.equalToSuperview().priority(.high)
                    make.trailing.lessThanOrEqualToSuperview().priority(.required)
                } else {
                    make.top.greaterThanOrEqualTo(primaryStack.snp.bottom).priority(.required)
                    make.centerY.equalToSuperview().multipliedBy(1.5).priority(.high)
                    make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
                    make.bottom.lessThanOrEqualToSuperview().priority(.required)
                }
            }
        } else {
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
}

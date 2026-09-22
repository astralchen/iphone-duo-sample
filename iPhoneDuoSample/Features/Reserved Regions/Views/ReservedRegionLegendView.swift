//
//  ReservedRegionLegendView.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SnapKit
import UIKit

final class ReservedRegionLegendView: UIStackView {
    private lazy var colorView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.layer.cornerRadius = colorView.bounds.width / 2
    }
    
    init() {
        super.init(frame: .zero)
        setUpView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(text: String, color: UIColor) {
        textLabel.text = text
        colorView.backgroundColor = color
    }
    
    private func setUpView() {
        axis = .horizontal
        spacing = 16
        alignment = .center
        
        addArrangedSubview(colorView)
        addArrangedSubview(textLabel)
        
        colorView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}

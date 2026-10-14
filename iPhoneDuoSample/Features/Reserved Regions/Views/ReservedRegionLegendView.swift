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
        // 降低文字的水平 hugging 优先级，让多余宽度由文字区域吸收。
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 在布局完成、实际尺寸确定后计算半径，使正方形色块呈现为圆点。
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
        
        // 固定圆点尺寸；文字沿水平方向排列，并与圆点垂直居中。
        colorView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}

#if DEBUG
#Preview("区域图例 · Active", traits: .sizeThatFitsLayout) {
    let viewModel = ReservedRegionViewModel()
    let legend = ReservedRegionLegendView()
    legend.update(text: "Active Region", color: viewModel.activeRegionColor)
    return PreviewSupport.component(legend)
}

#Preview("区域图例 · Inactive", traits: .sizeThatFitsLayout) {
    let viewModel = ReservedRegionViewModel()
    let legend = ReservedRegionLegendView()
    legend.update(text: "Inactive Region", color: viewModel.inactiveRegionColor)
    return PreviewSupport.component(legend)
}
#endif

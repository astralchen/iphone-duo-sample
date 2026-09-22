//
//  CGFloat+DegreeText.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import CoreGraphics
import Foundation

extension CGFloat {
    var degreeText: String {
        let degrees = Double(self * 180 / .pi)
        return "\(degrees.formatted(.number.precision(.fractionLength(0))))°"
    }
}

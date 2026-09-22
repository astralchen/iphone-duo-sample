//
//  UIHingeStatus+CustomStringConvertible.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

@available(iOS 27.1, *)
extension UIHinge.Status: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .closed:
            return "closed"
        case .partiallyOpen:
            return "partiallyOpen"
        case .fullyOpen:
            return "fullyOpen"
        @unknown default:
            return "@unknown"
        }
    }
}

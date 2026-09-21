//
//  UIUserInterfaceSizeClass+CustomStringConvertible.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/21/2026.
//  
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

extension UIUserInterfaceSizeClass: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .unspecified:
            return "unspecified"
        case .compact:
            return "compact"
        case .regular:
            return "regular"
        @unknown default:
            return "@unknown"
        }
    }
}

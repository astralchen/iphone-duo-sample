//
//  HingeStatus.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

enum HingeStatus {
    case notDetermined
    case unavailable
    case active(angle: CGFloat, status: String)
}

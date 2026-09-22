//
//  IntroViewModel.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/21/2026.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Combine
import Foundation

protocol IntroViewModelOutputs {
    var content: AnyPublisher<IntroContent, Never> { get }
}

final class IntroViewModel: IntroViewModelOutputs {
    var outputs: any IntroViewModelOutputs { return self }
    
    @PassthroughPublisher(on: DispatchQueue.main)
    var navigationPath: AnyPublisher<IntroNavigationPath, Never>
    
    // Outputs
    @PassthroughPublisher(on: DispatchQueue.main)
    var content: AnyPublisher<IntroContent, Never>
    
    func updateHingeStatus(_ status: HingeStatus) {
        updateContent(status)
    }
    
    func processReservedRegionButtonTap() {
        _navigationPath.send(.reservedRegions)
    }
    
    func processArrangementViewButtonTap() {
        _navigationPath.send(.arrangementView)
    }
    
    private func updateContent(_ status: HingeStatus) {
        switch status {
        case let .active(angle, status):
            let statusText = "Hinge angle: \(angle.degreeText), status: \(status.description)"
            
            _content.send(IntroContent(title: "iPhone Duo ✅",
                                       text: "Sample project providing a look into new APIs introduced with iPhone Duo and iOS 27.1. Run this demo on an iPhone Duo to see it in action!",
                                       hingeText: statusText))
        case .notDetermined:
            break
        case .unavailable:
            _content.send(IntroContent(title: "Not iPhone Duo",
                                       text: "Sample project providing a look into new APIs introduced with iPhone Duo and iOS 27.1. Run this demo on an iPhone Duo to see it in action!",
                                       hingeText: "Hinge data unavailable."))
        }
    }
}

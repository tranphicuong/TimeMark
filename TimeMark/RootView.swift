//
//  RootView.swift
//  TimeMark
//
//  Created by cuong on 26/3/26.
//


import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            LoginView()
        } else {
            OnboardingView()
        }
    }
}
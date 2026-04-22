//
//  LoadingDotsView.swift
//  TimeMark
//
//  Created by Doanh on 4/22/26.
//

import SwiftUI

struct LoadingDotsView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 8) {
            Dot(delay: 0, animate: animate)
            Dot(delay: 0.2, animate: animate)
            Dot(delay: 0.4, animate: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct Dot: View {
    let delay: Double
    let animate: Bool

    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .scaleEffect(animate ? 1 : 0.5)
            .offset(y: animate ? -6 : 6)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever()
                    .delay(delay),
                value: animate
            )
    }
}

//
//  SplashView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            AppLayoutView()
        } else {
            VStack {
                // TODO: Add Animation or whatever
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

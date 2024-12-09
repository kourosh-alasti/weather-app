//
//  SplashView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var loadingAmount = 0.0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if isActive {
            AppLayoutView()
        } else {
            VStack {
                // TODO: Add Animation or whatever
                //Color.blue
                //    .ignoresSafeArea(.all)
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                ProgressView(value: loadingAmount, total: 100)
                    .tint(.white)
                    .padding(20)
                Text("Loading...")
                    .fontWeight(.bold)
                    .onReceive(timer) { _ in
                        if loadingAmount < 100 {
                            loadingAmount += 5
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.blue
                    .opacity(0.4)
                    .ignoresSafeArea()
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

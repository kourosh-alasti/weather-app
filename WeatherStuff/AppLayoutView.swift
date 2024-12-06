//
//  AppLayoutView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct AppLayoutView: View {
    var body: some View {
        ZStackLayout(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                SearchHistoryView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search History")
                    }
            }
        }
    }
}

#Preview {
    AppLayoutView()
}

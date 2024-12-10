//
//  SearchHistoryView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct SearchHistoryView: View {
    @State private var searchHistory: [CityInfo] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Search History...")
                        .foregroundColor(.primary)
                        .padding()
                } else if searchHistory.isEmpty {
                    Text("No Search History available.")
                        .foregroundColor(.primary)
                } else {
                    
                    List {
                        ForEach(searchHistory, id: \.xata_id) { city in
                            NavigationLink(destination: CityInfoView(city: city.city, temperature: city.lastTemperature)){
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(city.city)
                                            .font(.headline)
                                        Text(String(format: "%.2f°C", city.lastTemperature))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(String(format: "%.1f°F", (((city.lastTemperature*9)/5)+32)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Image(systemName: "camera")
                                }
                            }
                        }
                        .onDelete(perform: deleteCity)
                    }
                }
            }
            .navigationTitle("Search History")
            .onAppear {
                fetchSearchHistory()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.blue
                    .opacity(0.4)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func fetchSearchHistory() {
        guard let url = URL(string: "https://deploy-preview-1--unishopapp.netlify.app/api/") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            guard let data = data else {
                print("No Data Received")
                isLoading = false
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CityResponse.self, from: data)
                DispatchQueue.main.async {
                    searchHistory = decodedResponse.items
                    isLoading = false
                }
            } catch {
                print(data.count)
                print("error decoding response: \(error.localizedDescription)")
                isLoading = false
            }
        }.resume()
    }
    
    private func deleteCity(at offsets: IndexSet) {
        searchHistory.remove(atOffsets: offsets)
    }
}

#Preview {
    SearchHistoryView()
}

//
//  HomeView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct WeatherInfo: Decodable {
    let city: String
    let currentTempC: Double
    let minTempC: Double
    let maxTempC: Double
    let condition: String
    let conditionIcon: String
}


struct HomeView: View {
    @State private var cityName = ""
    @State private var weatherData: WeatherInfo?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a city", text: $cityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        fetchWeatherData(for: cityName)
                    }
                
                if let weather = weatherData  {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(weather.city)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Current Temperature: \(weather.currentTempC)°C")
                                .font(.title)
                            
                            Spacer()
                            
                            AsyncImage(url: URL(string: "https://\(weather.conditionIcon)")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        Text("Condition: \(weather.condition)")
                            .font(.title2)
                        
                        Text("Min Temp: \(weather.minTempC)°C | Max Temp: \(weather.maxTempC)°C")
                            .font(.title2)
                    }
                    .padding()
                    
                } else {
                    Text("Loading weather information...")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .onAppear {
                fetchWeatherData(for: cityName)
            }
            .navigationTitle("Weather App")
        }
    }
    
    func fetchWeatherData(for city: String) {
        guard let url = URL(string: "https://deploy-preview-1--unishopapp.netlify.app/api/weather?city=\(city)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                    let response = try JSONDecoder().decode(WeatherInfo.self, from: data)
                    DispatchQueue.main.async {
                        weatherData = response
                    }
                } catch {
                    print("Error decoding weather data: \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
}

#Preview {
    HomeView()
}

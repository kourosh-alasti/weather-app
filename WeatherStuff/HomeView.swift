//
//  HomeView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI

struct WeatherInfo: Decodable, Encodable {
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text(weather.city)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack(alignment: .leading){
                                Text("Current Temperature:")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(String(format:"%.0f°F | %.2f°C", (((weather.currentTempC*9)/5)+32), weather.currentTempC))
                                    .font(.title3)
                            }
                            Spacer()
                            
                            AsyncImage(url: URL(string: "https://\(weather.conditionIcon)")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75,  height: 75)
                            } placeholder: {
                                ProgressView()
                            }
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        HStack(spacing: 7){
                            Text("Condition:")
                                .font(.title2)
                            Text(weather.condition)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                       
                        
                        Text(String(format:"Min Temp:  %.2f°C\nMax Temp: %.2f°C", weather.minTempC, weather.maxTempC))
                            .font(.title2)
                    }
                    .padding()
                    
                } else {
                    if weatherData != nil {
                        Text("Loading weather information...")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        Text("Search for a city to get started...")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding()
                    }
                
                }
                
                Spacer()
            }
            .onAppear {
                loadData()
                fetchWeatherData(for: cityName)
            }
            .navigationTitle("Weather App")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.blue
                    .opacity(0.4)
                    .ignoresSafeArea()
            }
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
                        saveData(response)
                    }
                } catch {
                    print("Error decoding weather data: \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
    
    func saveData(_ info:WeatherInfo){
        let userstorage = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(info){
            userstorage.set(encodedData, forKey: "weatherInfo" )
            print("Saving Data")
        }
        
    }
    
    func loadData(){
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "weatherInfo"), let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: savedData){
            weatherData = weatherInfo
            print("Loading Data")
        }else{
            weatherData = nil
        }
    }
}

#Preview {
    HomeView()
}

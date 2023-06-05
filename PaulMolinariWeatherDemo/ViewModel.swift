//
//  ViewModel.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import Foundation
import UIKit

actor ViewModel: ObservableObject {
    
    @MainActor @Published var cityName: String = "San Diego"
    @MainActor @Published var icon: UIImage?
    
    static func mock() -> ViewModel {
        let networkManager = NetworkManager()
        let locationManager = LocationManager()
        return ViewModel(networkManager: networkManager,
                         locationManager: locationManager)
    }
    
    @MainActor @Published var weatherResponse: WeatherResponse?
    
    let networkManager: NetworkManagerConformable
    let locationManager: LocationManagerConformable

    init(networkManager: NetworkManagerConformable, locationManager: LocationManagerConformable) {
        self.networkManager = networkManager
        self.locationManager = locationManager
        
        Task { @MainActor in
            cityName = UserDefaults.standard.string(forKey: "city_name") ?? ""
            if cityName.count <= 0 { cityName = "San Diego" }
            locationManager.delegate = self
            await downloadWeather(city: cityName)
        }
    }
    
    private func refreshIcon() async {
        if let weatherResponse = await weatherResponse, let weather = weatherResponse.weather {
            for _weather in weather {
                do {
                    let image = try await networkManager.icon(id: _weather.icon)
                    await MainActor.run {
                        self.icon = image
                        print("image \(image.size.width) x \(image.size.height)")
                    }
                    return
                } catch let error {
                    print("error downloading icon: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func downloadWeather(city: String) async {
        do {
            let _weatherResponse = try await networkManager.weather(city: city)
            UserDefaults.standard.set(_weatherResponse.name, forKey: "city_name")
            
            await MainActor.run {
                weatherResponse = _weatherResponse
            }
            await refreshIcon()
            
        } catch let error {
            print("download weather with city error: \(error.localizedDescription)")
        }
    }
    
    func downloadWeather(lat: Double, lng: Double) async {
        do {
            let _weatherResponse = try await networkManager.weather(lat: lat, lng: lng)
            UserDefaults.standard.set(_weatherResponse.name, forKey: "city_name")
            
            await MainActor.run {
                weatherResponse = _weatherResponse
            }
            await refreshIcon()
            
        } catch let error {
            print("download weather with lat/lng error: \(error.localizedDescription)")
        }
    }
    
    private var searchText: String = ""
    private var lastExecutedSearchText: String = ""
    private var searchTask: Task<Void, Never>?
    func updateSearchText(_ text: String) {
        searchText = text
        if searchTask != nil { return }
        lastExecutedSearchText = searchText
        searchTask = Task {
            await downloadWeather(city: searchText)
            searchTask = nil
            if lastExecutedSearchText != searchText {
                updateSearchText(searchText)
            }
        }
    }
    
    @MainActor func temperature() -> String? {
        if let temp = weatherResponse?.main?.temp {
            let farenheit = (temp - 273.15) * 9.0 / 5.0 + 32.0
            return String(format: "%.1fºF", farenheit)
        }
        return nil
    }
    
    @MainActor func humidity() -> String? {
        if let humidity = weatherResponse?.main?.humidity {
            return String(format: "%.1f%%", humidity)
        }
        return nil
    }
    
    @MainActor func visibility() -> String? {
        if let visibility = weatherResponse?.visibility {
            let miles = visibility * 0.000621371
            return String(format: "%.1f mi", miles)
        }
        return nil
    }
    
    @MainActor func pressure() -> String? {
        if let pressure = weatherResponse?.main?.pressure {
            let ppsf = pressure * 2.08854
            return String(format: "%.1f lb/sq. ft", ppsf)
        }
        return nil
    }
}

extension ViewModel: LocationManagerDelegate {
    nonisolated func locationDidFail() {
        
    }
    
    nonisolated func locationDidUpdate(lat: Double, lng: Double) {
        Task {
            await downloadWeather(lat: lat, lng: lng)
        }
    }
}

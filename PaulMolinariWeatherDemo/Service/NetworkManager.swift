//
//  NetworkManager.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import Foundation

protocol NetworkManagerConformable: Actor {
    func weather(city: String) async throws -> WeatherResponse
    func weather(lat: Double, lng: Double) async throws -> WeatherResponse
    func icon(id: String) async throws -> Data
}

actor NetworkManager: NetworkManagerConformable {
    
    private lazy var decoder: JSONDecoder = {
        let result = JSONDecoder()
        result.keyDecodingStrategy = .convertFromSnakeCase
        return result
    }()
    
    private func urlEscape(_ text: String?) -> String {
        if let unencoded = text {
            let allowedCharacters = CharacterSet(charactersIn: "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789")
            if let result = unencoded.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {
                return result
            } else {
                return unencoded
            }
        }
        return ""
    }
    
    func weather(city: String) async throws -> WeatherResponse {
        
        let city = urlEscape(city)
        var urlString = "https://api.openweathermap.org/data/2.5/weather"
        urlString += "?appid=52b53c97712bbee042d3c6d7166a713a"
        urlString += "&q=\(city)"
        urlString += "&units=imperial"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        guard (200...299).contains(urlResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try decoder.decode(WeatherResponse.self, from: data)
    }
    
    func weather(lat: Double, lng: Double) async throws -> WeatherResponse {
        var urlString = "https://api.openweathermap.org/data/2.5/weather"
        urlString += "?appid=52b53c97712bbee042d3c6d7166a713a"
        urlString += "&lat=\(lat)"
        urlString += "&lon=\(lng)"
        urlString += "&units=imperial"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        guard (200...299).contains(urlResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try decoder.decode(WeatherResponse.self, from: data)
    }
    
    func icon(id: String) async throws -> Data {
        let urlString = "https://openweathermap.org/img/wn/\(id)@2x.png"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        guard (200...299).contains(urlResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
}

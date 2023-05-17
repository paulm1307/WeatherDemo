//
//  NetworkManager.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 5/15/23.
//

import Foundation
import UIKit

protocol NetworkManagerConformable: Actor {
    func weather(city: String) async throws -> WeatherResponse
    func weather(lat: Double, lng: Double) async throws -> WeatherResponse
    func icon(id: String) async throws -> UIImage
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
    
    func icon(id: String) async throws -> UIImage {
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
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeRawData)
        }
        return image
    }
    
}

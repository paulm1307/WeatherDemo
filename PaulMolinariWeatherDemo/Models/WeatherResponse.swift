//
//  WeatherResponse.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import Foundation

public struct WeatherResponse: Decodable {
    let name: String
    let coord: Coordinate?
    let main: Main?
    let wind: Wind?
    let weather: [Weather]?
    let visibility: Double
    let timezone: Double
}

struct Coordinate: Decodable {
    let lon: Double
    let lat: Double
}

struct Main: Decodable {
    let temp: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
}

struct Wind: Decodable {
    let speed: Double
    let deg: Double
}

struct Weather: Decodable {
    let main: String
    let description: String
    let icon: String
}

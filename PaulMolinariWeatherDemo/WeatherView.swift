//
//  WeatherView.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                HStack {
                    Spacer()
                    if let name = viewModel.weatherResponse?.name {
                        Text(name)
                            .font(.system(size: 32.0).bold())
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Button {
                    Task {
                        await viewModel.locationManager.fetch()
                    }
                } label: {
                    ZStack {
                        Image(systemName: "location.circle")
                            .font(.system(size: 44.0))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 44.0, height: 44.0)
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 16.0)
            mainBody()
            Spacer()
        }
    }
    
    func mainBody() -> some View {
        VStack {
            ZStack {
                if let image = viewModel.icon {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 50.0, height: 50.0)
                } else {
                    ZStack {
                        
                    }
                    .frame(width: 50.0, height: 50.0)
                }
            }
            .frame(width: 50.0, height: 50.0)
            
            if let temp = viewModel.temperature() {
                Text(temp)
                    .font(.system(size: 32.0).bold())
                    .foregroundColor(.gray)
                    .padding(.bottom, 12.0)
            }
            
            VStack {
                HStack {
                    if let humidity = viewModel.humidity() {
                        Text("Humidity: \(humidity)")
                            .font(.system(size: 24.0))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                HStack {
                    if let visibility = viewModel.visibility() {
                        Text("Visibility: \(visibility)")
                            .font(.system(size: 24.0))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                HStack {
                    if let pressure = viewModel.pressure() {
                        Text("Pressure: \(pressure)")
                            .font(.system(size: 24.0))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16.0)
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(viewModel: ViewModel.mock())
    }
}

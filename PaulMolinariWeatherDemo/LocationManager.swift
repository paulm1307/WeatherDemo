//
//  LocationManager.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationDidFail()
    func locationDidUpdate(lat: Double, lng: Double)
}

protocol LocationManagerConformable: Actor {
    @MainActor var delegate: LocationManagerDelegate? { set get }
    func fetch()
}

actor LocationManager: NSObject, LocationManagerConformable {
    
    let coreLocationManager = CLLocationManager()
    
    @MainActor weak var delegate: LocationManagerDelegate?
    override init() {
        super.init()
    }
    
    func fetch() {
        coreLocationManager.delegate = self
        coreLocationManager.requestWhenInUseAuthorization()
        coreLocationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            Task { @MainActor in
                self.delegate?.locationDidUpdate(lat: lat, lng: lng)
            }
        } else {
            Task { @MainActor in
                self.delegate?.locationDidFail()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch coreLocationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.coreLocationManager.requestLocation()
        default:
            Task { @MainActor in
                self.delegate?.locationDidFail()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await self.delegate?.locationDidFail()
        }
    }
}

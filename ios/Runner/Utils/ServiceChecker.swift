import Foundation
import CoreLocation
import CoreBluetooth

class ServiceChecker {
    static let shared = ServiceChecker()
    
    private let locationManager = CLLocationManager()
    private var bluetoothManager: CBCentralManager?
    
    private init() {
        bluetoothManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
    func canStartLocationService() -> Bool {
        // Check location authorization
        let locationStatus = locationManager.authorizationStatus
        guard locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse else {
            return false
        }
        
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }
        
        return true
    }
    
    func canStartBeaconService() -> Bool {
        // Check location authorization
        let locationStatus = locationManager.authorizationStatus
        guard locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse else {
            return false
        }
        
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }
        
        // Check Bluetooth status
        guard let bluetoothManager = bluetoothManager else {
            return false
        }
        
        let bluetoothStatus = bluetoothManager.state
        guard bluetoothStatus == .poweredOn else {
            return false
        }
        
        return true
    }
    
    // MARK: - Logging
    
    private func logDebug(_ message: String) {
        #if DEBUG
        print("[ServiceChecker] \(message)")
        #endif
    }
    
    private func logError(_ message: String) {
        print("[ServiceChecker] ERROR: \(message)")
    }
} 
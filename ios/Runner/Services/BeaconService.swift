import Foundation
import CoreLocation
import CoreBluetooth

class BeaconService: NSObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    private let locationManager = CLLocationManager()
    private var peripheralManager: CBPeripheralManager?
    private var isScanning = false
    private var beaconBuffer: [String: Models.BeaconScanData] = [:]
    private var uploadTimer: Timer?
    private let UPLOAD_INTERVAL: TimeInterval = 60 // 1 minute
    private let SCAN_INTERVAL: TimeInterval = 1.1 // 1.1 seconds
    private var currentLocation: CLLocation?
    
    static let shared = BeaconService()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startService() {
        guard !isScanning else { return }
        
        // Request location permission
        locationManager.requestAlwaysAuthorization()
        
        // Request Bluetooth permission
        if #available(iOS 13.0, *) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Configure location manager for background updates
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Start ranging beacons
        let uuid = UUID(uuidString: "YOUR_BEACON_UUID")! // Replace with your beacon UUID
        let region = CLBeaconRegion(uuid: uuid, identifier: "com.uniguard.ugz_app.beacon")
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startRangingBeacons(satisfying: region)
        locationManager.startMonitoring(for: region)
        
        // Start upload timer
        startUploadTimer()
        
        isScanning = true
    }
    
    func stopService() {
        guard isScanning else { return }
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        
        // Stop ranging beacons
        let uuid = UUID(uuidString: "YOUR_BEACON_UUID")! // Replace with your beacon UUID
        let region = CLBeaconRegion(uuid: uuid, identifier: "com.uniguard.ugz_app.beacon")
        locationManager.stopRangingBeacons(satisfying: region)
        locationManager.stopMonitoring(for: region)
        
        // Stop upload timer
        stopUploadTimer()
        
        // Clear buffer
        beaconBuffer.removeAll()
        
        isScanning = false
    }
    
    private func startUploadTimer() {
        uploadTimer = Timer.scheduledTimer(withTimeInterval: UPLOAD_INTERVAL, repeats: true) { [weak self] _ in
            self?.uploadBufferedBeacons()
        }
    }
    
    private func stopUploadTimer() {
        uploadTimer?.invalidate()
        uploadTimer = nil
    }
    
    private func uploadBufferedBeacons() {
        guard !beaconBuffer.isEmpty, let location = currentLocation else { return }
        
        for (_, beaconData) in beaconBuffer {
            let beaconRequest = Models.BeaconRequest(
                type: "beacon",
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: Date().timeIntervalSince1970 * 1000,
                beacon: Models.BeaconData(
                    majorValue: beaconData.major,
                    minorValue: beaconData.minor,
                    batteryLevel: 0 // Battery level not available in iOS
                )
            )
            
            Task {
                do {
                    try await API.APIClient.shared.submitBeacon(beaconRequest)
                    print("Beacon uploaded successfully")
                } catch {
                    print("Failed to upload beacon: \(error)")
                }
            }
        }
        
        // Clear buffer after upload
        beaconBuffer.removeAll()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            let beaconKey = "\(beacon.uuid)-\(beacon.major)-\(beacon.minor)"
            let beaconData = Models.BeaconScanData(
                uuid: beacon.uuid.uuidString,
                major: beacon.major.intValue,
                minor: beacon.minor.intValue,
                rssi: beacon.rssi,
                proximity: beacon.proximity.rawValue,
                timestamp: Date().timeIntervalSince1970 * 1000
            )
            beaconBuffer[beaconKey] = beaconData
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        default:
            print("Bluetooth state is unknown")
        }
    }
} 
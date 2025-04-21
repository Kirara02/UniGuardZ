import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var isServiceRunning = false
    private var uploadInterval: TimeInterval = 300 // Default 5 minutes
    private var lastUploadedLocation: CLLocation?
    private let MIN_DISTANCE_FILTER: CLLocationDistance = 10 // 10 meters
    private let MIN_TIME_INTERVAL: TimeInterval = 60 // 1 minute
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = MIN_DISTANCE_FILTER
        locationManager.activityType = .other
    }
    
    func startService(interval: TimeInterval = 300) {
        guard !isServiceRunning else { return }
        
        uploadInterval = interval
        locationManager.requestAlwaysAuthorization()
        
        // Start significant location changes for better battery efficiency
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Start standard location updates
        locationManager.startUpdatingLocation()
        
        // Start timer to upload location based on the provided interval
        timer = Timer.scheduledTimer(withTimeInterval: uploadInterval, repeats: true) { [weak self] _ in
            self?.uploadLocation()
        }
        
        isServiceRunning = true
    }
    
    func stopService() {
        guard isServiceRunning else { return }
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        
        isServiceRunning = false
    }
    
    private func uploadLocation() {
        guard let location = locationManager.location else { return }
        
        // Check if we should upload based on distance and time
        if let lastLocation = lastUploadedLocation {
            let distance = location.distance(from: lastLocation)
            let timeInterval = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            
            // Only upload if significant change in location or time interval exceeded
            if distance < MIN_DISTANCE_FILTER && timeInterval < MIN_TIME_INTERVAL {
                return
            }
        }
        
        let locationData = Models.LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            timestamp: Int(location.timestamp.timeIntervalSince1970 * 1000)
        )
        
        API.APIClient.shared.submitLocation(locationData) { result in
            switch result {
            case .success:
                print("Location uploaded successfully")
                self.lastUploadedLocation = location
            case .failure(let error):
                print("Failed to upload location: \(error)")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if isServiceRunning {
                locationManager.startMonitoringSignificantLocationChanges()
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            stopService()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Check if we should upload based on significant location change
        if let location = locations.last {
            if let lastLocation = lastUploadedLocation {
                let distance = location.distance(from: lastLocation)
                let timeInterval = location.timestamp.timeIntervalSince(lastLocation.timestamp)
                
                if distance >= MIN_DISTANCE_FILTER || timeInterval >= MIN_TIME_INTERVAL {
                    uploadLocation()
                }
            } else {
                // First location update
                uploadLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
} 
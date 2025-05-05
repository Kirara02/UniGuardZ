import Foundation
import CoreLocation
import UserNotifications
import BackgroundTasks

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var isServiceRunning = false
    private var uploadInterval: TimeInterval = 300 // Default 5 minutes
    private var lastUploadedLocation: CLLocation?
    private let MIN_DISTANCE_FILTER: CLLocationDistance = 10 // 10 meters
    private let MIN_TIME_INTERVAL: TimeInterval = 60 // 1 minute
    private var backgroundTimer: Timer?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = MIN_DISTANCE_FILTER
        locationManager.activityType = .other
        setupNotifications()
        setupBackgroundTask()
    }
    
    private func setupBackgroundTask() {
        // Register background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.uniguard.uniguardz.location_update", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
    }
    
    private func handleBackgroundTask(task: BGProcessingTask) {
        // Schedule the next background task
        scheduleBackgroundTask()
        
        // Start a background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // End the background task after a reasonable time
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
            self?.endBackgroundTask()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.uniguard.uniguardz.location_update")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 300) // 5 minutes from now
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logError("Could not schedule background task: \(error.localizedDescription)")
        }
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // Start background timer
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: uploadInterval, repeats: true) { [weak self] _ in
            self?.uploadLocation()
        }
    }
    
    private func endBackgroundTask() {
        backgroundTimer?.invalidate()
        backgroundTimer = nil
        
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logError("Failed to request notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    private func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Location Service"
        content.body = "Uploading location data"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "location_service_notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logError("Failed to show notification: \(error.localizedDescription)")
            }
        }
    }
    
    func startService(interval: TimeInterval = 300) {
        guard !isServiceRunning else { return }
        
        if !ServiceChecker.shared.canStartLocationService() {
            logError("Cannot start location service - Missing permissions or location disabled")
            return
        }
        
        uploadInterval = interval
        locationManager.requestAlwaysAuthorization()
        
        // Start significant location changes for better battery efficiency
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Start standard location updates
        locationManager.startUpdatingLocation()
        
        // Start background task
        startBackgroundTask()
        
        // Schedule background task
        scheduleBackgroundTask()
        
        // Show notification
        createNotification()
        
        isServiceRunning = true
    }
    
    func stopService() {
        guard isServiceRunning else { return }
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        
        // Stop background task
        endBackgroundTask()
        
        // Remove notification
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
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
                self.logDebug("Location uploaded successfully")
                self.lastUploadedLocation = location
            case .failure(let error):
                self.logError("Failed to upload location: \(error.localizedDescription)")
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logError("Location manager error: \(error.localizedDescription)")
    }
    
    // MARK: - Logging
    
    private func logDebug(_ message: String) {
        #if DEBUG
        print("[LocationService] \(message)")
        #endif
    }
    
    private func logError(_ message: String) {
        print("[LocationService] ERROR: \(message)")
    }
} 
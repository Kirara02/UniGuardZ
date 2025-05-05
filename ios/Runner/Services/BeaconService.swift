import Foundation
import CoreLocation
import CoreBluetooth
import UserNotifications
import BackgroundTasks

class BeaconService: NSObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    private let locationManager = CLLocationManager()
    private var peripheralManager: CBPeripheralManager?
    private var isScanning = false
    private var beaconBuffer: [String: Models.BeaconScanData] = [:]
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let UPLOAD_INTERVAL: TimeInterval = 60 // 1 minute
    private let SCAN_INTERVAL: TimeInterval = 1.1 // 1.1 seconds
    private var currentLocation: CLLocation?
    private var isServiceRunning = false
    private var allowedBeacons: [[String: Any]] = []
    private var backgroundTimer: Timer?
    
    static let shared = BeaconService()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        setupNotifications()
        setupBackgroundTask()
    }
    
    private func setupBackgroundTask() {
        // Register background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.uniguard.uniguardz.beacon_scan", using: nil) { task in
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
        
        // Start scanning
        startScanning()
        
        // End the background task after a reasonable time
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
            self?.endBackgroundTask()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.uniguard.uniguardz.beacon_scan")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // 1 minute from now
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
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: UPLOAD_INTERVAL, repeats: true) { [weak self] _ in
            self?.uploadBufferedBeacons()
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
        content.title = "Beacon Service"
        content.body = "Scanning for beacons"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "beacon_service_notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logError("Failed to show notification: \(error.localizedDescription)")
            }
        }
    }
    
    func startService() {
        guard !isServiceRunning else { return }
        
        if !ServiceChecker.shared.canStartBeaconService() {
            logError("Cannot start beacon service - Missing permissions or services disabled")
            return
        }
        
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
        
        // Start background task
        startBackgroundTask()
        
        // Schedule background task
        scheduleBackgroundTask()
        
        // Show notification
        createNotification()
        
        isServiceRunning = true
        isScanning = true
    }
    
    func stopService() {
        guard isServiceRunning else { return }
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        
        // Stop ranging beacons
        let uuid = UUID(uuidString: "YOUR_BEACON_UUID")! // Replace with your beacon UUID
        let region = CLBeaconRegion(uuid: uuid, identifier: "com.uniguard.ugz_app.beacon")
        locationManager.stopRangingBeacons(satisfying: region)
        locationManager.stopMonitoring(for: region)
        
        // Stop background task
        endBackgroundTask()
        
        // Clear buffer
        beaconBuffer.removeAll()
        
        // Remove notification
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        isServiceRunning = false
        isScanning = false
    }
    
    private func uploadBufferedBeacons() {
        guard !beaconBuffer.isEmpty, let location = currentLocation else { return }
        
        for (_, beaconData) in beaconBuffer {
            let beaconRequest = Models.BeaconRequest(
                type: "beacon",
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: Int(Date().timeIntervalSince1970 * 1000),
                beacon: Models.BeaconData(
                    majorValue: beaconData.major,
                    minorValue: beaconData.minor,
                    rssi: beaconData.rssi,
                    batteryLevel: beaconData.batteryLevel
                )
            )
            
            API.APIClient.shared.submitBeacon(beaconRequest) { result in
                switch result {
                case .success:
                    self.logDebug("Beacon data uploaded successfully")
                case .failure(let error):
                    self.logError("Failed to upload beacon data: \(error.localizedDescription)")
                }
            }
        }
        
        // Clear buffer after upload
        beaconBuffer.removeAll()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            let key = "\(beacon.major)-\(beacon.minor)"
            let beaconData = Models.BeaconScanData(
                major: beacon.major.intValue,
                minor: beacon.minor.intValue,
                rssi: beacon.rssi,
                batteryLevel: 0 // iOS doesn't provide battery level directly
            )
            beaconBuffer[key] = beaconData
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if isServiceRunning {
                startService()
            }
        case .denied, .restricted:
            stopService()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            if isServiceRunning {
                startService()
            }
        case .poweredOff, .unauthorized, .unsupported:
            stopService()
        default:
            break
        }
    }
    
    // MARK: - Logging
    
    private func logDebug(_ message: String) {
        #if DEBUG
        print("[BeaconService] \(message)")
        #endif
    }
    
    private func logError(_ message: String) {
        print("[BeaconService] ERROR: \(message)")
    }
} 
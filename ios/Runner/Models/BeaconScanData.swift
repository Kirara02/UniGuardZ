import Foundation

struct BeaconScanData {
    let uuid: String
    let major: Int
    let minor: Int
    let rssi: Int
    let proximity: Int
    let timestamp: TimeInterval
    var latitude: Double?
    var longitude: Double?
} 
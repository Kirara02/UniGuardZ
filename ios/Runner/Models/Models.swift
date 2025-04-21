import Foundation

enum Models {
    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let accuracy: Double
        let timestamp: Int
    }

    struct BeaconRequest: Codable {
        let type: String
        let latitude: Double
        let longitude: Double
        let timestamp: TimeInterval
        let beacon: BeaconData
    }

    struct BeaconData: Codable {
        let majorValue: Int
        let minorValue: Int
        let batteryLevel: Int
    }
} 
import Foundation

enum API {
    class APIClient {
        static let shared = APIClient()
        private let baseURL = "https://ugz-api-668795567730.asia-southeast1.run.app"
        private var headers: [String: String] = [:]
        
        private init() {}
        
        func updateHeaders(_ newHeaders: [String: String]) {
            var updatedHeaders = newHeaders
            // Add Bearer prefix to Authorization header if it exists
            if let authHeader = newHeaders["Authorization"], !authHeader.startsWith("Bearer ") {
                updatedHeaders["Authorization"] = "Bearer \(authHeader)"
            }
            headers = updatedHeaders
        }
        
        func submitLocation(_ request: Models.LocationData) async throws -> Bool {
            let url = URL(string: "\(baseURL)/mobile-api/admin/checkpoint/log")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw NSError(domain: "APIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                }
                throw NSError(domain: "APIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to upload location"])
            }
            
            return true
        }
        
        func submitBeacon(_ request: Models.BeaconRequest) async throws -> Bool {
            let url = URL(string: "\(baseURL)/mobile-api/admin/checkpoint/log")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw NSError(domain: "APIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                }
                throw NSError(domain: "APIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to upload beacon"])
            }
            
            return true
        }
    }

    struct APIError: Codable {
        let success: Bool
        let message: String
    }
} 
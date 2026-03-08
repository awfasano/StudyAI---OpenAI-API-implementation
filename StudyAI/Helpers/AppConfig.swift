import Foundation

enum AppConfig {
    static var revenueCatAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["RevenueCatAPIKey"] as? String else {
            // Fallback for development - in production, always use Config.plist
            return "appl_aiSvbIOaINlPiAzbBObXyNZfbAb"
        }
        return key
    }
}

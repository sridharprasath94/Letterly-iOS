import Foundation

enum AppConfiguration {
    static let developerName = "Sridhar Prasath"

    // MARK: - TODO: Replace before App Store submission

    // Replace id000000000 with the real App Store numeric ID.
    // For a direct review sheet use the itms-apps scheme:
    //   itms-apps://itunes.apple.com/app/id000000000?action=write-review
    static let appStoreURL = URL(string: "https://apps.apple.com/app/letterly/id000000000")!

    // Replace with production legal document URLs.
    static let privacyPolicyURL = URL(string: "https://example.com/letterly/privacy")!
    static let termsOfServiceURL = URL(string: "https://example.com/letterly/terms")!
}

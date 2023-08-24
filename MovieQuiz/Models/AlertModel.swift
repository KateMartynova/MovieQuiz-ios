import Foundation

struct AlertModel {
    //let accessibilityIdentifier: String
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}


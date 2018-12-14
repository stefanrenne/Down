//
//  ErrorHandler.swift
//  Down
//
//  Created by Ruud Puts on 07/11/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import UIKit
import DownKit

import RxSwift
import Result
import RxResult

enum ErrorSourceType {
    case download_deleteItem
    case dvr_addShow
    case dvr_deleteShow
}

protocol ErrorHandling {
    func handle(error: Error, type: ErrorSourceType, source: UIViewController)
}

class ErrorHandler: ErrorHandling {
    func handle(error: Error, type: ErrorSourceType, source: UIViewController) {
        let action: String
        switch type {
        case .download_deleteItem: action = "deleting item"
        case .dvr_addShow: action = "adding show"
        case .dvr_deleteShow: action = "deleting show"
        }

        let title = "Error while \(action)"
        let alert = UIAlertController(title: title, message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

        source.present(alert, animated: true, completion: nil)
    }
}

enum DownError: Error, RxResultError {
    case request(Error)
    case unhandled(Error)

    static func failure(from error: Error) -> DownError {
        switch error.self {
        case is RequestClientError: return .request(error)
        default: return .unhandled(error)
        }
    }
}

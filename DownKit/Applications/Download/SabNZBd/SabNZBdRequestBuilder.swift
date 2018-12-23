//
//  SabNZBdRequestBuilder.swift
//  Down
//
//  Created by Ruud Puts on 22/06/2018
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

class SabNZBdRequestBuilder: DownloadRequestBuilding {
    var application: ApiApplication

    lazy var defaultParameters = ["apikey": application.apiKey]

    required init(application: ApiApplication) {
        self.application = application
    }

    // swiftlint:disable:next function_body_length
    func specification(for apiCall: DownloadApplicationCall) -> RequestSpecification? {
        switch apiCall {
        case .queue: return RequestSpecification(
            host: application.host,
            path: "api?mode=queue&output=json&apikey={apikey}",
            parameters: defaultParameters
        )
        case .pauseQueue: return RequestSpecification(
            host: application.host,
            path: "api?mode=pause&output=json&apikey={apikey}",
            parameters: defaultParameters
        )
        case .resumeQueue: return RequestSpecification(
            host: application.host,
            path: "api?mode=resume&output=json&apikey={apikey}",
            parameters: defaultParameters
        )
        case .history: return RequestSpecification(
            host: application.host,
            path: "api?mode=history&output=json&apikey={apikey}",
            parameters: defaultParameters
        )
        case .purgeHistory: return RequestSpecification(
            host: application.host,
            path: "api?mode=history&name=delete&value=all&output=json&apikey={apikey}",
            parameters: defaultParameters
        )
        case .delete(let item):
            var mode: String
            if item is DownloadQueueItem {
                mode = "queue"
            }
            else {
                mode = "history"
            }

            return RequestSpecification(
                host: application.host,
                path: "api?mode=\(mode)&name=delete&value=\(item.identifier)&output=json&apikey={apikey}",
                parameters: defaultParameters
            )
        }
    }
}

extension SabNZBdRequestBuilder: ApiApplicationRequestBuilding {
    func specification(for apiCall: ApiApplicationCall, credentials: UsernamePassword? = nil) -> RequestSpecification? {
        switch apiCall {
        case .login: return RequestSpecification(
            host: application.host,
            path: "sabnzbd/login",
            authenticationMethod: .form,
            formAuthenticationData: makeDefaultFormAuthenticationData(with: credentials)
        )
        case .apiKey: return RequestSpecification(
            host: application.host,
            path: "config/general"
        )}
    }
}

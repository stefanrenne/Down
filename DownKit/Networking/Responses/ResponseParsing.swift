//
//  ResponseParsing.swift
//  Down
//
//  Created by Ruud Puts on 16/05/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

public protocol ResponseParsing {
    func parseImage(from response: Response) throws -> UIImage
}

enum ParseError: Error, Hashable {
    case noData
    case invalidData
    case invalidJson
    case api(message: String)
    case missingData
}

struct ParsedResult<Type> {
    let data: Type?
    let error: String?
}

extension ResponseParsing {
    func parse(_ response: Response) throws -> String {
        guard let data = response.data else {
            throw ParseError.noData
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    func parseImage(from response: Response) throws -> UIImage {
        guard let data = response.data, let image = UIImage(data: data) else {
            throw ParseError.invalidData
        }

        return image
    }
}

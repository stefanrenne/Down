//
//  SickbeardResponseParserSpec.swift
//  DownKitTests
//
//  Created by Ruud Puts on 14/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

@testable import DownKit
import Quick
import Nimble
import RealmSwift
import SwiftyJSON

class SickbeardResponseParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("SickbeardResponseParser") {
            var sut: SickbeardResponseParser!
            var response: Response!
            
            beforeEach {
                sut = SickbeardResponseParser()
                response = Response()
            }
            
            afterEach {
                response = nil
                sut = nil
            }
            
            context("parse Response") {
                var result: JSON!
                
                afterEach {
                    result = nil
                }
                
                context("without data") {
                    var parseError: ParseError!
                    
                    beforeEach {
                        do {
                            result = try sut.parse(response)
                        }
                        catch {
                            parseError = error as? ParseError
                        }
                    }
                    
                    afterEach {
                        parseError = nil
                    }
                    
                    it("throws no data error") {
                        expect(parseError) == ParseError.noData
                    }
                }
                
                context("from succesful response") {
                    beforeEach {
                        response.data = Data(fromJsonFile: "sickbeard_success")
                        result = try? sut.parse(response)
                    }
                    
                    it("parses the json's data") {
                        expect(result) == ["api_version": 4]
                    }
                }
                
                context("from failure response") {
                    var parseError: ParseError!
                    
                    beforeEach {
                        do {
                            response.data = Data(fromJsonFile: "sickbeard_error")
                            result = try sut.parse(response)
                        }
                        catch {
                            parseError = error as? ParseError
                        }
                    }
                    
                    afterEach {
                        parseError = nil
                    }
                    
                    it("throws api error") {
                        expect(parseError) == ParseError.api(message: "No such cmd: ''")
                    }
                }

                context("from chained command failure response") {
                    var parseError: ParseError!

                    beforeEach {
                        do {
                            response.data = Data(fromJsonFile: "sickbeard_error_chainedcommand")
                            result = try sut.parse(response)
                        }
                        catch {
                            parseError = error as? ParseError
                        }
                    }

                    afterEach {
                        parseError = nil
                    }

                    it("throws api error") {
                        expect(parseError) == ParseError.api(message: "Show not found")
                    }
                }
                
                context("from invalid response") {
                    var parseError: ParseError!
                    
                    beforeEach {
                        do {
                            response.data = "invalid response".data(using: .utf8)
                            result = try sut.parse(response)
                        }
                        catch {
                            parseError = error as? ParseError
                        }
                    }
                    
                    afterEach {
                        parseError = nil
                    }
                    
                    it("throws invalid json error") {
                        expect(parseError) == ParseError.invalidJson
                    }
                }
            }
            
            context("parse show list response") {
                var result: [DvrShow]!
                
                beforeEach {
                    response.data = Data(fromJsonFile: "sickbeard_showlist")
                    result = try? sut.parseShows(from: response)
                }
                
                afterEach {
                    result = nil
                }
                
                it("parses 1 show") {
                    expect(result.count) == 1
                }
                
                it("parses the show's id") {
                    expect(result.first?.identifier) == "78804"
                }
                
                it("parses the show's name") {
                    expect(result.first?.name) == "Doctor Who (2005)"
                }
                
                it("parses the show's quality") {
                    expect(result.first?.quality) == Quality.hd720p
                }
            }
            
            context("parse show details response") {
                var result: DvrShow!
                
                beforeEach {
                    response.data = Data(fromJsonFile: "sickbeard_showdetails")
                    result = try? sut.parseShowDetails(from: response)
                }
                
                afterEach {
                    result = nil
                }
                
                it("sets partial show identifier") {
                    expect(result.identifier) == DvrShow.partialIdentifier
                }
                
                it("parses the show's name") {
                    expect(result.name) == "Doctor Who (2005)"
                }
                
                it("parses the show's quality") {
                    expect(result.quality) == Quality.hd720p
                }
                
                it("parses 1 season") {
                    expect(result.seasons.count) == 1
                }
                
                it("parses the season's id") {
                    expect(result.seasons.first?.identifier) == "5"
                }
                
                it("parses 2 episodes") {
                    expect(result.seasons.first?.episodes.count) == 2
                }
                
                it("parses the episode's identifiers") {
                    expect(result.seasons.first?.episodes.map { $0.identifier } ?? []) == ["7", "13"]
                }
                
                it("parses the episode's name") {
                    expect(result.seasons.first?.episodes.map { $0.name } ?? []) == ["Amy's Choice", "Unaired: New episode"]
                }
                
                it("parses an episode's airdate") {
                    let expectedComponents = DateComponents(year: 2010,
                                                            month: 5,
                                                            day: 15,
                                                            hour: 0,
                                                            minute: 0,
                                                            second: 0)

                    let components = Calendar.current
                        .dateComponents([.year, .month, .day, .hour, .minute, .second],
                                        from: result.seasons.first?.episodes.first?.airdate ?? Date())

                    expect(components) == expectedComponents
                }

                it("parses an unaired episode date") {
                    expect(result.seasons.first?.episodes.last?.airdate).to(beNil())
                }
                
                it("parses the episode's quality") {
                    expect(result.seasons.first?.episodes.map { $0.quality } ?? []) == [.unknown, .unknown]
                }
                
                it("parses the episode's status") {
                    expect(result.seasons.first?.episodes.map { $0.status } ?? []) == [.ignored, .ignored]
                }
            }

            context("parse search shows response") {
                var result: [DvrShow]!

                beforeEach {
                    response.data = Data(fromJsonFile: "sickbeard_searchshows")
                    result = try? sut.parseSearchShows(from: response)
                }

                afterEach {
                    result = nil
                }

                it("parses 2 shows") {
                    expect(result.count) == 2
                }

                it("parses the first show's id") {
                    expect(result.first?.identifier) == "70336"
                }

                it("parses the first show's name") {
                    expect(result.first?.name) == "The Tonight Show with Jay Leno"
                }

                it("parses the second show's id") {
                    expect(result.last?.identifier) == "113921"
                }

                it("parses the second show's name") {
                    expect(result.last?.name) == "The Jay Leno Show"
                }
            }

            context("parse add show response") {
                var result: Bool!

                beforeEach {
                    response.data = Data(fromJsonFile: "sickbeard_addshow")
                    result = try? sut.parseAddShow(from: response)
                }

                afterEach {
                    result = nil
                }

                it("adds the show succesfully") {
                    expect(result) == true
                }
            }
        }
    }
}

private extension Data {
    init(fromJsonFile filename: String) {
        let bundle = Bundle(for: SickbeardResponseParserSpec.self)
        let filePath = bundle.path(forResource: filename, ofType: "json")!

        // swiftlint:disable force_try
        try! self.init(contentsOf: URL(fileURLWithPath: filePath))
    }
}

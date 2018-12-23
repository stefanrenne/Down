//
//  SabNZBdRequestBuilderSpec.swift
//  DownKitTests
//
//  Created by Ruud Puts on 14/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

@testable import DownKit
import Quick
import Nimble

class SabNZBdRequestBuilderSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("SabNZBdRequestBuilder") {
            var sut: SabNZBdRequestBuilder!
            var result: RequestSpecification?

            var application: DownloadApplication!
            var expectedDefaultParamters: [String: String]!
            
            beforeEach {
                application = DownloadApplication(type: .sabnzbd, host: "host", apiKey: "key")
                expectedDefaultParamters = ["apikey": application.apiKey]
                
                sut = SabNZBdRequestBuilder(application: application)
            }
            
            afterEach {
                result = nil
                sut = nil
                expectedDefaultParamters = nil
                application = nil
            }

            context("download request builder") {
                context("build queue call") {
                    beforeEach {
                        result = sut.specification(for: .queue)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "api?mode=queue&output=json&apikey={apikey}",
                                                               parameters: expectedDefaultParamters)
                    }
                }

                context("build pause queue call") {
                    beforeEach {
                        result = sut.specification(for: .pauseQueue)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "api?mode=pause&output=json&apikey={apikey}",
                                                               parameters: expectedDefaultParamters)
                    }
                }

                context("build resume queue call") {
                    beforeEach {
                        result = sut.specification(for: .resumeQueue)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "api?mode=resume&output=json&apikey={apikey}",
                                                               parameters: expectedDefaultParamters)
                    }
                }

                context("build history call") {
                    beforeEach {
                        result = sut.specification(for: .history)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "api?mode=history&output=json&apikey={apikey}",
                                                               parameters: expectedDefaultParamters)
                    }
                }

                context("build purge history call") {
                    beforeEach {
                        result = sut.specification(for: .purgeHistory)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "api?mode=history&name=delete&value=all&output=json&apikey={apikey}",
                                                               parameters: expectedDefaultParamters)
                    }
                }

                context("build delete item call") {
                    var item: DownloadItem!

                    afterEach {
                        item = nil
                    }

                    context("queue item") {
                        beforeEach {
                            item = DownloadQueueItem(identifier: "15", name: "", category: "",
                                                     sizeMb: 0, remainingMb: 0, remainingTime: 0,
                                                     progress: 0, state: .queued)
                            result = sut.specification(for: .delete(item: item))
                        }

                        it("builds the specification") {
                            expect(result) == RequestSpecification(host: application.host,
                                                                   path: "api?mode=queue&name=delete&value=15&output=json&apikey={apikey}",
                                                                   parameters: expectedDefaultParamters)
                        }
                    }

                    context("history item") {
                        beforeEach {
                            item = DownloadHistoryItem(identifier: "15", name: "", category: "",
                                                       sizeMb: 0, progress: 0, finishDate: nil,
                                                       state: .queued)
                            result = sut.specification(for: .delete(item: item))
                        }

                        it("builds the specification") {
                            expect(result) == RequestSpecification(host: application.host,
                                                                   path: "api?mode=history&name=delete&value=15&output=json&apikey={apikey}",
                                                                   parameters: expectedDefaultParamters)
                        }
                    }
                }
            }

            context("api application request builder") {
                context("build login call") {
                    var credentials: UsernamePassword!
                    var expectedFormData: FormAuthenticationData!

                    beforeEach {
                        credentials = ("username", "password")
                        expectedFormData = ["username": credentials.username,
                                            "password": credentials.password]

                        result = sut.specification(for: .login, credentials: credentials)
                    }

                    afterEach {
                        expectedFormData = nil
                        credentials = nil
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "sabnzbd/login",
                                                               authenticationMethod: .form,
                                                               formAuthenticationData: expectedFormData)
                    }
                }

                context("build api key call") {
                    beforeEach {
                        result = sut.specification(for: .apiKey)
                    }

                    it("builds the specification") {
                        expect(result) == RequestSpecification(host: application.host,
                                                               path: "config/general")
                    }
                }
            }
        }
    }
}

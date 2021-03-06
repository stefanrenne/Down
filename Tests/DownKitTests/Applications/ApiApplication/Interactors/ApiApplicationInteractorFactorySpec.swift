//
//  ApiApplicationInteractorFactorySpec.swift
//  DownKitTests
//
//  Created by Ruud Puts on 16/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

@testable import DownKit
import Quick
import Nimble

class ApiApplicationInteractorFactorySpec: QuickSpec {
    override func spec() {
        describe("ApiApplicationInteractorFactory") {
            var sut: ApiApplicationInteractorFactory!
            var application: ApiApplication!
            var dependenciesStub: DownKitDependenciesStub!

            beforeEach {
                dependenciesStub = DownKitDependenciesStub()
                dependenciesStub.applicationAdditionsFactory = ApplicationAdditionsFactory()
                sut = ApiApplicationInteractorFactory(dependencies: dependenciesStub)
                
                application = DownloadApplication(type: .sabnzbd, host: "", apiKey: "")
            }

            afterEach {
                application = nil
                sut = nil
                dependenciesStub = nil
            }

            context("login interactor") {
                var interactor: ApiApplicationLoginInteractor!

                beforeEach {
                    interactor = sut.makeLoginInteractor(for: application, credentials: nil)
                }

                afterEach {
                    interactor = nil
                }

                it("sets the login gateway") {
                    expect(interactor.gateway).to(beAnInstanceOf(ApiApplicationLoginGateway.self))
                }
            }

            context("key interactor") {
                var interactor: ApiApplicationApiKeyInteractor!

                beforeEach {
                    interactor = sut.makeApiKeyInteractor(for: application, credentials: nil)
                }

                afterEach {
                    interactor = nil
                }

                it("sets the apikey gateway") {
                    expect(interactor.gateway).to(beAnInstanceOf(ApiApplicationApiKeyGateway.self))
                }
            }
        }
    }
}

//
//  RequestGatewayInteractorSpec.swift
//  DownKitTests
//
//  Created by Ruud Puts on 21/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

@testable import DownKit
import RxSwift
import Quick
import Nimble

class RequestGatewayInteractorSpec: QuickSpec {
    override func spec() {
        describe("RequestGatewayInteractor") {
            var sut: RequestGatewayInteractor<RequestGatewayMock>!
            var gateway: RequestGatewayMock!
            
            beforeEach {
                gateway = RequestGatewayMock()
                gateway.stubs.execute = Observable.just(0)
                sut = RequestGatewayInteractor(gateway: gateway)
            }
            
            afterEach {
                sut = nil
                gateway = nil
            }
            
            context("observing") {
                var result: Any!
                
                beforeEach {
                    // swiftlint:disable force_try
                    result = try! sut.observe()
                        .toBlocking()
                        .first()
                }
                
                afterEach {
                    result = nil
                }
                
                it("executes the gateway") {
                    expect(result as? Int) == 0
                }
            }
        }
    }
}
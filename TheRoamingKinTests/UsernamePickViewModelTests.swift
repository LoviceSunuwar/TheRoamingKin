//
//  UsernamePickViewModelTests.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import XCTest
import Combine
@testable import TheRoamingKin

@MainActor
final class UsernamePickViewModelTests: XCTestCase {

    var viewModel: UsernamePickViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = UsernamePickViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

//    func testUsernameAvailability() async {
//           let expectation = XCTestExpectation(description: "Username availability updates")
//
//           viewModel.username = "validuser123"
//
//           DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//               if self.viewModel.isUsernameAvailable != nil {
//                   expectation.fulfill()
//               }
//           }
//
//           await fulfillment(of: [expectation], timeout: 4)
//           XCTAssertNotNil(viewModel.isUsernameAvailable)
//       }

    func testAvatarSelectionAffectsCanContinue() {
        viewModel.isUsernameAvailable = true
        viewModel.selectedAvatar = "03"

        XCTAssertTrue(viewModel.canContinue)

        viewModel.selectedAvatar = nil
        XCTAssertFalse(viewModel.canContinue)
    }

    func testInvalidUsernameDisablesContinue() {
        viewModel.username = "abc"  // still invalid
        viewModel.selectedAvatar = "01"
        viewModel.isUsernameAvailable = nil  // mimic unknown status
        XCTAssertFalse(viewModel.canContinue)
    }

 
    func testMissingAvatarDisablesContinue() {
        viewModel.username = "validusername"
        viewModel.isUsernameAvailable = true
        viewModel.selectedAvatar = nil

        XCTAssertFalse(viewModel.canContinue)
    }

    func testValidStateEnablesContinue() {
        viewModel.username = "validusername"
        viewModel.isUsernameAvailable = true
        viewModel.selectedAvatar = "05"

        XCTAssertTrue(viewModel.canContinue)
    }
}

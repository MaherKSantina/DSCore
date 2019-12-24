import XCTest
import FluentMySQL
@testable import DSCore

final class DSCoreTests: WMSTestCase {
    func testAB_InnerJoin_ShouldGetCorrectly() {

        do {
            _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
            _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
            let items = try conn.raw("Select * from Test1").all(decoding: ModelAB.self).wait()
            XCTAssertEqual(items.count, 1)
        }
        catch {
            if let e = error as? DecodingError {
                XCTFail(e.debugDescription)
            }
            else {
                XCTFail()
            }
        }
    }
}

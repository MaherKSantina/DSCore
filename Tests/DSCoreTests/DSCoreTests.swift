import XCTest
import FluentMySQL
@testable import DSCore

final class DSCoreTests: WMSTestCase {

    func testAB_InnerJoin_OneRowMissing_ShouldGetCorrectly() {
        try! ModelA.revert(on: conn).wait()
        try! ModelA.prepare(on: conn).wait()
        try! ModelB.revert(on: conn).wait()
        try! ModelB.prepare(on: conn).wait()

                InnerJoinModelAB.join = DSJoinRelationship(type: .inner, key1: "attributea2", key2: "attributeba2")
                do {
                    _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
    //                _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
                    let items = try InnerJoinModelAB.all(req: conn).wait()
                    XCTAssertEqual(items.count, 0)
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

    func testAB_InnerJoin_WithRows_ShouldGetCorrectly() {

        InnerJoinModelAB.join = DSJoinRelationship(type: .inner, key1: "attributea2", key2: "attributeba2")
        do {
            _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
            _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
            let items = try InnerJoinModelAB.all(req: conn).wait()
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

    func testAB_InnerJoin_First_WithRows_ShouldGetCorrectly() throws {

        InnerJoinModelAB.join = DSJoinRelationship(type: .inner, key1: "attributea2", key2: "attributeba2")
//        do {
            _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
            _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()

            _ = try ModelA(id: nil, attributea1: "a21", attributea2: "ea22").save(on: conn).wait()
            _ = try ModelB(id: nil, attributeb1: "b21", attributeb2: "b22", attributeba2: "ea22").save(on: conn).wait()

            let item = try InnerJoinModelAB.first(where: "ModelA_attributea2 = 'ea22'", req: conn).wait()
            XCTAssertEqual(item?.ModelA_attributea1, "a21")
//        }
//        catch {
//            if let e = error as? DecodingError {
//                XCTFail(e.debugDescription)
//            }
//            else {
//                XCTFail()
//            }
//        }
    }

    func testAB_LeftJoin_ShouldGetCorrectly() {
        do {
            _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
//            _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
            let items = try LeftJoinModelAB.all(req: conn).wait()
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

    func testAB_RightJoin_ShouldGetCorrectly() {
            do {
//                _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
                _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
                let items = try RightJoinModelAB.all(req: conn).wait()
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

    func test_NModelView3() throws {
        _ = try ModelA.all(req: conn).wait().forEach{ try $0.delete(on: conn).wait() }
        _ = try ModelB.all(req: conn).wait().forEach{ try $0.delete(on: conn).wait() }
        _ = try ModelC.all(req: conn).wait().forEach{ try $0.delete(on: conn).wait() }

        _ = try ModelA(id: nil, attributea1: "a1", attributea2: "ea2").save(on: conn).wait()
        _ = try ModelB(id: nil, attributeb1: "b1", attributeb2: "b2", attributeba2: "ea2").save(on: conn).wait()
        _ = try ModelC(id: nil, attributec1: "c1", attributec2: "c2", attributeca2: "ea2").save(on: conn).wait()

        _ = try ModelA(id: nil, attributea1: "a21", attributea2: "ea22").save(on: conn).wait()
        _ = try ModelB(id: nil, attributeb1: "b21", attributeb2: "b22", attributeba2: "ea22").save(on: conn).wait()
        _ = try ModelC(id: nil, attributec1: "c21", attributec2: "c22", attributeca2: "ea22").save(on: conn).wait()

        let items = try NModelView3.all(req: conn).wait()

        XCTAssertEqual(items.count, 2)
    }
}

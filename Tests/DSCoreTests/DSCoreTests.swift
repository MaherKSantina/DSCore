import XCTest
import Fluent
@testable import DSCore

final class DSCoreTests: XCTestCase {

    func test_DSParent_flatten_ShouldFlattenCorrectly() {
        final class MockParent: DSParent, DSIdentifiable {

            typealias Child = MockChild

            static var childKeyPath: WritableKeyPath<MockParent, [MockChild]> {
                return \.items
            }

            var id: Int?
            var name: String
            var items: [MockChild]

            init(id: Int?, name: String, items: [MockChild]) {
                self.id = id
                self.name = name
                self.items = items
            }
        }

        final class MockChild {
            var id: Int?
            var nameChild: String

            init(id: Int?, nameChild: String) {
                self.id = id
                self.nameChild = nameChild
            }
        }

        let testData = [
            MockParent(id: 1, name: "Item 1", items: [
                MockChild(id: 1, nameChild: "Item 1 Child 1")
            ]),
            MockParent(id: 1, name: "Item 1", items: [
                MockChild(id: 2, nameChild: "Item 1 Child 2")
            ]),
            MockParent(id: 2, name: "Item 2", items: [
                MockChild(id: 3, nameChild: "Item 2 Child 1")
            ]),
            MockParent(id: 3, name: "Item 3", items: [
                MockChild(id: 4, nameChild: "Item 3 Child 1")
            ]),
            MockParent(id: 4, name: "Item 4", items: []),

        ]

        let finalData = testData.flatten.sorted(by: { $0.id! < $1.id! })

        XCTAssertEqual(finalData[0].items.count, 2)
        XCTAssertEqual(finalData[1].items.count, 1)
        XCTAssertEqual(finalData[2].items.count, 1)
        XCTAssertEqual(finalData[0].items[1].nameChild, "Item 1 Child 2")
        XCTAssertEqual(finalData[2].items[0].nameChild, "Item 3 Child 1")
        XCTAssertEqual(finalData[3].items.count, 0)
    }

    func test_DSParent2_flatten_ShouldFlattenCorrectly() {
        final class MockParent: DSParent2, DSIdentifiable {

            typealias Child1 = MockChild1
            typealias Child2 = MockChild2

            static var childKeyPath1: WritableKeyPath<MockParent, [MockChild1]> {
                return \.children1
            }

            static var childKeyPath2: WritableKeyPath<MockParent, [Child2]> {
                return \.children2
            }

            var id: Int?
            var name: String
            var children1: [MockChild1]
            var children2: [MockChild2]

            init(id: Int?, name: String, children1: [MockChild1], children2: [MockChild2]) {
                self.id = id
                self.name = name
                self.children1 = children1
                self.children2 = children2
            }
        }

        final class MockChild1 {
            var id: Int?
            var nameChild1: String

            init(id: Int?, nameChild1: String) {
                self.id = id
                self.nameChild1 = nameChild1
            }
        }

        final class MockChild2 {
            var id: Int?
            var nameChild2: String

            init(id: Int?, nameChild2: String) {
                self.id = id
                self.nameChild2 = nameChild2
            }
        }

        let testData = [
            MockParent(id: 1, name: "Item 1", children1: [
                MockChild1(id: 1, nameChild1: "Item 1 Child1 1")
            ], children2: [
                MockChild2(id: 2, nameChild2: "Item 1 Child2 1")
            ]),
            MockParent(id: 1, name: "Item 1", children1: [
                MockChild1(id: 2, nameChild1: "Item 1 Child1 2")
            ], children2: [
                MockChild2(id: 3, nameChild2: "Item 1 Child2 2")
            ]),
            MockParent(id: 2, name: "Item 2", children1: [
                MockChild1(id: 3, nameChild1: "Item 2 Child1 1")
            ], children2: []),
            MockParent(id: 3, name: "Item 3", children1: [
                MockChild1(id: 4, nameChild1: "Item 3 Child1 1")
            ], children2: [
                MockChild2(id: 4, nameChild2: "Item 3 Child2 1")
            ]),
            MockParent(id: 4, name: "Item 4", children1: [], children2: []),

        ]

        let finalData = testData.flatten.sorted(by: { $0.id! < $1.id! })

        XCTAssertEqual(finalData[0].children1.count, 2)
        XCTAssertEqual(finalData[0].children2.count, 2)
        XCTAssertEqual(finalData[1].children1.count, 1)
        XCTAssertEqual(finalData[1].children2.count, 0)
        XCTAssertEqual(finalData[2].children1.count, 1)
        XCTAssertEqual(finalData[2].children2.count, 1)
        XCTAssertEqual(finalData[0].children1[1].nameChild1, "Item 1 Child1 2")
        XCTAssertEqual(finalData[2].children1[0].nameChild1, "Item 3 Child1 1")
        XCTAssertEqual(finalData[3].children1.count, 0)
    }
    
}

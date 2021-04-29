import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TwitterAuthTests.allTests),
    ]
}
#endif

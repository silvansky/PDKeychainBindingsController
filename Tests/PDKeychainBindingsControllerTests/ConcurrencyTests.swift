import XCTest
import PDKeychainBindingsController

final class ConcurrencyTests: XCTestCase {
    private let controller = PDKeychainBindingsController.shared()!
    private let bindings = PDKeychainBindings.shared()!
    private let keys = (0..<4).map { "concurrency-test-key-\($0)" }
    private var keychainPath: String!

    override func setUpWithError() throws {
        #if os(macOS)
        keychainPath = NSTemporaryDirectory() + "pdkeychain-tests-\(UUID().uuidString).keychain"
        try controller.useExternalKeychainFile(withPath: keychainPath, password: "test")
        #endif
    }

    override func tearDownWithError() throws {
        keys.forEach { bindings.removeObject(forKey: $0) }
        #if os(macOS)
        try controller.removeExternalKeychainFile()
        controller.useDefaultKeychain()
        #endif
    }

    func testConcurrentReadsAndWritesDoNotCorruptCache() {
        DispatchQueue.concurrentPerform(iterations: 1000) { i in
            let key = keys[i % keys.count]
            if i % 2 == 0 {
                bindings.setString("value-\(i)", forKey: key)
            } else {
                _ = bindings.string(forKey: key)
            }
        }

        for key in keys {
            bindings.setString("final-\(key)", forKey: key)
            XCTAssertEqual(bindings.string(forKey: key), "final-\(key)")
        }
    }

    func testConcurrentRemoveAllDoesNotMutateWhileEnumerating() {
        DispatchQueue.concurrentPerform(iterations: 200) { i in
            if i % 10 == 0 {
                bindings.removeAllObjects()
            } else {
                bindings.setString("value-\(i)", forKey: keys[i % keys.count])
            }
        }

        bindings.removeAllObjects()
        keys.forEach { XCTAssertNil(bindings.string(forKey: $0)) }
    }
}

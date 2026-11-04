import Foundation
import Testing
@testable import Candid

struct ByteInputStreamTests {
    @Test func emptyInputThrows() {
        #expect(throws: (any Error).self) { try ByteInputStream(Data()).readNextByte() }
    }
}

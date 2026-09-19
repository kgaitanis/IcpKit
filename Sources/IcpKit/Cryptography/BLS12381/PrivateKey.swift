import BigInt
import Foundation

// MARK: PrivateKey
public struct PrivateKey {
    private let scalar: BigInt
    public init(scalar: BigInt) throws {
        guard scalar > 0 && scalar <= G2.Curve.order else {
            throw Error.invalidPrivateKey
        }
        self.scalar = scalar
    }
}

public extension PrivateKey {
    
    enum Error: Swift.Error {
        case invalidPrivateKey
    }
    
    func publicKey() -> PublicKey {
        try! .init(
            groupElement: G1(point: G1.generator.point.multiplyPrecomputed(scalar: scalar))
        )
    }
    
    /// Executes `hashToCurve` on the message and then multiplies the result by private key.
    /// S = pk x H(m)
    func sign(
        hashing messageToHash: Data
    ) async throws -> (signature: Signature, message: Message) {
        try await sign(hashing: messageToHash, domainSeperationTag: .g2Basic)
    }
    
    /// multiplies the message by private key.
    /// S = pk x H(m)
    func sign(message: Message) async throws -> Signature {
        let signaturePoint = try message.groupElement * scalar
        return Signature(groupElement: signaturePoint)
    }
}

internal extension PrivateKey {
    /// Executes `hashToCurve` on the message and then multiplies the result by private key.
    /// S = pk x H(m)
    func sign(
        hashing messageToHash: Data,
        domainSeperationTag: DomainSeperationTag
    ) async throws -> (signature: Signature, message: Message) {
        let message = try await Message(hashing: messageToHash, domainSeperationTag: domainSeperationTag)
        let signature = try await sign(message: message)
        return (signature, message)
    }
    
}

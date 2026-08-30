
![IcpKit](IcpKit.png)
[![Build Status][build status badge]][build status] [![Code Coverage][codecov badge]][codecov]
[![Platforms][platforms badge]][swift package] [![][swift versions]][swift package] 
[![License: MIT][license]][license badge] 

A comprehensive iOS package for writing mobile applications that interact with the Internet Computer Protocol (ICP), written in Swift.
IcpKit aims at facilitating the interaction between iOS apps and the ICP blockchain.

For more information about ICP Development, we recommend starting from https://internetcomputer.org/docs/current/references/

## Contributors
The main developer of this package is [Konstantinos Gaitanis](https://github.com/kgaitanis).

Originally developed at [Bity SA](https://bity.com) with support from the [DFinity Foundation Developer Grant Program](https://dfinity.org/grants).

## License
**MIT License** is applicable for all Swift Code (see [LICENSE](LICENSE)).

The BLS12381 Rust Library is licensed by Levi Feldman (see [LICENSE](Sources/bls12381/LICENSE)).

## Installation

### Swift Package Manager
Adding IcpKit as a dependency to your Xcode project is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
...
dependencies: [
    .package(url: "https://github.com/kgaitanis/IcpKit.git", .upToNextMajor(from: "0.2.0"))
]
...
```

The `IcpKit` package defines two libraries `Candid` and `IcpKit`. `Candid` implements the Candid specification and `IcpKit` implements the communication with canisters. To use in your code

```swift
import Candid  // not needed when using the CodeGenerator
import IcpKit
```

## What does it do?

IcpKit will take care of all the encoding, serialisation and cryptography required to communicate with ICP allowing developers to focus on the real functionality of their app and bootstrapping their development cycle.

### Main Functionalities

- `CodeGenerator` Command Line Tool for parsing .did files and generating Swift code that can be directly added to your project.
- `CandidEncoder` and `CandidDecoder` for converting any `Encodable`/`Decodable` to a `CandidValue`
- Candid binary serialisation/deserialisation
- CBOR serialisation
- Cryptographic methods applicable to ICP such as signing and signature verification.
- Basic ICP Models for transactions, accounts, self-authenticating principals etc.
- Ledger and Archive Canister implementation as sample code.

`IcpKit` package is split in 3 products : 

- [`Candid` Library](#candid-library-overview)
- [`IcpKit` Library](#icpkit-library-overview)
- [`CodeGenerator` command line executable](#codegenerator-command-line-tool-overview)

### Candid Library Overview

[Candid](https://github.com/dfinity/candid/blob/master/spec/Candid.md) is the language used to communicate with any ICP canister. It describes the data types used by the canister, and the methods one can call on the canister. Candid is essentially a textual and a binary representation of these types. The binary representation is what is actually being sent/received to/from the canister while the textual representation is used in the Candid Interface Definition files ( `.did`) to describe the interface of a canister.

If you use the `CodeGenerator` tool then you will never have to use `Candid` directly to interact with a canister.

The main classes of the Candid Library are the following :

| Class                                                        | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`CandidValue`](Sources/Candid/CandidValue/CandidValue.swift) | Represents a `CandidValue` in `Swift`. Eg. `.bool(true)`     |
| [`CandidType`](Sources/Candid/CandidType/CandidType.swift)   | Represent the type of a `CandidValue`. Eg. `.option(.integer)` |
| [`CandidSerialiser`](Sources/Candid/Serialisation/CandidSerialiser.swift) and [`CandidDeserialiser`](Sources/Candid/Serialisation/CandidDeserialiser.swift) | Convert any `CandidValue` to/from its binary representation which can be directly sent/received to/from a canister.<br />*NOTE:* Serialising recursive candid values is not supported. |
| [`CandidEncoder`](Sources/Candid/Encoding/CandidEncoder.swift) and [`CandidDecoder`](Sources/Candid/Encoding/CandidDecoder.swift) | Convert any `Encodable`/ `Decodable` Swift object to/from a `CandidValue`. See [Swift/Candid Encoding Rules](#swiftcandid-encoding-rules) |
| [`CandidParser`](Sources/Candid/Parser/CandidParser.swift)   | Parses the contents of a `.did` file and returns a `CandidInterfaceDefinition`, a `CandidType` or a `CandidValue` depending on the type of file parsed (see [Candid Interface Definition files](#candid-interface-definition-files-did)). <br />The `CandidParser` is mostly meant to be used with the provided Command Line Tool but it can be directly called from the your app for cases such as reading values from an online `.did` file, or similar. |

### IcpKit Library Overview

The `IcpKit` Library is built on top of `Candid` and is responsible for the actual communication with the canisters. The role of `IcpKit` is to abstract away the underlying data structures used when calling canister functions. 

The main classes of the `IcpKit` Library are the following : 

| Class                                                        | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`ICPRequestClient`](Sources/IcpKit/ICPRequest/ICPRequestClient.swift) | Responsible for making the `HTTP` requests to the methods of canisters. It receives the arguments of the method as a `CandidValue` and will return the result of the canister as a `CandidValue`. Internally, it will serialise the candid arguments using the `CandidSerialiser`,  sign the request when a `ICPSigningPrincipal` is provided and finally wrap everything in `CBOR`. When a response is received the opposite process is performed to return the `CandidValue`. |
| [`ICPFunction<T,R>`](Sources/ICPKit/ICPRequest/ICPFunction.swift) | Wraps the `CandidEncoder` around the `ICPRequestClient` so that a canister method can be called using `Swift` objects instead of a `CandidValue`. Similarly the canister's response is decoded with `CandidDecoder` to return a `Swift` object. |
| [`LedgerCanister`](Sources/IcpKit/Canisters/ICPLedgerCanister.swift) | Is provided as sample code and is the code generated using `CodeGenerator` from the `Ledger.did` file. It allows to query the ICP balance of any ICP account and to fetch the details of any ICP Block. |
| [`ICPSigningPrincipal`](Sources/ICPKit/Models/ICPSigningPrincipal.swift) | Protocol that must be implemented by your application in order to sign requests. The library provides the function to sign arbitrary data with a private key [ICPCryptography.ellipticSign()](Sources/ICPKit/Cryptography/ICPSignature.swift) but it is the responsibility of your app to handle the private keys. Implementing a concrete `ICPSigningPrincipal` requires you to get the private key required and then call `ellipticSign` and return the result.<br />See [How can I create a Principal](#how-can-i-create-a-principal) |

The [ICPRequestClient](Sources/IcpKit/ICPRequest/ICPRequestClient.swift) class is the communication workhorse of the library allowing to make method calls to any canister.

The [Ledger Canister](Sources/IcpKit/Canisters/ICPLedgerCanister.swift) is provided as a sample implementation which also allows for easy creation of ICP Wallet apps.

### `CodeGenerator` Command Line Tool Overview

To use the `CodeGenerator`, you must first clone the project 

```shell
git clone https://github.com/kosta-bity/IcpKit
cd IcpKit
```

and then you can either use Swift to compile and run or build the executable yourself.

#### Build the executable

From the `IcpKit` root folder :

```shell
./compile_code_generator.sh
```

You will find the executable inside the folder `.build/release/CodeGenerator`. Running the `CodeGenerator` without any arguments will display the help.

#### Use Swift to execute

Alternatively you can use swift to run it from the `IcpKit` root folder :

```shell
swift run CodeGenerator
```

## Candid Interface Definition files (`.did`)

A canister is defined by all the types and methods used to interact with it. Most canisters publish their definition in the `.did` format defined [here](https://github.com/dfinity/candid/blob/master/spec/Candid.md#candid-specification). 

IcpKit can parse these files and generate Swift code that can be included in your iOS/Mac Project to interact with the canister. This effectively abstracts away all technical details regarding the communication.

The `.did` files can be one of two types  :

- A Service Interface definition including type definitions and service methods. These are called interface `.did` files.
- A single candid value. These are called value `.did` files.

#### Development Process for integrating canisters in your app

Assuming that you have a `.did` service interface definition file, the steps to interact with a canister are the following :

- Generate Swift code for the `.did` file using the `CodeGeneratorTool`.
- Add the generated Swift files in your project.
- Modify the generated Swift files as necessary. The kind of modifications that are allowed are :
  - Renaming of types and methods. 
    - Candid naming standards are not the same as Swift naming standards. You might want to respect naming conventions
    - Not all generated types have an assigned name. These are generated as `UnnamedType<n>` and can be renamed to a more readable name.
  - Adding/Modifying documentation.
- Write code that calls the methods of the canister.

### Generating code for interface `.did` files
Here is a simple interface `MyDid.did`:

```candid
type MyVector = vec opt bool;
type FooResult = record { name: text; count: int8 };
service: { 
    foo: (input: MyVector; sorted: bool) -> (FooResult) query
};

```

Using the command

```shell
CodeGenerator -n SimpleExample MyDid.did
```

we get the `SimpleExample.swift` file generated with these contents:

```swift
import IcpKit

enum SimpleExample {
	typealias MyVector = [Bool?]
    
	struct FooResult: Codable {
		let name: String
		let count: Int8
	}  
  
	class Service: ICPService {
		func foo(input: MyVector, sorted: Bool) async throws -> FooResult {
			let caller = ICPQuery<CandidTuple2<MyVector, Bool>, FooResult>(canister, "foo")
			let response = try await caller.callMethod(.init(input, sorted), client, sender: sender)
			return response
		}
	}
}
```

We can then add this file to our project and use it anywhere in our code as follows:

```swift
let client = ICPRequestClient()
let myService = SimpleExample.Service("aaaaa-aa", client)
let myVector: SimpleExample.MyVector = [true, false, nil]
let record = try await myService.foo(input: myVector, sorted: false)
print(record.name)
print(record.count)
```

The code generated is completely type safe and avoids common mistakes such as wrong number types etc...

### Generating Code for value `.did` files

An example of a value `.did` file is the following `phone_book.did`:

```candid
(
	vec {
	   record { name = "MyName"; phone = 1234 : nat; };
	   record { name = "AnotherName"; phone = 4321 : nat; };
	}
)
```

These types of files can be parsed using the following command :

```shell
./CodeGenerator value -n PhoneBook phone_book.did
```

This will generate `PhoneBook.swift` with the following contents :

```swift
enum PhoneBook {
   struct UnnamedType0: Codable {
      let name: String
      let phone: BigUInt
   }
   
   let cValue: [UnnamedType0] = [
   		.init(name: "MyName", phone: 1234),
      .init(name: "AnotherName", phone: 4321),
   ]
}
```

#### Parsing `.did` files during runtime

Your app might require to download a `.did` file, parse it and extract some values from it. This can be done using the `CandidParser`. For example, if we wanted to download and read the above `phone_book.did`

```swift
let phoneBookDidContents: String = try await downloadDid() // download phone_book.did file and read it 
let phoneBookCandidValue: CandidValue = try CandidParser().parseValue(phoneBookContents)
```

We can go one step further and decode the parsed `CandidValue` into a `Swift struct` :

```swift
struct PhoneBookEntry: Decodable {
  let name: String
	let phone: BigUInt
}
let phoneBook: [PhoneBookEntry] = try CandidDecoder().decode(phoneBookCandidValue)
```



### Swift/Candid Encoding Rules

| Candid | Swift | Notes |
| ----------- | ----------- | --------- |
| `bool` | `Bool` | |
| `text` | `String` | utf8 encoding |
| `int` | `BigInt` | |
| `nat` | `BigUInt` | |
| `int<n>` | `Int<n>` | `n = 8, 16, 32, 64`, `Int` corresponds to `int64` |
| `nat<n>` | `UInt<n>` | `n = 8, 16, 32, 64`, `UInt` corresponds to `nat64` |
| `blob` | `Data` | |
| `opt <candid_type>` | `<swift_type>?` | Because of limitations in the Swift compiler, Optional Structs with nil value are encoded as `opt empty`. <br />`CandidEncoder().encode(MyStruct?.none) // .option(.empty) Type of nil Structs can not be determined) |
| `vec <candid_type>` | `[<swift_type>]` |  |
| `record` | `struct <name>: Codable { ... }` | Every record is encoded/decoded to a Swift Codable `struct`. Each record item corresponds to a struct member value with the same name. If the candid item is keyed only by number then the name is `_<number>`.<br />`struct MyStruct: Codable { let a: Bool; let b: String? }` is encoded to `record { a: bool; b: opt text; }` and `record { bool; text; }` decodes to `struct MyStruct2: Codable { let _0: Bool; let _1: String }` |
| `variant` | `enum <name>: Codable { ... }` | Every variant is encoded/decoded to a Swift Codable `enum`. Each variant case corresponds to an enum case with the same name. Associated values are attached to each case using their names when available.<br />`variant { winter, summer }` encodes to `enum Season: Codable { case winter, summer }`<br />`variant { status: int; error: bool; }` encodes to `enum Status { case status(Int); case error(Bool) }` |
| `function` | `CandidFunctionProtocol` | Automatic encoding of Swift functions to a Candid Value is not supported because we can not deduce the function signature from the Swift Types without a value. This is due to Swift's Type system limitations. Decoding is allowed however. |
| `service` | `CandidServiceProtocol` | Encoding is not supported for the same reasons as for functions. |
| `principal` | `CandidPrincipal` |  |
| `null` | `nil` |  |
| `empty` | `nil` |  |
| `reserved` | `nil` |  |

#### `null`,`reserved` and `empty` vs `nil`

When decoding `null`,`reserved` or `empty` from a `CandidValue` to `Swift`, they are always decoded as `nil` in `Swift`. 

When encoding a `nil` from `Swift` to `CandidValue`, it is always encoded as `opt <sub_type>`.

#### `CodingKeys`

The Candid Binary format does not support textual representation of keys for records, variants, functions etc... Rather, a simple hashing method defined [here](https://github.com/dfinity/candid/blob/master/spec/Candid.md#records) as :

```
hash(id) = ( Sum_(i=0..k) utf8(id)[i] * 223^(k-i) ) mod 2^32 where k = |utf8(id)|-1
```

This means that when a CandidValue is deserialised from the binary format, we do not have access to the original key that generated the hash.

The `CandidDecoder` takes care of this automatically for all `Swift structs` by hashing the swift name and then comparing the hashes.

However, due to the way the Swift Decoding System works, we can not do the same for `Swift enums`. This means that for a Swift enum to be decoded from a Deserialised CandidValue (essentially every value received via the `ICPRequestClient`) we need to define the CodingKeys as follows :

- If we are decoding from a variant with named values :

  ```candid
  type NamedVariant = variant { one: int8; two: int16; three: record { a: int8; b: int16 } };
  ```

  We use `CandidCodingKey` to perform the hashing :

  ```swift
  enum NamedVariant {
    case one(Int8)
    case two(Int16)
    case three(a: Int8, b: Int16)
      
    enum CodingKeys: String, CandidCodingKey {
      case one, two, three
    }
    enum ThreeCodingKeys: String, CandidCodingKey {
      case a, b
    }
  }
  ```

- If we are deocding from a variant with unnamed values :

  ```candid
  type UnnamedVariant = variant { int8; int16; record { int8, int16} };
  ```

  We use `Int, CodingKey` to assing integer values to the keys :

  ```swift
  enum UnnamedVariant {
    case anyName(Int8)
    case really(Int16)
    case weCanChoose(here: Int8, too: Int16)
      
    enum CodingKeys: Int, CodingKey {
      case anyName, really, weCanChoose	// as long as we keep the order here
    }
    enum WeCanChooseCodingKeys: Int, CodingKey {
      case here, too										// and here
    }
  }
  ```

See the Swift Documentation regarding Encoding, Decoding and Coding Keys for a deeper understanding.

## Advanced Topics

### How can I manually write code to interact with a canister?
There are several ways to perform a request. Depending if it is a simple query or if the request actually changes the state of the blockchain.

#### Define the method you wish to call :
```swift
let method = ICPMethod(
  canister: ICPSystemCanisters.ledger,
  methodName: "account_balance",
  arg: .record([
    "account": .blob(account.accountId)
  ])
)
```
#### Make the a simple query request:
```swift
let response = try await client.query(method, effectiveCanister: ICPSystemCanisters.ledger)
```
equivalently we can also do
```swift
let response = try await client.query(.uncertified, method, effectiveCanister: ICPSystemCanisters.ledger)
```

#### Make a call request and then poll for the response
```swift
let requestId = try await client.call(method, effectiveCanister: ICPSystemCanisters.ledger)
let response = try await client.pollRequestStatus(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
equivalently we can also do 
```swift
let response = try await client.callAndPoll(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
or even
```swift
let response = try await client.query(.certified, method, effectiveCanister: ICPSystemCanisters.ledger)
```
All these have the exact same result.

### Hot to use `ICPFunction`

The same can be achieved with the following code, only this time by using the `ICPFunction`. This allows us to directly feed an `Encodable` to the function and receive back a `Decodable`. `ICPFunction` will make sure the input is correctly encoded from the input Swift type to a `CandidValue` and the output is decoded from the `CandidValue` to the output Swift type.

```swift
struct Result: Decodable {
	let name: String
	let count: Int?
}
// equivalent Candid definition:
// function (nat) -> ( record { name: text; count: opt int64; } )
let function = ICPFunction<BigUInt, Result>(canister, "foo")
let result = try await function.callMethod(12345)
```

### How can I create a Principal?
#### Starting from a seed
We recommend using the [HdWalletKit.Swift](https://github.com/horizontalsystems/HdWalletKit.Swift) from HorizontalSystems in order to derive the public/private Key Pair from the seed. The ICP derivation path is `m/44'/223'/0'/0/0`

#### Starting from a public/private Key Pair

The public key must be in uncompressed form.

1. Create a `ICPPrincipal` instance using `ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey:)`.
2. If you need to sign requests (eg. to send transactions) you also need to create a `ICPSigningPrincipal`.
3. The main account of this principal can be created using `ICPAccount.mainAccount(of:)`.

#### Implementing a simple `ICPSigningPrincipal`

Here is a minimal `ICPSigningPrincipal`implementation. This is given as an example only. Do not use this code in production as keeping private keys in memory is generally not a good practice.

The `sign` method is purposely `async` to allow for any type of delayed fetching of the private keys (eg. remote access or access to iOS Secure Enclave).

```swift
class SimpleSigningPrincipal: ICPSigningPrincipal {
  private let privateKey: Data
  let rawPublicKey: Data
  let principal: ICPPrincipal
  
  init(publicKey: Data, privateKey: Data) throws {
    self.privateKey = privateKey
    self.rawPublicKey = publicKey
    self.principal = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: publicKey)    
  }
  
  func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
    return try ICPCryptography.ellipticSign(message, domain: domain, with: privateKey)
  }
  
  static func fromMnemonic(_ words: [String]) throws -> SimplePrincipal {
    let seed = HdWalletKit.Mnemonic.seed(mnemonic: words)!
    let xPrivKey = HDExtendedKeyVersion.xprv.rawValue
    let privateKey = try HDPrivateKey(seed: seed, xPrivKey: xPrivKey)
      .derived(at: 44, hardened: true)
      .derived(at: 223, hardened: true)
      .derived(at: 0, hardened: true)
      .derived(at: 0, hardened: false)
      .derived(at: 0, hardened: false)
    let publicKey = privateKey.publicKey(compressed: false)
    return try SimplePrincipal(privateKey: privateKey.raw, uncompressedPublicKey: publicKey.raw)
  }
}
```

### Delegated Identity

`ICPDelegatedIdentity` represents an identity that has been delegated authority to authenticate and sign as a different principal. It validates the delegation chain on initialization and ensures the chain ultimately matches the signing `ICPSigningPrincipal`.

- `fromPublicKeyDer` is the DER-encoded public key of the delegated-from principal.
- `chain` is an ordered array of `ICPSignedDelegation` from `fromPublicKeyDer` to `to`.
- Actual signing is performed by `to`, so `ICPDelegatedIdentity.sign(...)` forwards to `to.sign(...)`.
- Use `unchecked(...)` to skip validation only when the chain is already trusted.

```swift
let delegated = try ICPDelegatedIdentity(
  fromPublicKeyDer: fromDer,
  to: signingIdentity,
  chain: signedDelegations
)
```

## Known Limitations

- Serialisation of recursive candid values leads to infinite loop.
- Encoding of `CandidFunctionProtocol` is not supported as there is no easy way to infer the `CandidTypes` used in the arguments and results of the function. This means that the automatic code generation will fail when calling a canister method that expects another function as input.
- Encoding of `CandidServiceProtocol` is not supported because functions can not be encoded. 
- Encoding of optional `Structs` can not infer the members of the struct. These are encoded as `opt empty` which should be accepted by all canisters according to Candid specifications.


[build status]: https://github.com/kosta-bity/IcpKit/actions
[build status badge]: https://github.com/kosta-bity/IcpKit/actions/workflows/IcpKit-Tests.yml/badge.svg
[swift package]: https://swiftpackageindex.com/kosta-bity/IcpKit
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkosta-bity%2FIcpKit%2Fbadge%3Ftype%3Dplatforms
[codecov badge]: https://codecov.io/gh/kosta-bity/IcpKit/graph/badge.svg?token=QL11UD2IXD
[codecov]: https://codecov.io/gh/kosta-bity/IcpKit
[license]: https://img.shields.io/badge/License-MIT-yellow.svg
[license badge]: https://opensource.org/licenses/MIT
[swift versions]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkosta-bity%2FIcpKit%2Fbadge%3Ftype%3Dswift-versions

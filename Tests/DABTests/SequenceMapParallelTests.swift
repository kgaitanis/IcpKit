import Testing
@testable import DAB

struct SequenceMapParallelTests {
    @Test func emptySequencesDoNotCallTransform() async {
        let mapped = await [Int]().mapParallel { value in
            Issue.record("Transform should not run for an empty sequence")
            return value
        }
        let compacted = await [Int]().compactMapParallel { value -> Int? in
            Issue.record("Transform should not run for an empty sequence")
            return value
        }

        #expect(mapped.isEmpty)
        #expect(compacted.isEmpty)
    }

    @Test func mapsEveryElementExactlyOnceAndPreservesDuplicates() async {
        let calls = InvocationRecorder()
        let input = [3, 1, 3, 2]
        let result = await input.mapParallel { value in
            await calls.record(value)
            return String(value * 2)
        }

        #expect(result.sorted() == ["2", "4", "6", "6"])
        #expect(await calls.values.sorted() == input.sorted())
    }

    @Test func mapsNonArraySequence() async {
        let result = await (1...4).mapParallel { $0 * $0 }
        #expect(result.sorted() == [1, 4, 9, 16])
    }

    @Test func mapPreservesNilResults() async {
        let result = await [1, 2, 3].mapParallel { value -> Int? in
            value == 2 ? nil : value
        }

        #expect(result.count == 3)
        #expect(result.filter { $0 == nil }.count == 1)
        #expect(result.compactMap { $0 }.sorted() == [1, 3])
    }

    @Test func compactMapRemovesOnlyNilResults() async {
        let calls = InvocationRecorder()
        let input = [0, 1, 2, 2, 3]
        let result = await input.compactMapParallel { value -> Int? in
            await calls.record(value)
            return value.isMultiple(of: 2) ? value : nil
        }

        #expect(result.sorted() == [0, 2, 2])
        #expect(await calls.values.sorted() == input.sorted())
    }

    @Test func compactMapCanRemoveEveryResult() async {
        let result = await (1...3).compactMapParallel { _ -> Int? in nil }
        #expect(result.isEmpty)
    }

    @Test func mapPropagatesTransformError() async {
        await #expect(throws: TransformError.rejected(2)) {
            _ = try await [1, 2, 3].mapParallel { value in
                if value == 2 { throw TransformError.rejected(value) }
                return value
            }
        }
    }

    @Test func compactMapPropagatesErrorAlongsideNilResults() async {
        await #expect(throws: TransformError.rejected(2)) {
            _ = try await [1, 2, 3].compactMapParallel { value -> Int? in
                if value == 2 { throw TransformError.rejected(value) }
                return nil
            }
        }
    }

    @Test(arguments: [false, true])
    func transformsCanRunConcurrently(compact: Bool) async throws {
        let calls = InvocationRecorder()
        let transform: @Sendable (Int) async throws -> Int = { value in
            await calls.record(value)
            // Every transform must start before any can finish. The deadline makes
            // a sequential implementation fail instead of hanging the test.
            let clock = ContinuousClock()
            let deadline = clock.now.advanced(by: .seconds(2))
            while await calls.values.count < 3 {
                guard clock.now < deadline else { throw TransformError.concurrencyTimeout }
                try await Task.sleep(for: .milliseconds(1))
            }
            return value
        }
        let result: [Int]
        if compact {
            result = try await [1, 2, 3].compactMapParallel { try await transform($0) }
        } else {
            result = try await [1, 2, 3].mapParallel(transform: transform)
        }

        #expect(result.sorted() == [1, 2, 3])
    }

    @MainActor
    @Test func callableFromActorIsolation() async {
        let mapped = await [1, 2].mapParallel { $0 * 2 }
        let compacted = await [1, 2].compactMapParallel { $0 == 1 ? nil : $0 }

        #expect(mapped.sorted() == [2, 4])
        #expect(compacted == [2])
    }

    private enum TransformError: Error, Equatable {
        case rejected(Int)
        case concurrencyTimeout
    }

    private actor InvocationRecorder {
        private(set) var values: [Int] = []

        func record(_ value: Int) {
            values.append(value)
        }
    }
}

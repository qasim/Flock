struct Benchmark<Input> {
    typealias Body = (Input, ContinuousClock) async throws -> ContinuousClock.Duration
    let body: Body

    init(
        body: @escaping Body
    ) {
        self.body = body
    }

    func run(on input: Input) async throws -> ContinuousClock.Duration {
        let clock = ContinuousClock()
        return try await body(input, clock)
    }
}

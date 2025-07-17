import Testing

@testable import Underneath

@Test func hello() async throws {
  let result = Greeter.hello(name: "World")
  #expect(result == "Hello, World!")
}

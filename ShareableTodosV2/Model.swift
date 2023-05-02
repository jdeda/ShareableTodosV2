import Foundation

struct Todo: Identifiable, Codable {
  let id: UUID
  var description: String
  var isComplete: Bool
}

let mockTodos: [Todo] = [
  .init(id: .init(), description: "Wakeup", isComplete: true),
  .init(id: .init(), description: "Do Homework", isComplete: false),
  .init(id: .init(), description: "Play Videogames", isComplete: true),
  .init(id: .init(), description: "Do Keto", isComplete: false),
  .init(id: .init(), description: "Go to Bed", isComplete: false),
]

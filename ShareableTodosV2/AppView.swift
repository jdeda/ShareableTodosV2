import SwiftUI

struct AppView: View {
  @ObservedObject var vm: AppViewModel = .init()
  var body: some View {
    NavigationStack {
      List {
        ForEach(vm.todos) { todo in
          HStack {
            Button {
              vm.todoIsCompleteToggled(todo)
            } label: {
              Image(systemName: todo.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            
            TextField("", text: .init(
              get: { todo.description },
              set: { vm.todoDescriptionEdited(todo, $0) }
            ))
          }
          .swipeActions {
            Button(role: .destructive) {
              vm.todoSwipedToDelete(todo)
            } label: {
              Image(systemName: "trash")
            }
            
          }
        }
      }
      .navigationTitle("Todos")
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          Text("\(vm.todos.count) todos")
        }
        ToolbarItemGroup(placement: .primaryAction) {
          ShareLink(
            item: vm.todosURL,
            subject: Text("ShareableTodos!"),
            message: Text("\n\nCheck out my todos!"),
            preview: SharePreview(
              "My Shareable Todos",
              image: Image("TodosIcon"),
              icon: Image("TodosIcon")
            )
          ) {
            Image(systemName: "square.and.arrow.up")
              .foregroundColor(.orange)
          }
        }
      }
      .onOpenURL(perform: vm.openURL)
      .alert("Opened URL!", isPresented: $vm.alertIsShowing) {
        Button(role: .cancel) {
          vm.denySavedTodos()
        } label: {
          Text("Deny")
        }
        Button {
          vm.acceptSavedTodos()
        } label: {
          Text("Accept")
        }
      } message: {
        Text("Would you like to replace your todos with the new data?")
      }
      
    }
  }
}

final class AppViewModel: ObservableObject {
  @Published var todos: [Todo] = mockTodos
  @Published var alertIsShowing: Bool = false
  var savedTodos: [Todo]? = nil
  
  var todosURL: URL {
    let data = try! JSONEncoder().encode(todos)
    let JSON = String(data: data, encoding: .utf8)!
    var components = URLComponents()
    components.scheme = "todosLink"
    components.host = ""
    components.queryItems = [
      URLQueryItem(name: "json", value: JSON)
    ]
    return components.url!
  }
  
  
  func todoIsCompleteToggled(_ todo: Todo) {
    let i = todos.firstIndex { $0.id == todo.id }!
    todos[i].isComplete.toggle()
  }
  
  func todoDescriptionEdited(_ todo: Todo, _ newDescription: String) {
    let i = todos.firstIndex { $0.id == todo.id }!
    todos[i].description = newDescription
  }
  
  func todoSwipedToDelete(_ todo: Todo) {
    let i = todos.firstIndex { $0.id == todo.id }!
    todos.remove(at: i)
  }
  
  func openURL(_ url: URL) {
    alertIsShowing = true
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    let dataString = components.queryItems!.first!.value!
    let data = dataString.data(using: .utf8)!
    let todos = try! JSONDecoder().decode([Todo].self, from: data)
    savedTodos = todos
  }
  
  func acceptSavedTodos() {
    guard let savedTodos else { return }
    withAnimation {
      self.todos = savedTodos
      self.savedTodos = nil
    }
  }
  
  func denySavedTodos() {
    self.savedTodos = nil
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

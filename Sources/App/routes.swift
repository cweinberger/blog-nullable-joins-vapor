import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.getRichTodosV1)
    router.get("v2", "todos", use: todoController.getRichTodosV2)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)

    // For test data
    router.post("todos", "import-testdata", use: todoController.importTestData)
    router.delete("todos", use: todoController.deleteAll)
}

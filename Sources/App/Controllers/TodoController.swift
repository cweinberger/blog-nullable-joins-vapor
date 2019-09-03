import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }

    func importTestData(_ req: Request) throws -> Future<[Todo]> {

        // create & save a category
        return TodoCategory(title: "Blog").save(on: req).flatMap { category in

            // create some todos
            let todos = try [
                Todo(title: "Clean up my desk", categoryID: category.requireID()),
                Todo(title: "Install all updates", categoryID: category.requireID()),
                Todo(title: "Prepare medium blog post", categoryID: category.requireID()),
                Todo(title: "Play with the kids"),
                Todo(title: "Write medium blog post", categoryID: category.requireID()),
                Todo(title: "Publish medium blog post", categoryID: category.requireID())
            ]

            return todos
                .map({ $0.save(on: req) })
                .flatten(on: req)
        }
    }

    func deleteAll(_ req: Request) throws -> Future<HTTPStatus> {
        return Todo.query(on: req).delete()
            .flatMap() { _ in
                TodoCategory.query(on: req).delete()
            }.transform(to: .ok)
    }

    func getRichTodosV1(_ req: Request) throws -> Future<[Todo.APIModel]> {
        return Todo.query(on: req)
            // join `TodoCategory` to the result table
            .join(\TodoCategory.id, to: \Todo.categoryID, method: .left)
            // decode the `TodoCategory` fields from the result as well
            .alsoDecode(TodoCategory.self)
            // fetch all results, it will be an array of `(Todo, TodoCategory)`
            .all().map(to: [Todo.APIModel].self) { result in
                // map to our `TodoAPIModel`
                return result.map {
                    Todo.APIModel(
                        todo: $0.0,
                        category: $0.1
                    )
                }
        }
    }

    func getRichTodosV2(_ req: Request) throws -> Future<[Todo.APIModel]> {
        return Todo.query(on: req)
            // join `TodoCategory` to the result table
            .join(\TodoCategory.id, to: \Todo.categoryID, method: .left)
            // decode the `TodoCategory.OptionalFields` and provide the entity name
            .alsoDecode(TodoCategory.OptionalFields.self, TodoCategory.name)
            // fetch all results, it will be an array of `(Todo, TodoCategory.OptionalFields)`
            .all().map(to: [Todo.APIModel].self) { result in
                // map to our `TodoAPIModel`
                return result.map {
                    Todo.APIModel(
                        todo: $0.0,
                        category: TodoCategory($0.1) // transform `TodoCategory.OptionalFields` to `TodoCategory`
                    )
                }
        }
    }
}

extension Todo {

    struct APIModel: Content {
        let id: Int?
        let title: String
        let category: TodoCategory?

        init(todo: Todo, category: TodoCategory? = nil) {
            self.id = todo.id
            self.title = todo.title
            self.category = category
        }
    }
}

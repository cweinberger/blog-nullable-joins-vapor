import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class Todo: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String

    /// The ID of the `TodoCategory` a `Todo` belongs to
    var categoryID: Int?

    /// Creates a new `Todo`.
    init(id: Int? = nil, title: String, categoryID: Int? = nil) {
        self.id = id
        self.title = title
        self.categoryID = categoryID
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }

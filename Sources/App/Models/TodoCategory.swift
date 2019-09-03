import FluentSQLite
import Vapor

final class TodoCategory: SQLiteModel {

    var id: Int?
    var title: String

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension TodoCategory: Migration { }
extension TodoCategory: Content { }

extension TodoCategory {
    struct OptionalFields: Decodable {
        let id: Int?
        let title: String?
    }

    convenience init?(_ optionalFields: OptionalFields) {
        guard let title = optionalFields.title else {
            return nil
        }
        self.init(id: optionalFields.id, title: title)
    }
}

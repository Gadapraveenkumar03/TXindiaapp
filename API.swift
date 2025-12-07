//  This file was automatically generated and should not be edited.

#if canImport(AWSAPIPlugin)
import Foundation

public protocol GraphQLInputValue {
}

public struct GraphQLVariable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

public typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  public var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String

public protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension APISwiftGraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: APISwiftGraphQLOperation {}

public protocol GraphQLMutation: APISwiftGraphQLOperation {}

public protocol GraphQLSubscription: APISwiftGraphQLOperation {}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    public init(from decoder: Decoder) throws {
        if let jsonObject = try? APISwiftJSONValue(from: decoder) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(jsonObject)
            let decodedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            let optionalDictionary = decodedDictionary.mapValues { $0 as Any? }

            self.init(snapshot: optionalDictionary)
        } else {
            self.init(snapshot: [:])
        }
    }
}

enum APISwiftJSONValue: Codable {
    case array([APISwiftJSONValue])
    case boolean(Bool)
    case number(Double)
    case object([String: APISwiftJSONValue])
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: APISwiftJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([APISwiftJSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .array(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)
  
  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  public init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

public typealias JSONObject = [String: Any]

public protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension String: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  public var jsonValue: Any {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: JSONEncodable {
  public var jsonValue: Any {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as JSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: JSONEncodable {
  public var jsonValue: Any {
    return map() { element -> (Any) in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

extension URL: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

#elseif canImport(AWSAppSync)
import AWSAppSync
#endif

public struct CreateUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
    graphQLMap = ["id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var email: String {
    get {
      return graphQLMap["email"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var city: City {
    get {
      return graphQLMap["city"] as! City
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var profilePicture: String? {
    get {
      return graphQLMap["profilePicture"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profilePicture")
    }
  }

  public var phoneNumber: String? {
    get {
      return graphQLMap["phoneNumber"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public enum City: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case dallas
  case houston
  case austin
  case sanAntonio
  case corpusChristi
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "DALLAS": self = .dallas
      case "HOUSTON": self = .houston
      case "AUSTIN": self = .austin
      case "SAN_ANTONIO": self = .sanAntonio
      case "CORPUS_CHRISTI": self = .corpusChristi
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .dallas: return "DALLAS"
      case .houston: return "HOUSTON"
      case .austin: return "AUSTIN"
      case .sanAntonio: return "SAN_ANTONIO"
      case .corpusChristi: return "CORPUS_CHRISTI"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: City, rhs: City) -> Bool {
    switch (lhs, rhs) {
      case (.dallas, .dallas): return true
      case (.houston, .houston): return true
      case (.austin, .austin): return true
      case (.sanAntonio, .sanAntonio): return true
      case (.corpusChristi, .corpusChristi): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelUserConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(email: ModelStringInput? = nil, name: ModelStringInput? = nil, city: ModelCityInput? = nil, profilePicture: ModelStringInput? = nil, phoneNumber: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelUserConditionInput?]? = nil, or: [ModelUserConditionInput?]? = nil, not: ModelUserConditionInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var email: ModelStringInput? {
    get {
      return graphQLMap["email"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var profilePicture: ModelStringInput? {
    get {
      return graphQLMap["profilePicture"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profilePicture")
    }
  }

  public var phoneNumber: ModelStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelUserConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserConditionInput? {
    get {
      return graphQLMap["not"] as! ModelUserConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public enum ModelAttributeTypes: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case binary
  case binarySet
  case bool
  case list
  case map
  case number
  case numberSet
  case string
  case stringSet
  case null
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "binary": self = .binary
      case "binarySet": self = .binarySet
      case "bool": self = .bool
      case "list": self = .list
      case "map": self = .map
      case "number": self = .number
      case "numberSet": self = .numberSet
      case "string": self = .string
      case "stringSet": self = .stringSet
      case "_null": self = .null
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .binary: return "binary"
      case .binarySet: return "binarySet"
      case .bool: return "bool"
      case .list: return "list"
      case .map: return "map"
      case .number: return "number"
      case .numberSet: return "numberSet"
      case .string: return "string"
      case .stringSet: return "stringSet"
      case .null: return "_null"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelAttributeTypes, rhs: ModelAttributeTypes) -> Bool {
    switch (lhs, rhs) {
      case (.binary, .binary): return true
      case (.binarySet, .binarySet): return true
      case (.bool, .bool): return true
      case (.list, .list): return true
      case (.map, .map): return true
      case (.number, .number): return true
      case (.numberSet, .numberSet): return true
      case (.string, .string): return true
      case (.stringSet, .stringSet): return true
      case (.null, .null): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelSizeInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public struct ModelCityInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: City? = nil, ne: City? = nil) {
    graphQLMap = ["eq": eq, "ne": ne]
  }

  public var eq: City? {
    get {
      return graphQLMap["eq"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ne: City? {
    get {
      return graphQLMap["ne"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }
}

public enum EventCategory: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case religious
  case cultural
  case professional
  case kids
  case online
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "RELIGIOUS": self = .religious
      case "CULTURAL": self = .cultural
      case "PROFESSIONAL": self = .professional
      case "KIDS": self = .kids
      case "ONLINE": self = .online
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .religious: return "RELIGIOUS"
      case .cultural: return "CULTURAL"
      case .professional: return "PROFESSIONAL"
      case .kids: return "KIDS"
      case .online: return "ONLINE"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: EventCategory, rhs: EventCategory) -> Bool {
    switch (lhs, rhs) {
      case (.religious, .religious): return true
      case (.cultural, .cultural): return true
      case (.professional, .professional): return true
      case (.kids, .kids): return true
      case (.online, .online): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum ClassifiedCategory: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case jobs
  case rentals
  case buySell
  case services
  case matrimony
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "JOBS": self = .jobs
      case "RENTALS": self = .rentals
      case "BUY_SELL": self = .buySell
      case "SERVICES": self = .services
      case "MATRIMONY": self = .matrimony
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .jobs: return "JOBS"
      case .rentals: return "RENTALS"
      case .buySell: return "BUY_SELL"
      case .services: return "SERVICES"
      case .matrimony: return "MATRIMONY"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ClassifiedCategory, rhs: ClassifiedCategory) -> Bool {
    switch (lhs, rhs) {
      case (.jobs, .jobs): return true
      case (.rentals, .rentals): return true
      case (.buySell, .buySell): return true
      case (.services, .services): return true
      case (.matrimony, .matrimony): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum BusinessCategory: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case restaurant
  case grocery
  case temple
  case medical
  case services
  case education
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "RESTAURANT": self = .restaurant
      case "GROCERY": self = .grocery
      case "TEMPLE": self = .temple
      case "MEDICAL": self = .medical
      case "SERVICES": self = .services
      case "EDUCATION": self = .education
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .restaurant: return "RESTAURANT"
      case .grocery: return "GROCERY"
      case .temple: return "TEMPLE"
      case .medical: return "MEDICAL"
      case .services: return "SERVICES"
      case .education: return "EDUCATION"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: BusinessCategory, rhs: BusinessCategory) -> Bool {
    switch (lhs, rhs) {
      case (.restaurant, .restaurant): return true
      case (.grocery, .grocery): return true
      case (.temple, .temple): return true
      case (.medical, .medical): return true
      case (.services, .services): return true
      case (.education, .education): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct UpdateUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, email: String? = nil, name: String? = nil, city: City? = nil, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
    graphQLMap = ["id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var email: String? {
    get {
      return graphQLMap["email"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var city: City? {
    get {
      return graphQLMap["city"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var profilePicture: String? {
    get {
      return graphQLMap["profilePicture"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profilePicture")
    }
  }

  public var phoneNumber: String? {
    get {
      return graphQLMap["phoneNumber"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct DeleteUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID) {
    graphQLMap = ["id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String {
    get {
      return graphQLMap["description"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var date: String {
    get {
      return graphQLMap["date"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var city: City {
    get {
      return graphQLMap["city"] as! City
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var category: EventCategory {
    get {
      return graphQLMap["category"] as! EventCategory
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var location: String {
    get {
      return graphQLMap["location"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var price: Double? {
    get {
      return graphQLMap["price"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var contactInfo: String? {
    get {
      return graphQLMap["contactInfo"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID {
    get {
      return graphQLMap["userID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct ModelEventConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(title: ModelStringInput? = nil, description: ModelStringInput? = nil, date: ModelStringInput? = nil, city: ModelCityInput? = nil, category: ModelEventCategoryInput? = nil, location: ModelStringInput? = nil, price: ModelFloatInput? = nil, imageUrl: ModelStringInput? = nil, contactInfo: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelEventConditionInput?]? = nil, or: [ModelEventConditionInput?]? = nil, not: ModelEventConditionInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var category: ModelEventCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelEventCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var location: ModelStringInput? {
    get {
      return graphQLMap["location"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var price: ModelFloatInput? {
    get {
      return graphQLMap["price"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var contactInfo: ModelStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelEventConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelEventConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelEventConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelEventConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelEventConditionInput? {
    get {
      return graphQLMap["not"] as! ModelEventConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelEventCategoryInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: EventCategory? = nil, ne: EventCategory? = nil) {
    graphQLMap = ["eq": eq, "ne": ne]
  }

  public var eq: EventCategory? {
    get {
      return graphQLMap["eq"] as! EventCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ne: EventCategory? {
    get {
      return graphQLMap["ne"] as! EventCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }
}

public struct ModelFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct ModelIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public struct UpdateEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, title: String? = nil, description: String? = nil, date: String? = nil, city: City? = nil, category: EventCategory? = nil, location: String? = nil, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var date: String? {
    get {
      return graphQLMap["date"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var city: City? {
    get {
      return graphQLMap["city"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var category: EventCategory? {
    get {
      return graphQLMap["category"] as! EventCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var location: String? {
    get {
      return graphQLMap["location"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var price: Double? {
    get {
      return graphQLMap["price"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var contactInfo: String? {
    get {
      return graphQLMap["contactInfo"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID? {
    get {
      return graphQLMap["userID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct DeleteEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateClassifiedInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID) {
    graphQLMap = ["id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String {
    get {
      return graphQLMap["description"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var category: ClassifiedCategory {
    get {
      return graphQLMap["category"] as! ClassifiedCategory
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: City {
    get {
      return graphQLMap["city"] as! City
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var price: Double? {
    get {
      return graphQLMap["price"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var contactInfo: String {
    get {
      return graphQLMap["contactInfo"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var expiryDate: String {
    get {
      return graphQLMap["expiryDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiryDate")
    }
  }

  public var isActive: Bool {
    get {
      return graphQLMap["isActive"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isActive")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID {
    get {
      return graphQLMap["userID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct ModelClassifiedConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(title: ModelStringInput? = nil, description: ModelStringInput? = nil, category: ModelClassifiedCategoryInput? = nil, city: ModelCityInput? = nil, price: ModelFloatInput? = nil, contactInfo: ModelStringInput? = nil, imageUrl: ModelStringInput? = nil, expiryDate: ModelStringInput? = nil, isActive: ModelBooleanInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelClassifiedConditionInput?]? = nil, or: [ModelClassifiedConditionInput?]? = nil, not: ModelClassifiedConditionInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var category: ModelClassifiedCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelClassifiedCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var price: ModelFloatInput? {
    get {
      return graphQLMap["price"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var contactInfo: ModelStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var expiryDate: ModelStringInput? {
    get {
      return graphQLMap["expiryDate"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiryDate")
    }
  }

  public var isActive: ModelBooleanInput? {
    get {
      return graphQLMap["isActive"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isActive")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelClassifiedConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelClassifiedConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelClassifiedConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelClassifiedConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelClassifiedConditionInput? {
    get {
      return graphQLMap["not"] as! ModelClassifiedConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelClassifiedCategoryInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: ClassifiedCategory? = nil, ne: ClassifiedCategory? = nil) {
    graphQLMap = ["eq": eq, "ne": ne]
  }

  public var eq: ClassifiedCategory? {
    get {
      return graphQLMap["eq"] as! ClassifiedCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ne: ClassifiedCategory? {
    get {
      return graphQLMap["ne"] as! ClassifiedCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }
}

public struct ModelBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateClassifiedInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, title: String? = nil, description: String? = nil, category: ClassifiedCategory? = nil, city: City? = nil, price: Double? = nil, contactInfo: String? = nil, imageUrl: String? = nil, expiryDate: String? = nil, isActive: Bool? = nil, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String? {
    get {
      return graphQLMap["title"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var category: ClassifiedCategory? {
    get {
      return graphQLMap["category"] as! ClassifiedCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: City? {
    get {
      return graphQLMap["city"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var price: Double? {
    get {
      return graphQLMap["price"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var contactInfo: String? {
    get {
      return graphQLMap["contactInfo"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var expiryDate: String? {
    get {
      return graphQLMap["expiryDate"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiryDate")
    }
  }

  public var isActive: Bool? {
    get {
      return graphQLMap["isActive"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isActive")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID? {
    get {
      return graphQLMap["userID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct DeleteClassifiedInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateBusinessInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID) {
    graphQLMap = ["id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var category: BusinessCategory {
    get {
      return graphQLMap["category"] as! BusinessCategory
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: City {
    get {
      return graphQLMap["city"] as! City
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var address: String {
    get {
      return graphQLMap["address"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: String {
    get {
      return graphQLMap["phoneNumber"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var email: String? {
    get {
      return graphQLMap["email"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var website: String? {
    get {
      return graphQLMap["website"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var rating: Double? {
    get {
      return graphQLMap["rating"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rating")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var hours: String? {
    get {
      return graphQLMap["hours"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hours")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID {
    get {
      return graphQLMap["userID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct ModelBusinessConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: ModelStringInput? = nil, category: ModelBusinessCategoryInput? = nil, city: ModelCityInput? = nil, address: ModelStringInput? = nil, phoneNumber: ModelStringInput? = nil, email: ModelStringInput? = nil, website: ModelStringInput? = nil, description: ModelStringInput? = nil, rating: ModelFloatInput? = nil, imageUrl: ModelStringInput? = nil, hours: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelBusinessConditionInput?]? = nil, or: [ModelBusinessConditionInput?]? = nil, not: ModelBusinessConditionInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var category: ModelBusinessCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelBusinessCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var address: ModelStringInput? {
    get {
      return graphQLMap["address"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: ModelStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var email: ModelStringInput? {
    get {
      return graphQLMap["email"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var website: ModelStringInput? {
    get {
      return graphQLMap["website"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var rating: ModelFloatInput? {
    get {
      return graphQLMap["rating"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rating")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var hours: ModelStringInput? {
    get {
      return graphQLMap["hours"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hours")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelBusinessConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelBusinessConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelBusinessConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelBusinessConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelBusinessConditionInput? {
    get {
      return graphQLMap["not"] as! ModelBusinessConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelBusinessCategoryInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: BusinessCategory? = nil, ne: BusinessCategory? = nil) {
    graphQLMap = ["eq": eq, "ne": ne]
  }

  public var eq: BusinessCategory? {
    get {
      return graphQLMap["eq"] as! BusinessCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ne: BusinessCategory? {
    get {
      return graphQLMap["ne"] as! BusinessCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }
}

public struct UpdateBusinessInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, name: String? = nil, category: BusinessCategory? = nil, city: City? = nil, address: String? = nil, phoneNumber: String? = nil, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, userId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var category: BusinessCategory? {
    get {
      return graphQLMap["category"] as! BusinessCategory?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: City? {
    get {
      return graphQLMap["city"] as! City?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var address: String? {
    get {
      return graphQLMap["address"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: String? {
    get {
      return graphQLMap["phoneNumber"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var email: String? {
    get {
      return graphQLMap["email"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var website: String? {
    get {
      return graphQLMap["website"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var rating: Double? {
    get {
      return graphQLMap["rating"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rating")
    }
  }

  public var imageUrl: String? {
    get {
      return graphQLMap["imageUrl"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var hours: String? {
    get {
      return graphQLMap["hours"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hours")
    }
  }

  public var createdAt: String? {
    get {
      return graphQLMap["createdAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: String? {
    get {
      return graphQLMap["updatedAt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: GraphQLID? {
    get {
      return graphQLMap["userID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }
}

public struct DeleteBusinessInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ModelUserFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, email: ModelStringInput? = nil, name: ModelStringInput? = nil, city: ModelCityInput? = nil, profilePicture: ModelStringInput? = nil, phoneNumber: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelUserFilterInput?]? = nil, or: [ModelUserFilterInput?]? = nil, not: ModelUserFilterInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var email: ModelStringInput? {
    get {
      return graphQLMap["email"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var profilePicture: ModelStringInput? {
    get {
      return graphQLMap["profilePicture"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profilePicture")
    }
  }

  public var phoneNumber: ModelStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelUserFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserFilterInput? {
    get {
      return graphQLMap["not"] as! ModelUserFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelEventFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, title: ModelStringInput? = nil, description: ModelStringInput? = nil, date: ModelStringInput? = nil, city: ModelCityInput? = nil, category: ModelEventCategoryInput? = nil, location: ModelStringInput? = nil, price: ModelFloatInput? = nil, imageUrl: ModelStringInput? = nil, contactInfo: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelEventFilterInput?]? = nil, or: [ModelEventFilterInput?]? = nil, not: ModelEventFilterInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var date: ModelStringInput? {
    get {
      return graphQLMap["date"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var category: ModelEventCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelEventCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var location: ModelStringInput? {
    get {
      return graphQLMap["location"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var price: ModelFloatInput? {
    get {
      return graphQLMap["price"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var contactInfo: ModelStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelEventFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelEventFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelEventFilterInput? {
    get {
      return graphQLMap["not"] as! ModelEventFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public enum ModelSortDirection: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case asc
  case desc
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ASC": self = .asc
      case "DESC": self = .desc
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .asc: return "ASC"
      case .desc: return "DESC"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelSortDirection, rhs: ModelSortDirection) -> Bool {
    switch (lhs, rhs) {
      case (.asc, .asc): return true
      case (.desc, .desc): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelClassifiedFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, title: ModelStringInput? = nil, description: ModelStringInput? = nil, category: ModelClassifiedCategoryInput? = nil, city: ModelCityInput? = nil, price: ModelFloatInput? = nil, contactInfo: ModelStringInput? = nil, imageUrl: ModelStringInput? = nil, expiryDate: ModelStringInput? = nil, isActive: ModelBooleanInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelClassifiedFilterInput?]? = nil, or: [ModelClassifiedFilterInput?]? = nil, not: ModelClassifiedFilterInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelStringInput? {
    get {
      return graphQLMap["title"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var category: ModelClassifiedCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelClassifiedCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var price: ModelFloatInput? {
    get {
      return graphQLMap["price"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var contactInfo: ModelStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var expiryDate: ModelStringInput? {
    get {
      return graphQLMap["expiryDate"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiryDate")
    }
  }

  public var isActive: ModelBooleanInput? {
    get {
      return graphQLMap["isActive"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isActive")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelClassifiedFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelClassifiedFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelClassifiedFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelClassifiedFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelClassifiedFilterInput? {
    get {
      return graphQLMap["not"] as! ModelClassifiedFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelBusinessFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, name: ModelStringInput? = nil, category: ModelBusinessCategoryInput? = nil, city: ModelCityInput? = nil, address: ModelStringInput? = nil, phoneNumber: ModelStringInput? = nil, email: ModelStringInput? = nil, website: ModelStringInput? = nil, description: ModelStringInput? = nil, rating: ModelFloatInput? = nil, imageUrl: ModelStringInput? = nil, hours: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, userId: ModelIDInput? = nil, and: [ModelBusinessFilterInput?]? = nil, or: [ModelBusinessFilterInput?]? = nil, not: ModelBusinessFilterInput? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "not": not, "owner": owner]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: ModelStringInput? {
    get {
      return graphQLMap["name"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var category: ModelBusinessCategoryInput? {
    get {
      return graphQLMap["category"] as! ModelBusinessCategoryInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelCityInput? {
    get {
      return graphQLMap["city"] as! ModelCityInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var address: ModelStringInput? {
    get {
      return graphQLMap["address"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: ModelStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var email: ModelStringInput? {
    get {
      return graphQLMap["email"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var website: ModelStringInput? {
    get {
      return graphQLMap["website"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var rating: ModelFloatInput? {
    get {
      return graphQLMap["rating"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rating")
    }
  }

  public var imageUrl: ModelStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var hours: ModelStringInput? {
    get {
      return graphQLMap["hours"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hours")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelBusinessFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelBusinessFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelBusinessFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelBusinessFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelBusinessFilterInput? {
    get {
      return graphQLMap["not"] as! ModelBusinessFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionUserFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, email: ModelSubscriptionStringInput? = nil, name: ModelSubscriptionStringInput? = nil, city: ModelSubscriptionStringInput? = nil, profilePicture: ModelSubscriptionStringInput? = nil, phoneNumber: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionUserFilterInput?]? = nil, or: [ModelSubscriptionUserFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var email: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["email"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var name: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["name"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var city: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["city"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var profilePicture: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["profilePicture"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profilePicture")
    }
  }

  public var phoneNumber: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionUserFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionUserFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionUserFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionUserFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [GraphQLID?]? {
    get {
      return graphQLMap["in"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [GraphQLID?]? {
    get {
      return graphQLMap["notIn"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [String?]? {
    get {
      return graphQLMap["in"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [String?]? {
    get {
      return graphQLMap["notIn"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionEventFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, title: ModelSubscriptionStringInput? = nil, description: ModelSubscriptionStringInput? = nil, date: ModelSubscriptionStringInput? = nil, city: ModelSubscriptionStringInput? = nil, category: ModelSubscriptionStringInput? = nil, location: ModelSubscriptionStringInput? = nil, price: ModelSubscriptionFloatInput? = nil, imageUrl: ModelSubscriptionStringInput? = nil, contactInfo: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, userId: ModelSubscriptionIDInput? = nil, and: [ModelSubscriptionEventFilterInput?]? = nil, or: [ModelSubscriptionEventFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["description"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var date: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["date"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "date")
    }
  }

  public var city: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["city"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var category: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["category"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var location: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["location"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var price: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["price"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var imageUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var contactInfo: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelSubscriptionEventFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionEventFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionEventFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, `in`: [Double?]? = nil, notIn: [Double?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Double?]? {
    get {
      return graphQLMap["in"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Double?]? {
    get {
      return graphQLMap["notIn"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionClassifiedFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, title: ModelSubscriptionStringInput? = nil, description: ModelSubscriptionStringInput? = nil, category: ModelSubscriptionStringInput? = nil, city: ModelSubscriptionStringInput? = nil, price: ModelSubscriptionFloatInput? = nil, contactInfo: ModelSubscriptionStringInput? = nil, imageUrl: ModelSubscriptionStringInput? = nil, expiryDate: ModelSubscriptionStringInput? = nil, isActive: ModelSubscriptionBooleanInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, userId: ModelSubscriptionIDInput? = nil, and: [ModelSubscriptionClassifiedFilterInput?]? = nil, or: [ModelSubscriptionClassifiedFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["title"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["description"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var category: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["category"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["city"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var price: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["price"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var contactInfo: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["contactInfo"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactInfo")
    }
  }

  public var imageUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var expiryDate: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["expiryDate"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiryDate")
    }
  }

  public var isActive: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["isActive"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isActive")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelSubscriptionClassifiedFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionClassifiedFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionClassifiedFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionClassifiedFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public struct ModelSubscriptionBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil) {
    graphQLMap = ["ne": ne, "eq": eq]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }
}

public struct ModelSubscriptionBusinessFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, name: ModelSubscriptionStringInput? = nil, category: ModelSubscriptionStringInput? = nil, city: ModelSubscriptionStringInput? = nil, address: ModelSubscriptionStringInput? = nil, phoneNumber: ModelSubscriptionStringInput? = nil, email: ModelSubscriptionStringInput? = nil, website: ModelSubscriptionStringInput? = nil, description: ModelSubscriptionStringInput? = nil, rating: ModelSubscriptionFloatInput? = nil, imageUrl: ModelSubscriptionStringInput? = nil, hours: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, userId: ModelSubscriptionIDInput? = nil, and: [ModelSubscriptionBusinessFilterInput?]? = nil, or: [ModelSubscriptionBusinessFilterInput?]? = nil, owner: ModelStringInput? = nil) {
    graphQLMap = ["id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "and": and, "or": or, "owner": owner]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["name"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var category: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["category"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var city: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["city"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var address: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["address"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["phoneNumber"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }

  public var email: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["email"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var website: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["website"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var description: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["description"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var rating: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["rating"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rating")
    }
  }

  public var imageUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["imageUrl"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "imageUrl")
    }
  }

  public var hours: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["hours"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hours")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var userId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userID")
    }
  }

  public var and: [ModelSubscriptionBusinessFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionBusinessFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionBusinessFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionBusinessFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var owner: ModelStringInput? {
    get {
      return graphQLMap["owner"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "owner")
    }
  }
}

public final class CreateUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateUser($input: CreateUserInput!, $condition: ModelUserConditionInput) {\n  createUser(input: $input, condition: $condition) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var input: CreateUserInput
  public var condition: ModelUserConditionInput?

  public init(input: CreateUserInput, condition: ModelUserConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createUser", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createUser: CreateUser? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createUser": createUser.flatMap { $0.snapshot }])
    }

    public var createUser: CreateUser? {
      get {
        return (snapshot["createUser"] as? Snapshot).flatMap { CreateUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createUser")
      }
    }

    public struct CreateUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class UpdateUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateUser($input: UpdateUserInput!, $condition: ModelUserConditionInput) {\n  updateUser(input: $input, condition: $condition) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var input: UpdateUserInput
  public var condition: ModelUserConditionInput?

  public init(input: UpdateUserInput, condition: ModelUserConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateUser", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateUser: UpdateUser? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateUser": updateUser.flatMap { $0.snapshot }])
    }

    public var updateUser: UpdateUser? {
      get {
        return (snapshot["updateUser"] as? Snapshot).flatMap { UpdateUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateUser")
      }
    }

    public struct UpdateUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class DeleteUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteUser($input: DeleteUserInput!, $condition: ModelUserConditionInput) {\n  deleteUser(input: $input, condition: $condition) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var input: DeleteUserInput
  public var condition: ModelUserConditionInput?

  public init(input: DeleteUserInput, condition: ModelUserConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteUser", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteUser: DeleteUser? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteUser": deleteUser.flatMap { $0.snapshot }])
    }

    public var deleteUser: DeleteUser? {
      get {
        return (snapshot["deleteUser"] as? Snapshot).flatMap { DeleteUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteUser")
      }
    }

    public struct DeleteUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class CreateEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateEvent($input: CreateEventInput!, $condition: ModelEventConditionInput) {\n  createEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: CreateEventInput
  public var condition: ModelEventConditionInput?

  public init(input: CreateEventInput, condition: ModelEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createEvent: CreateEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createEvent": createEvent.flatMap { $0.snapshot }])
    }

    public var createEvent: CreateEvent? {
      get {
        return (snapshot["createEvent"] as? Snapshot).flatMap { CreateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createEvent")
      }
    }

    public struct CreateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class UpdateEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateEvent($input: UpdateEventInput!, $condition: ModelEventConditionInput) {\n  updateEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: UpdateEventInput
  public var condition: ModelEventConditionInput?

  public init(input: UpdateEventInput, condition: ModelEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateEvent: UpdateEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateEvent": updateEvent.flatMap { $0.snapshot }])
    }

    public var updateEvent: UpdateEvent? {
      get {
        return (snapshot["updateEvent"] as? Snapshot).flatMap { UpdateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateEvent")
      }
    }

    public struct UpdateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class DeleteEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteEvent($input: DeleteEventInput!, $condition: ModelEventConditionInput) {\n  deleteEvent(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: DeleteEventInput
  public var condition: ModelEventConditionInput?

  public init(input: DeleteEventInput, condition: ModelEventConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteEvent", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteEvent: DeleteEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteEvent": deleteEvent.flatMap { $0.snapshot }])
    }

    public var deleteEvent: DeleteEvent? {
      get {
        return (snapshot["deleteEvent"] as? Snapshot).flatMap { DeleteEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteEvent")
      }
    }

    public struct DeleteEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class CreateClassifiedMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateClassified($input: CreateClassifiedInput!, $condition: ModelClassifiedConditionInput) {\n  createClassified(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: CreateClassifiedInput
  public var condition: ModelClassifiedConditionInput?

  public init(input: CreateClassifiedInput, condition: ModelClassifiedConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createClassified", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createClassified: CreateClassified? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createClassified": createClassified.flatMap { $0.snapshot }])
    }

    public var createClassified: CreateClassified? {
      get {
        return (snapshot["createClassified"] as? Snapshot).flatMap { CreateClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createClassified")
      }
    }

    public struct CreateClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class UpdateClassifiedMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateClassified($input: UpdateClassifiedInput!, $condition: ModelClassifiedConditionInput) {\n  updateClassified(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: UpdateClassifiedInput
  public var condition: ModelClassifiedConditionInput?

  public init(input: UpdateClassifiedInput, condition: ModelClassifiedConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateClassified", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateClassified: UpdateClassified? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateClassified": updateClassified.flatMap { $0.snapshot }])
    }

    public var updateClassified: UpdateClassified? {
      get {
        return (snapshot["updateClassified"] as? Snapshot).flatMap { UpdateClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateClassified")
      }
    }

    public struct UpdateClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class DeleteClassifiedMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteClassified($input: DeleteClassifiedInput!, $condition: ModelClassifiedConditionInput) {\n  deleteClassified(input: $input, condition: $condition) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: DeleteClassifiedInput
  public var condition: ModelClassifiedConditionInput?

  public init(input: DeleteClassifiedInput, condition: ModelClassifiedConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteClassified", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteClassified: DeleteClassified? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteClassified": deleteClassified.flatMap { $0.snapshot }])
    }

    public var deleteClassified: DeleteClassified? {
      get {
        return (snapshot["deleteClassified"] as? Snapshot).flatMap { DeleteClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteClassified")
      }
    }

    public struct DeleteClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class CreateBusinessMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateBusiness($input: CreateBusinessInput!, $condition: ModelBusinessConditionInput) {\n  createBusiness(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: CreateBusinessInput
  public var condition: ModelBusinessConditionInput?

  public init(input: CreateBusinessInput, condition: ModelBusinessConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createBusiness", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createBusiness: CreateBusiness? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createBusiness": createBusiness.flatMap { $0.snapshot }])
    }

    public var createBusiness: CreateBusiness? {
      get {
        return (snapshot["createBusiness"] as? Snapshot).flatMap { CreateBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createBusiness")
      }
    }

    public struct CreateBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class UpdateBusinessMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateBusiness($input: UpdateBusinessInput!, $condition: ModelBusinessConditionInput) {\n  updateBusiness(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: UpdateBusinessInput
  public var condition: ModelBusinessConditionInput?

  public init(input: UpdateBusinessInput, condition: ModelBusinessConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateBusiness", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateBusiness: UpdateBusiness? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateBusiness": updateBusiness.flatMap { $0.snapshot }])
    }

    public var updateBusiness: UpdateBusiness? {
      get {
        return (snapshot["updateBusiness"] as? Snapshot).flatMap { UpdateBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateBusiness")
      }
    }

    public struct UpdateBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class DeleteBusinessMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteBusiness($input: DeleteBusinessInput!, $condition: ModelBusinessConditionInput) {\n  deleteBusiness(input: $input, condition: $condition) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var input: DeleteBusinessInput
  public var condition: ModelBusinessConditionInput?

  public init(input: DeleteBusinessInput, condition: ModelBusinessConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteBusiness", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteBusiness: DeleteBusiness? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteBusiness": deleteBusiness.flatMap { $0.snapshot }])
    }

    public var deleteBusiness: DeleteBusiness? {
      get {
        return (snapshot["deleteBusiness"] as? Snapshot).flatMap { DeleteBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteBusiness")
      }
    }

    public struct DeleteBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class GetUserQuery: GraphQLQuery {
  public static let operationString =
    "query GetUser($id: ID!) {\n  getUser(id: $id) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getUser", arguments: ["id": GraphQLVariable("id")], type: .object(GetUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getUser: GetUser? = nil) {
      self.init(snapshot: ["__typename": "Query", "getUser": getUser.flatMap { $0.snapshot }])
    }

    public var getUser: GetUser? {
      get {
        return (snapshot["getUser"] as? Snapshot).flatMap { GetUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getUser")
      }
    }

    public struct GetUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class ListUsersQuery: GraphQLQuery {
  public static let operationString =
    "query ListUsers($filter: ModelUserFilterInput, $limit: Int, $nextToken: String) {\n  listUsers(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    nextToken\n  }\n}"

  public var filter: ModelUserFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelUserFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUsers", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUsers: ListUser? = nil) {
      self.init(snapshot: ["__typename": "Query", "listUsers": listUsers.flatMap { $0.snapshot }])
    }

    public var listUsers: ListUser? {
      get {
        return (snapshot["listUsers"] as? Snapshot).flatMap { ListUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listUsers")
      }
    }

    public struct ListUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelUserConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelUserConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class GetEventQuery: GraphQLQuery {
  public static let operationString =
    "query GetEvent($id: ID!) {\n  getEvent(id: $id) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEvent", arguments: ["id": GraphQLVariable("id")], type: .object(GetEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEvent: GetEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEvent": getEvent.flatMap { $0.snapshot }])
    }

    public var getEvent: GetEvent? {
      get {
        return (snapshot["getEvent"] as? Snapshot).flatMap { GetEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEvent")
      }
    }

    public struct GetEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class ListEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEvents($filter: ModelEventFilterInput, $limit: Int, $nextToken: String) {\n  listEvents(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      description\n      date\n      city\n      category\n      location\n      price\n      imageUrl\n      contactInfo\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var filter: ModelEventFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelEventFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEvents", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEvents: ListEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "listEvents": listEvents.flatMap { $0.snapshot }])
    }

    public var listEvents: ListEvent? {
      get {
        return (snapshot["listEvents"] as? Snapshot).flatMap { ListEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listEvents")
      }
    }

    public struct ListEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelEventConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelEventConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Event"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
          GraphQLField("location", type: .nonNull(.scalar(String.self))),
          GraphQLField("price", type: .scalar(Double.self)),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("contactInfo", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var description: String {
          get {
            return snapshot["description"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var date: String {
          get {
            return snapshot["date"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var category: EventCategory {
          get {
            return snapshot["category"]! as! EventCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var location: String {
          get {
            return snapshot["location"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "location")
          }
        }

        public var price: Double? {
          get {
            return snapshot["price"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "price")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var contactInfo: String? {
          get {
            return snapshot["contactInfo"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "contactInfo")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class EventsByUserIdQuery: GraphQLQuery {
  public static let operationString =
    "query EventsByUserID($userID: ID!, $sortDirection: ModelSortDirection, $filter: ModelEventFilterInput, $limit: Int, $nextToken: String) {\n  eventsByUserID(\n    userID: $userID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      description\n      date\n      city\n      category\n      location\n      price\n      imageUrl\n      contactInfo\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var userID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelEventFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelEventFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userID = userID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("eventsByUserID", arguments: ["userID": GraphQLVariable("userID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(EventsByUserId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(eventsByUserId: EventsByUserId? = nil) {
      self.init(snapshot: ["__typename": "Query", "eventsByUserID": eventsByUserId.flatMap { $0.snapshot }])
    }

    public var eventsByUserId: EventsByUserId? {
      get {
        return (snapshot["eventsByUserID"] as? Snapshot).flatMap { EventsByUserId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "eventsByUserID")
      }
    }

    public struct EventsByUserId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelEventConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelEventConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Event"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
          GraphQLField("location", type: .nonNull(.scalar(String.self))),
          GraphQLField("price", type: .scalar(Double.self)),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("contactInfo", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var description: String {
          get {
            return snapshot["description"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var date: String {
          get {
            return snapshot["date"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var category: EventCategory {
          get {
            return snapshot["category"]! as! EventCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var location: String {
          get {
            return snapshot["location"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "location")
          }
        }

        public var price: Double? {
          get {
            return snapshot["price"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "price")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var contactInfo: String? {
          get {
            return snapshot["contactInfo"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "contactInfo")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class GetClassifiedQuery: GraphQLQuery {
  public static let operationString =
    "query GetClassified($id: ID!) {\n  getClassified(id: $id) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getClassified", arguments: ["id": GraphQLVariable("id")], type: .object(GetClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getClassified: GetClassified? = nil) {
      self.init(snapshot: ["__typename": "Query", "getClassified": getClassified.flatMap { $0.snapshot }])
    }

    public var getClassified: GetClassified? {
      get {
        return (snapshot["getClassified"] as? Snapshot).flatMap { GetClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getClassified")
      }
    }

    public struct GetClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class ListClassifiedsQuery: GraphQLQuery {
  public static let operationString =
    "query ListClassifieds($filter: ModelClassifiedFilterInput, $limit: Int, $nextToken: String) {\n  listClassifieds(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      description\n      category\n      city\n      price\n      contactInfo\n      imageUrl\n      expiryDate\n      isActive\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var filter: ModelClassifiedFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelClassifiedFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listClassifieds", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listClassifieds: ListClassified? = nil) {
      self.init(snapshot: ["__typename": "Query", "listClassifieds": listClassifieds.flatMap { $0.snapshot }])
    }

    public var listClassifieds: ListClassified? {
      get {
        return (snapshot["listClassifieds"] as? Snapshot).flatMap { ListClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listClassifieds")
      }
    }

    public struct ListClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelClassifiedConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelClassifiedConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Classified"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
          GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("price", type: .scalar(Double.self)),
          GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
          GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var description: String {
          get {
            return snapshot["description"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var category: ClassifiedCategory {
          get {
            return snapshot["category"]! as! ClassifiedCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var price: Double? {
          get {
            return snapshot["price"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "price")
          }
        }

        public var contactInfo: String {
          get {
            return snapshot["contactInfo"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "contactInfo")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var expiryDate: String {
          get {
            return snapshot["expiryDate"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "expiryDate")
          }
        }

        public var isActive: Bool {
          get {
            return snapshot["isActive"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isActive")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class ClassifiedsByUserIdQuery: GraphQLQuery {
  public static let operationString =
    "query ClassifiedsByUserID($userID: ID!, $sortDirection: ModelSortDirection, $filter: ModelClassifiedFilterInput, $limit: Int, $nextToken: String) {\n  classifiedsByUserID(\n    userID: $userID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      title\n      description\n      category\n      city\n      price\n      contactInfo\n      imageUrl\n      expiryDate\n      isActive\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var userID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelClassifiedFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelClassifiedFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userID = userID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("classifiedsByUserID", arguments: ["userID": GraphQLVariable("userID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ClassifiedsByUserId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(classifiedsByUserId: ClassifiedsByUserId? = nil) {
      self.init(snapshot: ["__typename": "Query", "classifiedsByUserID": classifiedsByUserId.flatMap { $0.snapshot }])
    }

    public var classifiedsByUserId: ClassifiedsByUserId? {
      get {
        return (snapshot["classifiedsByUserID"] as? Snapshot).flatMap { ClassifiedsByUserId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "classifiedsByUserID")
      }
    }

    public struct ClassifiedsByUserId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelClassifiedConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelClassifiedConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Classified"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
          GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("price", type: .scalar(Double.self)),
          GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
          GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String {
          get {
            return snapshot["title"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var description: String {
          get {
            return snapshot["description"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var category: ClassifiedCategory {
          get {
            return snapshot["category"]! as! ClassifiedCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var price: Double? {
          get {
            return snapshot["price"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "price")
          }
        }

        public var contactInfo: String {
          get {
            return snapshot["contactInfo"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "contactInfo")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var expiryDate: String {
          get {
            return snapshot["expiryDate"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "expiryDate")
          }
        }

        public var isActive: Bool {
          get {
            return snapshot["isActive"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isActive")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class GetBusinessQuery: GraphQLQuery {
  public static let operationString =
    "query GetBusiness($id: ID!) {\n  getBusiness(id: $id) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getBusiness", arguments: ["id": GraphQLVariable("id")], type: .object(GetBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getBusiness: GetBusiness? = nil) {
      self.init(snapshot: ["__typename": "Query", "getBusiness": getBusiness.flatMap { $0.snapshot }])
    }

    public var getBusiness: GetBusiness? {
      get {
        return (snapshot["getBusiness"] as? Snapshot).flatMap { GetBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getBusiness")
      }
    }

    public struct GetBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class ListBusinessesQuery: GraphQLQuery {
  public static let operationString =
    "query ListBusinesses($filter: ModelBusinessFilterInput, $limit: Int, $nextToken: String) {\n  listBusinesses(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      name\n      category\n      city\n      address\n      phoneNumber\n      email\n      website\n      description\n      rating\n      imageUrl\n      hours\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var filter: ModelBusinessFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelBusinessFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listBusinesses", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listBusinesses: ListBusiness? = nil) {
      self.init(snapshot: ["__typename": "Query", "listBusinesses": listBusinesses.flatMap { $0.snapshot }])
    }

    public var listBusinesses: ListBusiness? {
      get {
        return (snapshot["listBusinesses"] as? Snapshot).flatMap { ListBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listBusinesses")
      }
    }

    public struct ListBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelBusinessConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelBusinessConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Business"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
          GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
          GraphQLField("email", type: .scalar(String.self)),
          GraphQLField("website", type: .scalar(String.self)),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("rating", type: .scalar(Double.self)),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("hours", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var category: BusinessCategory {
          get {
            return snapshot["category"]! as! BusinessCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var address: String {
          get {
            return snapshot["address"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "address")
          }
        }

        public var phoneNumber: String {
          get {
            return snapshot["phoneNumber"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var email: String? {
          get {
            return snapshot["email"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var website: String? {
          get {
            return snapshot["website"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "website")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var rating: Double? {
          get {
            return snapshot["rating"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "rating")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var hours: String? {
          get {
            return snapshot["hours"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "hours")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class BusinessesByUserIdQuery: GraphQLQuery {
  public static let operationString =
    "query BusinessesByUserID($userID: ID!, $sortDirection: ModelSortDirection, $filter: ModelBusinessFilterInput, $limit: Int, $nextToken: String) {\n  businessesByUserID(\n    userID: $userID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      name\n      category\n      city\n      address\n      phoneNumber\n      email\n      website\n      description\n      rating\n      imageUrl\n      hours\n      createdAt\n      updatedAt\n      userID\n      owner\n    }\n    nextToken\n  }\n}"

  public var userID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelBusinessFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelBusinessFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userID = userID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("businessesByUserID", arguments: ["userID": GraphQLVariable("userID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(BusinessesByUserId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(businessesByUserId: BusinessesByUserId? = nil) {
      self.init(snapshot: ["__typename": "Query", "businessesByUserID": businessesByUserId.flatMap { $0.snapshot }])
    }

    public var businessesByUserId: BusinessesByUserId? {
      get {
        return (snapshot["businessesByUserID"] as? Snapshot).flatMap { BusinessesByUserId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "businessesByUserID")
      }
    }

    public struct BusinessesByUserId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelBusinessConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelBusinessConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Business"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
          GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
          GraphQLField("email", type: .scalar(String.self)),
          GraphQLField("website", type: .scalar(String.self)),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("rating", type: .scalar(Double.self)),
          GraphQLField("imageUrl", type: .scalar(String.self)),
          GraphQLField("hours", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, owner: String? = nil) {
          self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var category: BusinessCategory {
          get {
            return snapshot["category"]! as! BusinessCategory
          }
          set {
            snapshot.updateValue(newValue, forKey: "category")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var address: String {
          get {
            return snapshot["address"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "address")
          }
        }

        public var phoneNumber: String {
          get {
            return snapshot["phoneNumber"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var email: String? {
          get {
            return snapshot["email"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var website: String? {
          get {
            return snapshot["website"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "website")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var rating: Double? {
          get {
            return snapshot["rating"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "rating")
          }
        }

        public var imageUrl: String? {
          get {
            return snapshot["imageUrl"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "imageUrl")
          }
        }

        public var hours: String? {
          get {
            return snapshot["hours"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "hours")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userID")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnCreateUserSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateUser($filter: ModelSubscriptionUserFilterInput, $owner: String) {\n  onCreateUser(filter: $filter, owner: $owner) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionUserFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateUser", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateUser: OnCreateUser? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateUser": onCreateUser.flatMap { $0.snapshot }])
    }

    public var onCreateUser: OnCreateUser? {
      get {
        return (snapshot["onCreateUser"] as? Snapshot).flatMap { OnCreateUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateUser")
      }
    }

    public struct OnCreateUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnUpdateUserSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateUser($filter: ModelSubscriptionUserFilterInput, $owner: String) {\n  onUpdateUser(filter: $filter, owner: $owner) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionUserFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateUser", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateUser: OnUpdateUser? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateUser": onUpdateUser.flatMap { $0.snapshot }])
    }

    public var onUpdateUser: OnUpdateUser? {
      get {
        return (snapshot["onUpdateUser"] as? Snapshot).flatMap { OnUpdateUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateUser")
      }
    }

    public struct OnUpdateUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnDeleteUserSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteUser($filter: ModelSubscriptionUserFilterInput, $owner: String) {\n  onDeleteUser(filter: $filter, owner: $owner) {\n    __typename\n    id\n    email\n    name\n    city\n    profilePicture\n    phoneNumber\n    createdAt\n    updatedAt\n    events {\n      __typename\n      nextToken\n    }\n    classifieds {\n      __typename\n      nextToken\n    }\n    businesses {\n      __typename\n      nextToken\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionUserFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionUserFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteUser", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteUser: OnDeleteUser? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteUser": onDeleteUser.flatMap { $0.snapshot }])
    }

    public var onDeleteUser: OnDeleteUser? {
      get {
        return (snapshot["onDeleteUser"] as? Snapshot).flatMap { OnDeleteUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteUser")
      }
    }

    public struct OnDeleteUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("email", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("profilePicture", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("events", type: .object(Event.selections)),
        GraphQLField("classifieds", type: .object(Classified.selections)),
        GraphQLField("businesses", type: .object(Business.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, events: Event? = nil, classifieds: Classified? = nil, businesses: Business? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "events": events.flatMap { $0.snapshot }, "classifieds": classifieds.flatMap { $0.snapshot }, "businesses": businesses.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var email: String {
        get {
          return snapshot["email"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }

      public var phoneNumber: String? {
        get {
          return snapshot["phoneNumber"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var events: Event? {
        get {
          return (snapshot["events"] as? Snapshot).flatMap { Event(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "events")
        }
      }

      public var classifieds: Classified? {
        get {
          return (snapshot["classifieds"] as? Snapshot).flatMap { Classified(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "classifieds")
        }
      }

      public var businesses: Business? {
        get {
          return (snapshot["businesses"] as? Snapshot).flatMap { Business(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "businesses")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelEventConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelEventConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Classified: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelClassifiedConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelClassifiedConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelBusinessConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelBusinessConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnCreateEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateEvent($filter: ModelSubscriptionEventFilterInput, $owner: String) {\n  onCreateEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateEvent: OnCreateEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateEvent": onCreateEvent.flatMap { $0.snapshot }])
    }

    public var onCreateEvent: OnCreateEvent? {
      get {
        return (snapshot["onCreateEvent"] as? Snapshot).flatMap { OnCreateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateEvent")
      }
    }

    public struct OnCreateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnUpdateEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateEvent($filter: ModelSubscriptionEventFilterInput, $owner: String) {\n  onUpdateEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateEvent: OnUpdateEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateEvent": onUpdateEvent.flatMap { $0.snapshot }])
    }

    public var onUpdateEvent: OnUpdateEvent? {
      get {
        return (snapshot["onUpdateEvent"] as? Snapshot).flatMap { OnUpdateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateEvent")
      }
    }

    public struct OnUpdateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnDeleteEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteEvent($filter: ModelSubscriptionEventFilterInput, $owner: String) {\n  onDeleteEvent(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    date\n    city\n    category\n    location\n    price\n    imageUrl\n    contactInfo\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionEventFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionEventFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteEvent", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteEvent: OnDeleteEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteEvent": onDeleteEvent.flatMap { $0.snapshot }])
    }

    public var onDeleteEvent: OnDeleteEvent? {
      get {
        return (snapshot["onDeleteEvent"] as? Snapshot).flatMap { OnDeleteEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteEvent")
      }
    }

    public struct OnDeleteEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("category", type: .nonNull(.scalar(EventCategory.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("contactInfo", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, date: String, city: City, category: EventCategory, location: String, price: Double? = nil, imageUrl: String? = nil, contactInfo: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "title": title, "description": description, "date": date, "city": city, "category": category, "location": location, "price": price, "imageUrl": imageUrl, "contactInfo": contactInfo, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var date: String {
        get {
          return snapshot["date"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "date")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var category: EventCategory {
        get {
          return snapshot["category"]! as! EventCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var location: String {
        get {
          return snapshot["location"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var contactInfo: String? {
        get {
          return snapshot["contactInfo"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnCreateClassifiedSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateClassified($filter: ModelSubscriptionClassifiedFilterInput, $owner: String) {\n  onCreateClassified(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionClassifiedFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionClassifiedFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateClassified", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateClassified: OnCreateClassified? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateClassified": onCreateClassified.flatMap { $0.snapshot }])
    }

    public var onCreateClassified: OnCreateClassified? {
      get {
        return (snapshot["onCreateClassified"] as? Snapshot).flatMap { OnCreateClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateClassified")
      }
    }

    public struct OnCreateClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnUpdateClassifiedSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateClassified($filter: ModelSubscriptionClassifiedFilterInput, $owner: String) {\n  onUpdateClassified(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionClassifiedFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionClassifiedFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateClassified", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateClassified: OnUpdateClassified? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateClassified": onUpdateClassified.flatMap { $0.snapshot }])
    }

    public var onUpdateClassified: OnUpdateClassified? {
      get {
        return (snapshot["onUpdateClassified"] as? Snapshot).flatMap { OnUpdateClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateClassified")
      }
    }

    public struct OnUpdateClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnDeleteClassifiedSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteClassified($filter: ModelSubscriptionClassifiedFilterInput, $owner: String) {\n  onDeleteClassified(filter: $filter, owner: $owner) {\n    __typename\n    id\n    title\n    description\n    category\n    city\n    price\n    contactInfo\n    imageUrl\n    expiryDate\n    isActive\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionClassifiedFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionClassifiedFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteClassified", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteClassified.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteClassified: OnDeleteClassified? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteClassified": onDeleteClassified.flatMap { $0.snapshot }])
    }

    public var onDeleteClassified: OnDeleteClassified? {
      get {
        return (snapshot["onDeleteClassified"] as? Snapshot).flatMap { OnDeleteClassified(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteClassified")
      }
    }

    public struct OnDeleteClassified: GraphQLSelectionSet {
      public static let possibleTypes = ["Classified"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(ClassifiedCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("price", type: .scalar(Double.self)),
        GraphQLField("contactInfo", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("expiryDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("isActive", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, title: String, description: String, category: ClassifiedCategory, city: City, price: Double? = nil, contactInfo: String, imageUrl: String? = nil, expiryDate: String, isActive: Bool, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Classified", "id": id, "title": title, "description": description, "category": category, "city": city, "price": price, "contactInfo": contactInfo, "imageUrl": imageUrl, "expiryDate": expiryDate, "isActive": isActive, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return snapshot["title"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "title")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var category: ClassifiedCategory {
        get {
          return snapshot["category"]! as! ClassifiedCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var price: Double? {
        get {
          return snapshot["price"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var contactInfo: String {
        get {
          return snapshot["contactInfo"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "contactInfo")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var expiryDate: String {
        get {
          return snapshot["expiryDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiryDate")
        }
      }

      public var isActive: Bool {
        get {
          return snapshot["isActive"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isActive")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnCreateBusinessSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateBusiness($filter: ModelSubscriptionBusinessFilterInput, $owner: String) {\n  onCreateBusiness(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionBusinessFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBusinessFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateBusiness", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnCreateBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateBusiness: OnCreateBusiness? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateBusiness": onCreateBusiness.flatMap { $0.snapshot }])
    }

    public var onCreateBusiness: OnCreateBusiness? {
      get {
        return (snapshot["onCreateBusiness"] as? Snapshot).flatMap { OnCreateBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateBusiness")
      }
    }

    public struct OnCreateBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnUpdateBusinessSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateBusiness($filter: ModelSubscriptionBusinessFilterInput, $owner: String) {\n  onUpdateBusiness(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionBusinessFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBusinessFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateBusiness", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnUpdateBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateBusiness: OnUpdateBusiness? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateBusiness": onUpdateBusiness.flatMap { $0.snapshot }])
    }

    public var onUpdateBusiness: OnUpdateBusiness? {
      get {
        return (snapshot["onUpdateBusiness"] as? Snapshot).flatMap { OnUpdateBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateBusiness")
      }
    }

    public struct OnUpdateBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class OnDeleteBusinessSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteBusiness($filter: ModelSubscriptionBusinessFilterInput, $owner: String) {\n  onDeleteBusiness(filter: $filter, owner: $owner) {\n    __typename\n    id\n    name\n    category\n    city\n    address\n    phoneNumber\n    email\n    website\n    description\n    rating\n    imageUrl\n    hours\n    createdAt\n    updatedAt\n    userID\n    user {\n      __typename\n      id\n      email\n      name\n      city\n      profilePicture\n      phoneNumber\n      createdAt\n      updatedAt\n      owner\n    }\n    owner\n  }\n}"

  public var filter: ModelSubscriptionBusinessFilterInput?
  public var owner: String?

  public init(filter: ModelSubscriptionBusinessFilterInput? = nil, owner: String? = nil) {
    self.filter = filter
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteBusiness", arguments: ["filter": GraphQLVariable("filter"), "owner": GraphQLVariable("owner")], type: .object(OnDeleteBusiness.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteBusiness: OnDeleteBusiness? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteBusiness": onDeleteBusiness.flatMap { $0.snapshot }])
    }

    public var onDeleteBusiness: OnDeleteBusiness? {
      get {
        return (snapshot["onDeleteBusiness"] as? Snapshot).flatMap { OnDeleteBusiness(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteBusiness")
      }
    }

    public struct OnDeleteBusiness: GraphQLSelectionSet {
      public static let possibleTypes = ["Business"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("category", type: .nonNull(.scalar(BusinessCategory.self))),
        GraphQLField("city", type: .nonNull(.scalar(City.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("rating", type: .scalar(Double.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("hours", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("user", type: .object(User.selections)),
        GraphQLField("owner", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, category: BusinessCategory, city: City, address: String, phoneNumber: String, email: String? = nil, website: String? = nil, description: String? = nil, rating: Double? = nil, imageUrl: String? = nil, hours: String? = nil, createdAt: String, updatedAt: String, userId: GraphQLID, user: User? = nil, owner: String? = nil) {
        self.init(snapshot: ["__typename": "Business", "id": id, "name": name, "category": category, "city": city, "address": address, "phoneNumber": phoneNumber, "email": email, "website": website, "description": description, "rating": rating, "imageUrl": imageUrl, "hours": hours, "createdAt": createdAt, "updatedAt": updatedAt, "userID": userId, "user": user.flatMap { $0.snapshot }, "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var category: BusinessCategory {
        get {
          return snapshot["category"]! as! BusinessCategory
        }
        set {
          snapshot.updateValue(newValue, forKey: "category")
        }
      }

      public var city: City {
        get {
          return snapshot["city"]! as! City
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var address: String {
        get {
          return snapshot["address"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var phoneNumber: String {
        get {
          return snapshot["phoneNumber"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "phoneNumber")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var rating: Double? {
        get {
          return snapshot["rating"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "rating")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var hours: String? {
        get {
          return snapshot["hours"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hours")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var user: User? {
        get {
          return (snapshot["user"] as? Snapshot).flatMap { User(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "user")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .nonNull(.scalar(City.self))),
          GraphQLField("profilePicture", type: .scalar(String.self)),
          GraphQLField("phoneNumber", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, email: String, name: String, city: City, profilePicture: String? = nil, phoneNumber: String? = nil, createdAt: String, updatedAt: String, owner: String? = nil) {
          self.init(snapshot: ["__typename": "User", "id": id, "email": email, "name": name, "city": city, "profilePicture": profilePicture, "phoneNumber": phoneNumber, "createdAt": createdAt, "updatedAt": updatedAt, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String {
          get {
            return snapshot["email"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "email")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var city: City {
          get {
            return snapshot["city"]! as! City
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var profilePicture: String? {
          get {
            return snapshot["profilePicture"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profilePicture")
          }
        }

        public var phoneNumber: String? {
          get {
            return snapshot["phoneNumber"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "phoneNumber")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}
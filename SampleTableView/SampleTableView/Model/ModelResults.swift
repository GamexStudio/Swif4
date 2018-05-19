//
//  ModelResults.swift
//
//  Created by Darshan on 19/05/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ModelResults: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let geometry = "geometry"
    static let reference = "reference"
    static let icon = "icon"
    static let name = "name"
    static let id = "id"
    static let types = "types"
    static let placeId = "place_id"
    static let rating = "rating"
    static let openingHours = "opening_hours"
    static let photos = "photos"
    static let scope = "scope"
    static let vicinity = "vicinity"
  }

  // MARK: Properties
  public var geometry: ModelGeometry?
  public var reference: String?
  public var icon: String?
  public var name: String?
  public var id: String?
  public var types: [String]?
  public var placeId: String?
  public var rating: Float?
  public var openingHours: ModelOpeningHours?
  public var photos: [ModelPhotos]?
  public var scope: String?
  public var vicinity: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    geometry = ModelGeometry(json: json[SerializationKeys.geometry])
    reference = json[SerializationKeys.reference].string
    icon = json[SerializationKeys.icon].string
    name = json[SerializationKeys.name].string
    id = json[SerializationKeys.id].string
    if let items = json[SerializationKeys.types].array { types = items.map { $0.stringValue } }
    placeId = json[SerializationKeys.placeId].string
    rating = json[SerializationKeys.rating].float
    openingHours = ModelOpeningHours(json: json[SerializationKeys.openingHours])
    if let items = json[SerializationKeys.photos].array { photos = items.map { ModelPhotos(json: $0) } }
    scope = json[SerializationKeys.scope].string
    vicinity = json[SerializationKeys.vicinity].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = geometry { dictionary[SerializationKeys.geometry] = value.dictionaryRepresentation() }
    if let value = reference { dictionary[SerializationKeys.reference] = value }
    if let value = icon { dictionary[SerializationKeys.icon] = value }
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = types { dictionary[SerializationKeys.types] = value }
    if let value = placeId { dictionary[SerializationKeys.placeId] = value }
    if let value = rating { dictionary[SerializationKeys.rating] = value }
    if let value = openingHours { dictionary[SerializationKeys.openingHours] = value.dictionaryRepresentation() }
    if let value = photos { dictionary[SerializationKeys.photos] = value.map { $0.dictionaryRepresentation() } }
    if let value = scope { dictionary[SerializationKeys.scope] = value }
    if let value = vicinity { dictionary[SerializationKeys.vicinity] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.geometry = aDecoder.decodeObject(forKey: SerializationKeys.geometry) as? ModelGeometry
    self.reference = aDecoder.decodeObject(forKey: SerializationKeys.reference) as? String
    self.icon = aDecoder.decodeObject(forKey: SerializationKeys.icon) as? String
    self.name = aDecoder.decodeObject(forKey: SerializationKeys.name) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.types = aDecoder.decodeObject(forKey: SerializationKeys.types) as? [String]
    self.placeId = aDecoder.decodeObject(forKey: SerializationKeys.placeId) as? String
    self.rating = aDecoder.decodeObject(forKey: SerializationKeys.rating) as? Float
    self.openingHours = aDecoder.decodeObject(forKey: SerializationKeys.openingHours) as? ModelOpeningHours
    self.photos = aDecoder.decodeObject(forKey: SerializationKeys.photos) as? [ModelPhotos]
    self.scope = aDecoder.decodeObject(forKey: SerializationKeys.scope) as? String
    self.vicinity = aDecoder.decodeObject(forKey: SerializationKeys.vicinity) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(geometry, forKey: SerializationKeys.geometry)
    aCoder.encode(reference, forKey: SerializationKeys.reference)
    aCoder.encode(icon, forKey: SerializationKeys.icon)
    aCoder.encode(name, forKey: SerializationKeys.name)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(types, forKey: SerializationKeys.types)
    aCoder.encode(placeId, forKey: SerializationKeys.placeId)
    aCoder.encode(rating, forKey: SerializationKeys.rating)
    aCoder.encode(openingHours, forKey: SerializationKeys.openingHours)
    aCoder.encode(photos, forKey: SerializationKeys.photos)
    aCoder.encode(scope, forKey: SerializationKeys.scope)
    aCoder.encode(vicinity, forKey: SerializationKeys.vicinity)
  }

}

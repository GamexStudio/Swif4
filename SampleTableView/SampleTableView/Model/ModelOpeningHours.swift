//
//  ModelOpeningHours.swift
//
//  Created by Darshan on 19/05/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ModelOpeningHours: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let weekdayText = "weekday_text"
    static let openNow = "open_now"
  }

  // MARK: Properties
  public var weekdayText: [Any]?
  public var openNow: Bool? = false

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
    if let items = json[SerializationKeys.weekdayText].array { weekdayText = items.map { $0.object} }
    openNow = json[SerializationKeys.openNow].boolValue
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = weekdayText { dictionary[SerializationKeys.weekdayText] = value }
    dictionary[SerializationKeys.openNow] = openNow
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.weekdayText = aDecoder.decodeObject(forKey: SerializationKeys.weekdayText) as? [Any]
    self.openNow = aDecoder.decodeBool(forKey: SerializationKeys.openNow)
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(weekdayText, forKey: SerializationKeys.weekdayText)
    aCoder.encode(openNow, forKey: SerializationKeys.openNow)
  }

}

//
//  ModelGooglePlaces.swift
//
//  Created by Darshan on 19/05/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ModelGooglePlaces: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let results = "results"
    static let htmlAttributions = "html_attributions"
    static let nextPageToken = "next_page_token"
  }

  // MARK: Properties
  public var status: String?
  public var results: [ModelResults]?
  public var htmlAttributions: [Any]?
  public var nextPageToken: String?

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
    status = json[SerializationKeys.status].string
    if let items = json[SerializationKeys.results].array { results = items.map { ModelResults(json: $0) } }
    if let items = json[SerializationKeys.htmlAttributions].array { htmlAttributions = items.map { $0.object} }
    nextPageToken = json[SerializationKeys.nextPageToken].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = results { dictionary[SerializationKeys.results] = value.map { $0.dictionaryRepresentation() } }
    if let value = htmlAttributions { dictionary[SerializationKeys.htmlAttributions] = value }
    if let value = nextPageToken { dictionary[SerializationKeys.nextPageToken] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
    self.results = aDecoder.decodeObject(forKey: SerializationKeys.results) as? [ModelResults]
    self.htmlAttributions = aDecoder.decodeObject(forKey: SerializationKeys.htmlAttributions) as? [Any]
    self.nextPageToken = aDecoder.decodeObject(forKey: SerializationKeys.nextPageToken) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(status, forKey: SerializationKeys.status)
    aCoder.encode(results, forKey: SerializationKeys.results)
    aCoder.encode(htmlAttributions, forKey: SerializationKeys.htmlAttributions)
    aCoder.encode(nextPageToken, forKey: SerializationKeys.nextPageToken)
  }

}

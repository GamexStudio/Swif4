//
//  WSManager.swift
//  SampleAPI
//
//  Created by   on 05/05/18.
//  Copyright © 2018  . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias success = (_ response: JSON) -> Void
public typealias failure = (_ error: Error? , _ isTimeOut: Bool) -> Void


class WSManager: NSObject {
    
    //static let requestHeaders: HTTPHeaders = [
      //    ]
    
    class func POST(_ url: String,
                    param: [String: Any]?,
                    success: @escaping success,
                    failure: @escaping failure) {
        
        print(param ?? [:])
        
            Alamofire.request(url, method: HTTPMethod.post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
                
            case .success:
                let responseJSON = JSON(response.result.value!)
                
                success(responseJSON)
            case .failure(let error):
                if (error as NSError).code == -1001 {
                    print("The request timed out. Pelase try after again.")
                    failure(error, true)
                } else {
                    print(error.localizedDescription)
                    failure(error, false)
                }
                break
            }
        }
    }

}

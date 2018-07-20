//
//  Meteorite.swift
//  DataRoutr
//
//  Created by Zukosky,Jonah on 7/19/18.
//  Copyright © 2018 Zukosky,Jonah. All rights reserved.
//

import Foundation
import MapKit

struct Meteorite: Codable {
    var name: String?
    var id: String?
    var nametype: String?
    var recclass: String?
    var mass: String?
    var fall: String?
    var year: String?
    var reclat: String?
    var reclong: String?
    var GeoLocation: String?
    
    
    
    static func retrieve() -> [Meteorite] {
        guard let fileURL = Bundle.main.url(forResource: "meteorites", withExtension: "json") else { return [] }
        
        do {
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            
            return try decoder.decode([Meteorite].self, from: data)
        } catch let error {
            print(error)
            return []
        }
    }
}

class Singletons {
    static let sharedInstance = Singletons()
    var selectedMeteorites = [Meteorite]()
    var currentRoute: MKRoute?
    var fullRoute: MKRoute?
}

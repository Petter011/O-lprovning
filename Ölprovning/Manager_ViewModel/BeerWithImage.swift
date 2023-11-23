//
//  SwiftUIView.swift
//  Beer Tests
//
//  Created by Petter Gustafsson on 2023-08-07.
//
import SwiftUI
import Foundation

struct ScannedBeerType: Decodable {
    let name: String
    let id: String
}

struct ScannedBeer: Decodable {
    let beerType: ScannedBeerType
    let name: String
    let id: String
    let score: Int
    let note: String
    //let imageData: String? // Added property for base64-encoded image data
}

extension Beer: Encodable {
    enum CodingKeys: CodingKey {
        case id, name, score, note, beerType//, imageData
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(score, forKey: .score)
        try container.encode(note, forKey: .note)
        
        // Encode the relationship if it exists
        if let beerType = beerType {
            try container.encode(beerType, forKey: .beerType)
        }
        // Encode the image data if it exists
        /*if let imageData = image?.base64EncodedString() {
            try container.encode(imageData, forKey: .imageData)
        }*/
    }
}

// Decode image data
/*extension ScannedBeer {
    func getBeerImage() -> UIImage? {
        if let imageDataString = imageData,
           let imageData = Data(base64Encoded: imageDataString) {
            return UIImage(data: imageData)
        }
        return nil
    }
}*/

extension BeerType: Encodable {
    enum CodingKeys: CodingKey {
        case id, name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

    



struct BeerWithImage: Identifiable, Codable {
    var id = UUID()
    var beerType: String
    var beerPoints: Int16
    var beerName: String
    let beerImageData: Data?
    var beerNote: String
    
    // Method to convert beerImageData to UIImage
    func getBeerImage() -> UIImage? {
        if let imageData = beerImageData {
            return UIImage(data: imageData)
        }
        return nil
    }
}
extension Beer {
    func getBeerImage() -> UIImage? {
        if image != nil {
            return UIImage(data: image!)
        }
        return nil
    }
}





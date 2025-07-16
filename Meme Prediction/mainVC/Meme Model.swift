//
//  Meme Model.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 14.07.2025.
//
import UIKit

struct MemeData : Codable {
    var success : Bool
    var data : MemeList
}

struct MemeList: Codable {
    var memes: [Meme]  
}

struct Meme : Codable {
    var id : String
    var name : String
    var url : String
    var width : Int
    var height : Int
    var box_count : Int
    var captions : Int
}

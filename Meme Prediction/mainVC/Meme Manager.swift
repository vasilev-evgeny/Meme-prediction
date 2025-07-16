//
//  Meme Manager.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 14.07.2025.
//
import UIKit


class MemeManager {
    
    func getMeme(completion : @escaping(Result<[Meme], Error>) -> Void) {
        var url = "https://api.imgflip.com/get_memes"
        performRequest(with: url, completion: completion)
    }
    
    private func performRequest(with urlString: String, completion : @escaping (Result<[Meme], Error>) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, _ , error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(MemeData.self, from: data)
                        completion(.success(decodedData.data.memes))
                    } catch {
                        completion(.failure(error))
                        print(error)
                    }
                    print(data)
                }
            }
            task.resume()
        }
    }
    
}

//
//  NetworkService.swift
//  FilmFlow
//
//  Created by Aser Eid on 09/05/2024.
//

import Foundation
protocol NetworkProtocol {
    func fetchData<T : Codable>(from url : URL , responseType : T.Type , completionHandler : @escaping (Result<T ,Error>) -> Void)
}

class NetworkService : NetworkProtocol{
    func fetchData<T>(from url: URL, responseType: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data , response , error in
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completionHandler(.success(json))
            }catch {
                completionHandler(.failure(error))
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }
}

//
//  LocalDataSource.swift
//  FilmFlow
//
//  Created by Aser Eid on 10/05/2024.
//

import Foundation
import CoreData
import UIKit

class LocalDataSource {
    static let shared = LocalDataSource()
    let context : NSManagedObjectContext
    
    private init() {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             fatalError("Unable to get AppDelegate")
         }
         context = appDelegate.persistentContainer.viewContext
     }
    
    func fetchSavedMovies() -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching movies: \(error)")
            return []
        }
    }
    func fetchSavedUpcomingMovies() -> [NSManagedObject] {
        let fetchRequest : NSFetchRequest<UpcomingMovies> = UpcomingMovies.fetchRequest()
        do{
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    func fetchFavMovies() -> [NSManagedObject]{
        let fetchRequest : NSFetchRequest<FavouriteMovies> = FavouriteMovies.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func insertMovie(forEntity entityName : String , movie : Movie){
        
        let moviesEntity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let movieObject = NSManagedObject(entity: moviesEntity!, insertInto: context)
        movieObject.setValue(movie.id, forKey: "id")
        movieObject.setValue(movie.originalTitle, forKey: "title")
        movieObject.setValue(movie.overview, forKey: "desc")
        movieObject.setValue(movie.releaseDate, forKey: "releaseYear")
        movieObject.setValue(movie.voteAverage, forKey: "rating")
        movieObject.setValue(movie.posterPath, forKey: "imageUrl")
        do {
            try context.save()
        }catch let error as NSError {
            print("the error : \(error.localizedDescription)")
        }
    }
    func insertUpcomingMovie(forEntity entityName : String , movie : UpcomingFilm){
        
        let moviesEntity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let movieObject = NSManagedObject(entity: moviesEntity!, insertInto: context)
        movieObject.setValue(movie.id, forKey: "id")
        movieObject.setValue(movie.originalTitle, forKey: "title")
        movieObject.setValue(movie.overview, forKey: "desc")
        movieObject.setValue(movie.releaseDate, forKey: "releaseYear")
        movieObject.setValue(movie.voteAverage, forKey: "rating")
        movieObject.setValue(movie.posterPath, forKey: "imageUrl")
        do {
            try context.save()
        }catch let error as NSError {
            print("the error : \(error.localizedDescription)")
        }
    }
    
    func insertMovieToFav(movie : Movie){
        
        let moviesEntity = NSEntityDescription.entity(forEntityName: "FavouriteMovies", in: context)
        let movieObject = NSManagedObject(entity: moviesEntity!, insertInto: context)
        movieObject.setValue(movie.id, forKey: "id")
        movieObject.setValue(movie.originalTitle, forKey: "title")
        movieObject.setValue(movie.overview, forKey: "desc")
        movieObject.setValue(movie.releaseDate, forKey: "releaseYear")
        movieObject.setValue(movie.voteAverage, forKey: "rating")
        movieObject.setValue(movie.posterPath, forKey: "imageUrl")
        do {
            context.detectConflicts(for: movieObject)
            try context.save()
        }catch let error as NSError {
            print("the error : \(error.localizedDescription)")
        }
    }
    func deleteMovie(movie : NSManagedObject){
            context.delete(movie)
        do{
           try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    func deleteAllData(forEntity entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let persistentContainer = appDelegate.persistentContainer
            
            try persistentContainer.viewContext.execute(batchDeleteRequest)
        
        } catch {
            print("Failed to delete data from \(entityName): \(error)")
        }
    }
    
    func isMovieInFavourite(movie:Movie) -> Bool{
        var favMovie : [FavouriteMovies] = []
        
        let fetchRequest : NSFetchRequest<FavouriteMovies> = FavouriteMovies.fetchRequest()
        
        let myPredicate = NSPredicate(format: "id = %d", movie.id)
        
        fetchRequest.predicate = myPredicate
        
        do {
             favMovie = try context.fetch(fetchRequest)
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        if !favMovie.isEmpty{
            print(favMovie.count)
            return true
        }else{
            print(favMovie.count)
            return false
        }
    }
    
}

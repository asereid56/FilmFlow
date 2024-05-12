//
//  FavoritePresenter.swift
//  FilmFlow
//
//  Created by Aser Eid on 11/05/2024.
//

import Foundation
import CoreData
class FavoritePresenter{
    
    var db : LocalDataSource
    var view : FavoriteProtocol
    var favMovies : [NSManagedObject] = []
    
    init(db: LocalDataSource , view : FavoriteProtocol) {
        self.view = view
        self.db = db
    }
    
    func loadAllFavMovies(){
        favMovies = db.fetchFavMovies()
        view.showAllFavMovies()
    }
    
    func deleteMovie(movie : NSManagedObject){
        db.deleteMovie(movie: movie)
        favMovies = db.fetchFavMovies()
    }
    
    func getFavMoviesResult() -> [NSManagedObject] {
        return favMovies 
    }
}

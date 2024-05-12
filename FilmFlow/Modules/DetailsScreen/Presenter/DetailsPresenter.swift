//
//  DetailsPresenter.swift
//  FilmFlow
//
//  Created by Aser Eid on 09/05/2024.
//

import Foundation

class DetailsPresenter {
    var view : DetailsScreen
    var selectedMovie : Movie?
    var db : LocalDataSource
    
    init(view: DetailsScreen , db : LocalDataSource) {
        self.view = view
        self.db = db
    }
    func showDetailsOfOnlineMovie(movie: Movie) {
        self.selectedMovie = movie
      }
    
    func checkMovieInFavToFillHeartIcon(movie : Movie) {
        let isFav =  db.isMovieInFavourite(movie: movie)
        print("it doesnt exist in fav and value equal from presenter \(isFav)")
        if isFav{
            view.showFillHeart()
        }
    }
    
    func isMovieInFav(movie : Movie) -> Bool {
        return db.isMovieInFavourite(movie: movie)
    }
    
    func insertMovieToFav(movie : Movie){
        db.insertMovieToFav(movie: movie)
        
    }
}

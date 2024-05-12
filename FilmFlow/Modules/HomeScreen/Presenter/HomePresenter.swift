//
//  HomePresenter.swift
//  FilmFlow
//
//  Created by Aser Eid on 09/05/2024.
//

import Foundation
import CoreData

class HomePresenter {
    var network : NetworkProtocol?
    var db : LocalDataSource?
    var view : HomeScreen
    
    var movie : Movie?
    var MoviesList : [Movie]?
    
    var upcomingMovie : UpcomingFilm?
    var upcomingMoviesList : [UpcomingFilm]?
    
    var savedMovies : [NSManagedObject] = []
    var upcomingSavedMovies : [NSManagedObject] = []
    
    var detailsPresenter: DetailsPresenter?
    
    init(network: NetworkProtocol, db : LocalDataSource, view: HomeScreen) {
        self.network = network
        self.view = view
        self.db = db
    }
    
    func loadAllMovies(url : URL){
        network?.fetchData(from: url, responseType: MovieResponse.self){[weak self] result in
            switch result {
                
            case .success(let moviesResponse):
                DispatchQueue.main.sync {
                    self?.MoviesList = moviesResponse.results
                    self?.view.displayMoviesToCollectionViewAndSavedIt()
                    
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failed to fetch movies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadUpcomingMovies(url : URL){
        network?.fetchData(from: url, responseType: UpcomingFilmResponse.self){ [weak self] result in
            switch result {
            case .success(let upcomingMovies) :
                DispatchQueue.main.async{
                    self?.upcomingMoviesList = upcomingMovies.results
                    self?.view.displayUpcomingMoviesToCollectionViewAndSavedIt()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failed to fetch upcoming movies: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func insertMovieToDataBase(movie : Movie){
        db?.insertMovie(forEntity: "Movies", movie: movie)
    }
    
    func insertUpcomingMovieToDataBase(movie : UpcomingFilm){
        db?.insertUpcomingMovie(forEntity: "UpcomingMovies", movie: movie)
    }
    
    func fetchAllSavedMovies (){
        savedMovies = db?.fetchSavedMovies() ?? []
        view.displaySavedMoviesToCollectionView()
    }
    
    func fetchAllSavedUpcomingMovies (){
        upcomingSavedMovies =  db?.fetchSavedUpcomingMovies() ?? []
        view.displaySavedUpcomingMoviesToCollectionView()
       
    }
    func deleteAllMoviesInDataBase (forEntity name : String){
        db?.deleteAllData(forEntity: name)
    }
    
    func deleteAllUpcomingMoviesInDataBase (forEntity name : String){
        db?.deleteAllData(forEntity: name)
    }
    
    func getAllMoviesResult() -> [Movie] {
        return MoviesList ?? []
    }
    
    func getUpcomingMoviesResult() -> [UpcomingFilm]{
        return upcomingMoviesList ?? []
    }
    
    func getAllSavedMoviesResult() -> [NSManagedObject] {
        return savedMovies
    }
    
    func getSavedUpcomingMoviesResult() -> [NSManagedObject]{
        return upcomingSavedMovies
    }
    
    func passSelectedMovieToDetails(movie: Movie , detailsPresenter : DetailsPresenter) {
        detailsPresenter.showDetailsOfOnlineMovie(movie: movie )
    }
}

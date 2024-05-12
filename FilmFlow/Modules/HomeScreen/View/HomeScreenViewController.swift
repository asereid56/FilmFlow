//
//  MyTableViewController.swift
//  TableView
//
//  Created by JETSMobileLabMini12 on 22/04/2024.
//

import UIKit
import SDWebImage
import CoreData
import Reachability

protocol HomeScreen {
    func displayMoviesToCollectionViewAndSavedIt()
    func displayUpcomingMoviesToCollectionViewAndSavedIt()
    func displaySavedMoviesToCollectionView()
    func displaySavedUpcomingMoviesToCollectionView()
}

class HomeScreenViewController: UIViewController,UICollectionViewDelegateFlowLayout, HomeScreen{
    var presenter : HomePresenter?
    @IBOutlet weak var allMoviesCollectionView: UICollectionView!
    @IBOutlet weak var upcomingMoviesCollectionView: UICollectionView!
    
    var onlineMovies : [Movie] = []
    var upcomingMovies : [UpcomingFilm] = []
    var context : NSManagedObjectContext!
    var favMovies : [NSManagedObject] = []
    var savedMovies : [NSManagedObject] = []
    var upcomingSavedMovies : [NSManagedObject] = []
    var isAlertOfConnection = false
    let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=abe7089daa19c4b98bff89bb7fe1acac")
    let upcomingUrl = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=8680f0dbca8aaf3e3c6846d1068c12ca")
    let firstHalfPath = "https://image.tmdb.org/t/p/w500"
    var reachability : Reachability!
    func isInternetAvailable() -> Bool {
        return reachability.connection != .unavailable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = HomePresenter(network: NetworkService(), db: LocalDataSource.shared, view: self)
        
        reachability = try! Reachability()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        try! reachability.startNotifier()
        
        if isInternetAvailable() {
            
            presenter?.loadAllMovies(url: url!)
            presenter?.loadUpcomingMovies(url: upcomingUrl!)
            presenter?.deleteAllMoviesInDataBase(forEntity: "Movies")
            presenter?.deleteAllMoviesInDataBase(forEntity: "UpcomingMovies")
            if isAlertOfConnection {
                showAlert(message: "Your internet connection was restored")
            }
            
        }else{
            
            presenter?.fetchAllSavedMovies()
            presenter?.fetchAllSavedUpcomingMovies()
            
            if !isAlertOfConnection{
                showAlert(message: "You are currently offline")
            }
        }
    }
    
    func displayMoviesToCollectionViewAndSavedIt(){
        onlineMovies = presenter?.getAllMoviesResult() ?? []
        for movie in onlineMovies {
            presenter?.insertMovieToDataBase(movie: movie)
        }
        allMoviesCollectionView.reloadData()
    }
    func displayUpcomingMoviesToCollectionViewAndSavedIt(){
        upcomingMovies = presenter?.getUpcomingMoviesResult() ?? []
        for movie in upcomingMovies {
            presenter?.insertUpcomingMovieToDataBase(movie: movie)
        }
        upcomingMoviesCollectionView.reloadData()
    }
    
    func displaySavedMoviesToCollectionView(){
        savedMovies = presenter?.getAllSavedMoviesResult() ?? []
        allMoviesCollectionView.reloadData()
    }
    
    func displaySavedUpcomingMoviesToCollectionView(){
        upcomingSavedMovies = presenter?.getSavedUpcomingMoviesResult() ?? []
        upcomingMoviesCollectionView.reloadData()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.isAlertOfConnection = !self.isAlertOfConnection
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == allMoviesCollectionView{
            let width = (collectionView.frame.width - 25) / 3
            let height = width * 1.4
            return CGSize(width: width, height: height)}
        else  {
            let width = (collectionView.frame.width - 10) / 3
            let height = collectionView.frame.height - 2
            return CGSize(width: width, height: height)
        }
    }
    
}

extension HomeScreenViewController : UICollectionViewDataSource , UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == allMoviesCollectionView{
            if isInternetAvailable(){
                return onlineMovies.count
            }else{
                return savedMovies.count
            }
            
        }else if collectionView == upcomingMoviesCollectionView{
            if isInternetAvailable(){
                return upcomingMovies.count
            }else{
                return upcomingSavedMovies.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 7, bottom: 1, right: 7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == allMoviesCollectionView{
            
            let cell = allMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            
            if isInternetAvailable(){
                configureCellForOnlineMovie(cell, indexPath: indexPath, movies: onlineMovies)
                return cell
            }else{
                configureCellForOnlineMovie(cell, indexPath: indexPath, movies: savedMovies)
                return cell
            }
            
        }else if collectionView == upcomingMoviesCollectionView {
            
            let cell = upcomingMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: "topRatedCell", for: indexPath)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            
            if isInternetAvailable(){
                configureCellForOnlineMovie(cell, indexPath: indexPath, movies: upcomingMovies)
                return cell
            }else{
                configureCellForOnlineMovie(cell, indexPath: indexPath, movies: upcomingSavedMovies)
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedMovie: Movie?
        let detailsScreen = self.storyboard?.instantiateViewController(identifier: "details") as! DetailsViewController
        let detailsPresenter = detailsScreen.initializeDetailsPresenter()
        
        if collectionView == allMoviesCollectionView {
            if isInternetAvailable(){
                
                selectedMovie = onlineMovies[indexPath.row]
                presenter?.passSelectedMovieToDetails(movie: selectedMovie!, detailsPresenter: detailsPresenter)
            }else{
                
                let managedMovie = savedMovies[indexPath.row]
                selectedMovie = changeManagedObjectToMovie(from: managedMovie)
                
                presenter?.passSelectedMovieToDetails(movie: selectedMovie!, detailsPresenter: detailsPresenter)
            }
            
        } else if collectionView == upcomingMoviesCollectionView {
            if isInternetAvailable(){
                
                let  upcomingMovie = upcomingMovies[indexPath.row]
                selectedMovie = changeUpcomingObjectToMovie(from: upcomingMovie)
                
                presenter?.passSelectedMovieToDetails(movie: selectedMovie!, detailsPresenter: detailsPresenter)
            }else{
                
                let managedMovie = upcomingSavedMovies[indexPath.row]
                selectedMovie = changeManagedObjectToMovie(from: managedMovie)
                
                presenter?.passSelectedMovieToDetails(movie: selectedMovie!, detailsPresenter: detailsPresenter)
            }
            

        }
        
        self.navigationController?.pushViewController(detailsScreen, animated: true)
        
    }
    
    func changeManagedObjectToMovie(from managedMovie : NSManagedObject) -> Movie{
        
      let movie = Movie(id: managedMovie.value(forKey: "id") as! Int, originalTitle: managedMovie.value(forKey: "title") as! String, overview: managedMovie.value(forKey: "desc") as! String, posterPath: managedMovie.value(forKey: "imageUrl") as! String, releaseDate: managedMovie.value(forKey: "releaseYear") as! String, voteAverage: managedMovie.value(forKey: "rating") as! Double)
        
        return movie
    }
    
    func changeUpcomingObjectToMovie(from upcomingMovie : UpcomingFilm) -> Movie{
        
      let movie = Movie(id: upcomingMovie.id, originalTitle: upcomingMovie.originalTitle, overview: upcomingMovie.overview, posterPath: upcomingMovie.posterPath, releaseDate: upcomingMovie.releaseDate, voteAverage: upcomingMovie.voteAverage)
        
        return movie
    }
    
    func configureCellForOnlineMovie(_ cell: UICollectionViewCell, indexPath: IndexPath, movies: [Any]) {
        let movie = movies[indexPath.row]
        
        if let movie = movie as? Movie {
            
            let filmImage: UIImageView = cell.contentView.viewWithTag(2) as! UIImageView
            
            let imageData = firstHalfPath + movie.posterPath
            
            filmImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))

        } else if let upcomingMovie = movie as? UpcomingFilm {
            
            let filmImage: UIImageView = cell.contentView.viewWithTag(2) as! UIImageView
            
            let imageData = firstHalfPath + upcomingMovie.posterPath
            filmImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))
        } else if let savedMovie = movie as?  NSManagedObject{
            
            let filmImage: UIImageView = cell.contentView.viewWithTag(2) as! UIImageView
            
            let str2 = (movie as AnyObject).value(forKey: "imageUrl") as! String
            
            let imageData = firstHalfPath + str2
            filmImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))
        }
    }
    
}

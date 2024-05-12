//
//  FavouriteViewController.swift
//  Moives
//
//  Created by Aser Eid on 30/04/2024.
//

import UIKit
import CoreData

protocol FavoriteProtocol {
    func showAllFavMovies()
}

class FavouriteViewController: UIViewController , UICollectionViewDelegateFlowLayout , FavoriteProtocol {
    
    func showAllFavMovies() {
        myFavouriteCollection.reloadData()
    }
    

    @IBOutlet weak var myFavouriteCollection: UICollectionView!
    @IBOutlet weak var myImageBackground: UIImageView!

    var presenter : FavoritePresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FavoritePresenter(db: LocalDataSource.shared, view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.loadAllFavMovies()
    }
    
    @IBAction func deleteBtn(_ sender: UIButton) {
        
        guard let cell = sender.superview?.superview as? UICollectionViewCell,
              let indexPath = myFavouriteCollection.indexPath(for: cell) else {
            return
        }
        
        let deletedMovie = presenter?.getFavMoviesResult()[indexPath.row]
     
       var alert =  UIAlertController(title: "Alert", message: "Do you want to delete this movie?", preferredStyle: .actionSheet)
        var ok : UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in 
            self.presenter?.deleteMovie(movie: deletedMovie!)
            self.myFavouriteCollection.deleteItems(at: [indexPath])
        })
       
        var cancel : UIAlertAction = UIAlertAction(title: "Cancel", style:.cancel)
        
        alert.addAction(ok)
       
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        let height = width * 1.4
        return CGSize(width: width, height: height)
    }



}

extension FavouriteViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = presenter?.getFavMoviesResult().count ?? 0
        myImageBackground.isHidden = count > 0
        print("count is \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myFavouriteCollection.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        
        let savedMovie = presenter?.getFavMoviesResult()[indexPath.row]
        
        let filmTitle : UILabel = cell.contentView.viewWithTag(1) as! UILabel
        filmTitle.text = savedMovie?.value(forKey: "title") as? String ?? ""
        
        let filmImage : UIImageView = cell.contentView.viewWithTag(2) as! UIImageView
        
        
        let str1 = "https://image.tmdb.org/t/p/w500"
        let str2 : String = savedMovie?.value(forKey: "imageUrl") as? String ?? ""
        let imageData = str1 + str2
        filmImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2.5, bottom: 1, right: 2.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let managedMovie : NSManagedObject = presenter!.getFavMoviesResult()[indexPath.row]
        var selectedMovie = Movie(id: managedMovie.value(forKey: "id") as! Int, originalTitle: managedMovie.value(forKey: "title") as! String, overview: managedMovie.value(forKey: "desc") as! String, posterPath: managedMovie.value(forKey: "imageUrl") as! String, releaseDate: managedMovie.value(forKey: "releaseYear") as! String, voteAverage: managedMovie.value(forKey: "rating") as! Double)
        
        let detailsScreen : DetailsViewController = self.storyboard?.instantiateViewController(identifier: "details") as! DetailsViewController
      //  detailsScreen.selected = selectedMovie
        self.navigationController?.pushViewController(detailsScreen, animated: true)
    }
    
}

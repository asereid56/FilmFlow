//
//  ViewController.swift
//  Moives
//
//  Created by JETSMobileLabMini12 on 22/04/2024.
//

import UIKit
import Cosmos
import CoreData
protocol DetailsScreen {
    func showFillHeart()
}
class DetailsViewController: UIViewController, DetailsScreen {
    func showFillHeart() {
        let heartFillImage = UIImage(systemName: "heart.fill")
        btnFavv.setImage(heartFillImage, for: .normal)
    }
    
    var presenter : DetailsPresenter?
    
    @IBOutlet weak var btnFavv: UIButton!
    @IBOutlet weak var filmImage: UIImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var bluredImage: UIImageView!
    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var viewRating: UIView!
    @IBOutlet weak var publishedYear: UILabel!
    @IBOutlet weak var genreFilm: UITextView!
    
    var favMovies : [NSManagedObject] = []
    var context : NSManagedObjectContext!
    lazy var viewCosmos = {
        var view = CosmosView()
        view.settings.updateOnTouch = false
        view.settings.totalStars = 5
        return view
    }()
    
    func initializeDetailsPresenter() -> DetailsPresenter{
        presenter = DetailsPresenter(view: self, db: LocalDataSource.shared)
        return presenter!
    }
    
    func updateDetailsView() {
        if let selectedMovie = presenter?.selectedMovie {
            
            let str1 = "https://image.tmdb.org/t/p/w500"
            let imageData = str1 + selectedMovie.posterPath
            
            let blurEffect = UIBlurEffect(style: .systemMaterialDark)
            blur.effect = blurEffect
            
            bluredImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))
            filmImage.sd_setImage(with: URL(string: imageData), placeholderImage: UIImage(named: "placeholder.png"))
            
            
            if selectedMovie.title.isEmpty{
                filmTitle.text = selectedMovie.originalTitle
            }else{
                filmTitle.text = selectedMovie.title
            }
            
            viewRating.addSubview(viewCosmos)
            viewCosmos.rating = selectedMovie.voteAverage / 2
            viewCosmos.center = CGPointMake(viewRating.frame.width/2, viewRating.frame.height/2)
            
            publishedYear.text = selectedMovie.releaseDate
            genreFilm.text = selectedMovie.overview
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.black

        updateDetailsView()
        
    }
    
    @IBAction func btnFav(_ sender: Any) {
            
            let alert = UIAlertController(title: "Alert", message: "Do you want to add it to favorite?", preferredStyle: .actionSheet)
            
            let ok = UIAlertAction(title: "OK", style: .default) { [self] _ in
                let selected = presenter?.selectedMovie
                if (presenter?.isMovieInFav(movie: selected!)) == false {
                    presenter?.insertMovieToFav(movie: selected!)
                    presenter?.checkMovieInFavToFillHeartIcon(movie: selected!)
                } else {
                    let alert = UIAlertController(title: "Alert", message: "You have already added", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        presenter?.checkMovieInFavToFillHeartIcon(movie: (presenter?.selectedMovie)!)
        
        switch traitCollection.userInterfaceStyle {
            
        case .light:
            navigationController?.navigationBar.tintColor = UIColor.black
            bluredImage.layer.borderColor = UIColor.black.cgColor
            
        case .dark:
            navigationController?.navigationBar.tintColor = UIColor.white
            bluredImage.layer.borderColor = UIColor.white.cgColor
            
        default:
            navigationController?.navigationBar.tintColor = UIColor.black
        }
    }
    
}



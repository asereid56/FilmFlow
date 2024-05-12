//
//  MyTableViewController.swift
//  TableView
//
//  Created by JETSMobileLabMini12 on 22/04/2024.
//

import UIKit

class MyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddProtocol{
   
    @IBOutlet weak var myImageBackground: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    var listOfMovies : NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.createTable()
        listOfMovies = NSMutableArray()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        listOfMovies = (DatabaseManager.shared.getMovies() as! NSMutableArray)
        if listOfMovies.count == 0 {
            myImageBackground.isHidden = false
        }
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addViewController = segue.destination as! AddingFilmViewController
        addViewController.addingProtocol = self
    }
    
    func add(movie : Movie) {
        //listOfMovies.add(movie)
        DatabaseManager.shared.insertMovie(movie: movie)
        myTableView.reloadData()
    }


}

extension MyTableViewController{
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if listOfMovies.count == 0 {
             myImageBackground.isHidden = false
         }else{
             myImageBackground.isHidden = true
         }
        return listOfMovies.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let movie: Movie = listOfMovies[indexPath.row] as! Movie
        
        let filmTitle : UILabel = cell.contentView.viewWithTag(1) as! UILabel
        filmTitle.text = movie.title
        
        let filmImage : UIImageView = cell.contentView.viewWithTag(2) as! UIImageView
        let imageData = movie.imageData
        filmImage.image = UIImage(data: imageData!)
       
        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie : Movie = listOfMovies[indexPath.row] as! Movie
        let detailsScreen : ViewController = self.storyboard?.instantiateViewController(identifier: "details") as! ViewController
        detailsScreen.selected = selectedMovie
        self.navigationController?.pushViewController(detailsScreen, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieToDelete = listOfMovies[indexPath.row] as! Movie
            DatabaseManager.shared.deleteMovie(movie: movieToDelete)
            listOfMovies.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

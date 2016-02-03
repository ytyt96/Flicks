//
//  MovieInfoViewController.swift
//  MovieViewer
//
//  Created by Yuting Zhang on 1/27/16.
//  Copyright © 2016 Yuting Zhang. All rights reserved.
//

import UIKit

class MovieInfoViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieSummary: UILabel!
    @IBOutlet weak var movieScrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var selectedMovie: NSDictionary?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieScrollView.contentSize = CGSize(width: movieScrollView.frame.size.width, height: infoView.frame.size.height + infoView.frame.origin.y)
        
        
        if let posterPath = selectedMovie!["poster_path"] as? String{
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let imageUrl = NSURL(string: baseUrl + posterPath){
                movieImageView.setImageWithURL(imageUrl)
            }
        }

        if let title = selectedMovie!["title"] as? String{
            movieTitle.text = title
        }
        else{
            movieTitle.text = "No Title Available"
        }
        
        if let overview = selectedMovie!["overview"] as? String{
            movieSummary.text = overview
            movieSummary.sizeToFit()
        }
        else{
            movieSummary.text = "There is no overview for this movie now. Please check back later."
        }
        
        if let releaseDate = selectedMovie!["release_date"] as? String{
            movieReleaseDate.text = releaseDate

        }
        
        movieSummary.font = UIFont.systemFontOfSize(16)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

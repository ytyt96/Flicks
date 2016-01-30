//
//  MoivesViewController.swift
//  MoiveViewer
//
//  Created by Yuting Zhang on 1/18/16.
//  Copyright © 2016 Yuting Zhang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoivesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var movieSearchBar: UISearchBar!
    

    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var movies: [NSDictionary]?
    var filteredMovies : [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up dataSource and delegate
        movieCollectionView.dataSource = self
        movieCollectionView.delegate = self
        movieSearchBar.delegate = self
        
        // Create refreshControl for the tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        movieCollectionView.insertSubview(refreshControl, atIndex: 0)
        
        // Make initial data loading
        loadDataFromNetwork()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        loadDataFromNetwork()
        refreshControl.endRefreshing()
    }
    
    func loadDataFromNetwork(){
        
        // Initiate ProgressHUB
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Load movie data from network
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        // Cache will be used only after validation
        let request = NSURLRequest(URL: url!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 3)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.movieCollectionView.reloadData()
                    }
                }
                else{
                    // Setting up the Alert for no Internet connection
                    let networkAlert = UIAlertController(title: "Error", message: "Unable to reach server. Check your Internet connection", preferredStyle: .Alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .Default){ (action) in
                        self.loadDataFromNetwork()
                        return
                    }
                    let settingsAction = UIAlertAction(title: "Settings", style: .Default){ (action) in
                        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                        UIApplication.sharedApplication().openURL(settingsUrl!)
                    }
                    networkAlert.addAction(retryAction)
                    networkAlert.addAction(settingsAction)
                    // Failed to retrieve information from server. Set the alert!
                    self.presentViewController(networkAlert, animated: true, completion: nil)
                }
                
                
                // Hide ProgressHUD after data has been fetched
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        });
        task.resume()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        // If data has been fetched successfully from the Internet
        if let movies = filteredMovies {
            return movies.count
        }
            // Else show an empty table
        else{
            return 0
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        // Reuse any avaiable cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // Update cell with movie information
        let movie = filteredMovies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String{
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let imageUrl = NSURL(string: baseUrl + posterPath){
                let imageRequest = NSURLRequest(URL: imageUrl)
                
                // Let's do some animation
                cell.movieImageView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: {(imagerequest, imageResponse, image) -> Void in
                    if imageResponse != nil{
                        cell.movieImageView.alpha = 0.0
                        cell.movieImageView.image = image
                        UIView.animateWithDuration(0.3, animations: {() -> Void in
                            cell.movieImageView.alpha = 1.0
                        })
                    } else{
                        cell.movieImageView.image = image
                    }},
                    failure: nil
                )
            }
        }
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty {
            // Nothing in the text field, so no filtering will be done
            filteredMovies = movies
        } else {
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if let title = dataItem["title"] as? String{
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil{
                        return true
                    }
                }
                return false
            })
        }
        movieCollectionView.reloadData()
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        movieCollectionView.indexPathsForSelectedItems()
        if segue.identifier == "MovieCellPushed"{
            if let destination = segue.destinationViewController as? MovieInfoViewController{
                let movie = filteredMovies![(movieCollectionView.indexPathsForSelectedItems()?.first?.row)!]

                destination.selectedMovie = movie
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        movieSearchBar.endEditing(true)
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

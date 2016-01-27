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

class MoivesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Create refreshControl for the tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
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
        
        // Setting up the Alert for no Internet connection
        let networkAlert = UIAlertController(title: "Error", message: "Unable to reach server. Check your Internet connection", preferredStyle: .Alert)
        let retryAction = UIAlertAction(title: "Retry", style: .Default){ (action) in
            self.loadDataFromNetwork()
            return
        }
        networkAlert.addAction(retryAction)
        
        // Initiate ProgressHUB
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Load movie data from network
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        // Cache will be used only after validation
        let request = NSURLRequest(URL: url!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 10)
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
                            self.tableView.reloadData()
                    }
                }
                else{
                    // Failed to retrieve information from server. Set the alert!
                    self.presentViewController(networkAlert, animated: true, completion: nil)
                }
                
                
                // Hide ProgressHUD after data has been fetched
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // If data has been fetched successfully from the Internet
        if let movies = movies {
            return movies.count
        }
        // Else show an empty table
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        // Reuse any avaiable cell
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // Update cell with movie information
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)

        return cell
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

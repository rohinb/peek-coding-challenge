//
//  SearchViewController.swift
//  PeekInternDemo
//
//  Created by Rohin Bhushan on 3/12/16.
//  Copyright © 2016 rohinbhushan. All rights reserved.
//
import TwitterKit
import UIKit
import Fabric


class SearchViewController: UITableViewController {
    
    var tweetList = [Tweet]()
    var expectedTweets = 6
    let tweetsPerPage = 6
    var maxID = "none"
    var profilePictures = Dictionary<String, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        self.tableView.backgroundColor = UIColor.lightGrayColor()
        // pulling up calls refresh method
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh(nil)
    }
    
    func loadMoreTweets() {
        // fetch more tweets and reload table view
        fetchData()
        tableView.reloadData()
    }
    
    func refresh(sender: AnyObject?) {
        // empty current tweets and load new ones
        tweetList = []
        expectedTweets = 6
        maxID = "none"
        fetchData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func fetchData() {
        // fetch last session logged in
        let session = Twitter.sharedInstance().session()
        if let s = session {
            let userID = s.userID
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
            // if loading more tweets, only load ones older than the oldest one currently loaded
            var params = ["count": String(tweetsPerPage), "q": "@peek"]
            if maxID != "none" {
                params["max_id"] = self.maxID
            }
            
            var clientError : NSError?
            let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    do {
                        // use json from query to add to tweetList
                        let json : AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        let statusList = json!["statuses"]!! as! NSArray
                        for status in statusList{
                            self.tweetList.append(Tweet(status: status as! NSDictionary))
                        }
                        //update maxID to id of oldest tweet currently fetched minus 1
                        self.maxID = statusList[statusList.count - 1]["id_str"] as! String
                        self.maxID = String(Int(self.maxID)! - 1)
                        self.downloadProfilePictures()
                    } catch {
                        print("error deserializing JSON: \(error)")
                    }
                }
                else {
                    print("Error: \(connectionError)")
                }
            }
        }
    }
    
    func downloadProfilePictures() {
        // start downloading the images but in a fashion that does not interfere with user
        for tweet in self.tweetList {
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: tweet.avatar)!) {(data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    //when image has downloaded, assign image to tweet's id in Dictionary
                    let image = UIImage(data: data!)
                    self.profilePictures[tweet.id] = image
                    self.tableView.reloadData()
                })
            }
            task.resume()
        }
    }
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return tweetList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TweetCell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        let tweet = tweetList[indexPath.row]
        // set the cell's label's text to the tweet itself
        cell.tweetLabel.text = "User: \(tweet.user) \n \(tweet.text.stringByReplacingOccurrencesOfString("&amp;", withString: "&"))"
        // make the cell's color alternate every row
        cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(red: 255, green: 255, blue: 255, alpha:0) : UIColor.whiteColor();
        // set the cell's image to the tweet's picture if it has loaded yet
        if let image = profilePictures[tweet.id] {
            cell.profileImageView.image = image
        }
        // load more tweets if user has scrolled to last cell currently in view
        if (indexPath.row == expectedTweets - 1) {
            loadMoreTweets()
            expectedTweets += tweetsPerPage
        }
        // set the button's click handler to retweet function
        cell.retweetButton.addTarget(self, action: "retweet:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.retweetButton.tag = indexPath.row
        
        return cell
    }
    
    func retweet(sender: AnyObject?) {
        let index = sender!.tag
        let tweetID = tweetList[index].id // desired tweet to retweet
        let tweetOwner = tweetList[index].user
        let session = Twitter.sharedInstance().session()
        if let s = session {
            //retweet desired tweet from user's account
            let userID = s.userID
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/retweet/\(tweetID).json"
            let params = ["id": tweetID]
            var clientError : NSError?
            let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    // let user know that they have successfully retweeted the tweet
                    let refreshAlert = UIAlertController(title: "Success", message: "Tweet from \(tweetOwner) successfully retweeted", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action: UIAlertAction!) in
                    }))
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                }
                else {
                    print("Error: \(connectionError)")
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // swipe to delete functions
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // remove tweet from tweetList and update table view
            tweetList.removeAtIndex(indexPath.row)
            expectedTweets -= 1
            tableView.reloadData()
        }
    }
}

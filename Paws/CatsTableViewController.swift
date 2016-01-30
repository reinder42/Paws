//
//  CatsTableViewController.swift
//  Paws
//
//  Created by Reinder de Vries on 18-03-15.
//  Copyright (c) 2015 LearnAppMaking. All rights reserved.
//

import UIKit

class CatsTableViewController: PFQueryTableViewController
{
    let cellIdentifier:String = "CatCell";
    
    override init(style: UITableViewStyle, className: String!)
    {
        super.init(style: style, className: className);
        
        self.pullToRefreshEnabled = true;
        self.paginationEnabled = false;
        self.objectsPerPage = 25;
        
        self.parseClassName = className;
        self.tableView.rowHeight = 350;
        self.tableView.allowsSelection = false;
    }
    
    required init(coder aDecoder:NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad()
    {
        tableView.registerNib(UINib(nibName: "CatsTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier);
        
        super.viewDidLoad();
    }
    
    override func queryForTable() -> PFQuery
    {
        let query:PFQuery = PFQuery(className:self.parseClassName!);
        
        if(objects!.count == 0)
        {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork;
        }
        
        query.orderByAscending("name");
        
        return query;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell?
    {
        // Dequeue or create table view cell
        var cell:CatsTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? CatsTableViewCell;
        
        if(cell == nil)
        {
            cell = NSBundle.mainBundle().loadNibNamed("CatsTableViewCell", owner: self, options: nil)[0] as? CatsTableViewCell;
        }
        
        // Set parseObject on cell
        cell!.parseObject = object;
        
        // Attempt to set name label
        if let name = object?["name"] as? String
        {
            cell!.catNameLabel?.text = name;
        }
        
        // Attempt to set vote label
        if let votes = object?["votes"] as? Int
        {
            cell!.catVotesLabel?.text = "\(votes) votes";
        } else {
            cell!.catVotesLabel?.text = "0 votes";
        }
        
        // Attempt to set credit label
        if let credit = object?["cc_by"] as? String
        {
            cell!.catCreditLabel?.text = "\(credit) / CC 2.0";
        }
        
        if let urlString = object?["url"] as? String
        {
            cell!.catImageView?.image = nil; // Bug: flickering
            
            if let url = NSURL(string: urlString)
            {
                let request:NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 5.0);
                
                NSOperationQueue.mainQueue().cancelAllOperations();
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                    (response:NSURLResponse?, imageData:NSData?, error:NSError?) -> Void in
                    
                    if let data = imageData
                    {
                        cell!.catImageView!.image = UIImage(data: data);
                    }
                });
            }
        }
        
        return cell;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

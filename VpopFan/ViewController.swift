//
//  ViewController.swift
//  VpopFan
//
//  Created by Khoa Vu on 1/20/16.
//  Copyright © 2016 VuDo Solutions. All rights reserved.
//

import UIKit
import SVProgressHUD
import MWFeedParser
import AFNetworking
import KINWebBrowser

class ViewController: UIViewController, MWFeedParserDelegate {
    @IBOutlet var collectionView: UICollectionView!
    
    var items = [MWFeedItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        request()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func setupNavigationBar() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 30))
        label.font = UIFont.systemFontOfSize(21)
        label.textColor = UIColor.darkGrayColor()
        label.textAlignment = .Center
        label.text = "Latest Vpop News"
        
        navigationItem.titleView = label
    }
    
    func request() {
        let URL = NSURL(string: "http://vpopfan.com/rss")
        let feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
    }
    
    func feedParserDidStart(parser: MWFeedParser) {
        SVProgressHUD.show()
        self.items = [MWFeedItem]()
    }
    
    func feedParserDidFinish(parser: MWFeedParser) {
        SVProgressHUD.dismiss()
        //self.tableView.reloadData()
        self.collectionView?.reloadData()
    }
    
    
    func feedParser(parser: MWFeedParser, didParseFeedInfo info: MWFeedInfo) {
        //print(info)
        self.title = info.title
    }
    
    func feedParser(parser: MWFeedParser, didParseFeedItem item: MWFeedItem) {
        //print(item)
        self.items.append(item)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = "cellIdentifier"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
        
        let item:MWFeedItem = items[indexPath.row]
        let htmlContent:String = item.content
            
        // find match for image
        let imgTag = matchesForRegexInText("(<img.*?src=\")(.*?)(\".*?>)", text: htmlContent)
        //print(imgTag)
        let imgSrc = matchesForRegexInText("http.*(png|jpg)", text: imgTag)
        //print(imgSrc)
        
        let imgURL: NSURL? = NSURL(string: imgSrc)
        //cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.imageView?.setImageWithURL(imgURL!)
        
        cell.imageLabel.text = item.title
        
        return cell
    }

    func matchesForRegexInText(regex: String!, text: String!) -> String {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.firstMatchInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return nsString.substringWithRange(results!.range)
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return "Error"
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as MWFeedItem
        let con = KINWebBrowserViewController()
        let URL = NSURL(string: item.link)
        con.loadURL(URL)
        self.navigationController?.pushViewController(con, animated: true)
    }
}
//: Playground - noun: a place where people can play

import UIKit

func getJSON(urlToRequest: String) -> NSData{
    return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
}

func parseJSON(inputData: NSData) -> NSDictionary? {
    let boardsDictionary: NSDictionary
    do {
        try boardsDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
    } catch {
        return nil
    }
    return boardsDictionary
}

let response = parseJSON(getJSON("http://reddit.com/r/awww/hot.json"))!
let items = response.objectForKey("data")?.objectForKey("children") as! [[String : AnyObject]]
print(items[0]["data"]!["url"])

for item in items {
    print(item["data"]!["url"]!!)
}


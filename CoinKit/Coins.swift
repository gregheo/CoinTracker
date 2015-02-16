/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

public class Coin: NSObject, NSCoding, Printable {
  public let name: String

  public let price: Double
  public let price24h: Double
  public let volume: Double

  override public var description: String {
    return "\(name) \(price)"
  }

  init(name: String, price: Double, price24h: Double, volume: Double) {
    self.name = name
    self.price = price
    self.price24h = price24h
    self.volume = volume
  }

  public required init(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObjectForKey("name") as String
    self.price = aDecoder.decodeDoubleForKey("price")
    self.price24h = aDecoder.decodeDoubleForKey("price24h")
    self.volume = aDecoder.decodeDoubleForKey("volume")

    super.init()
  }

  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeDouble(price, forKey: "price")
    aCoder.encodeDouble(price24h, forKey: "price24h")
    aCoder.encodeDouble(volume, forKey: "volume")
  }
}

public typealias PriceRequestCompletionBlock = (coins: [Coin]?, error: NSError?) -> ()

private let URL = "http://api.cryptocoincharts.info/tradingPairs"
private let wantedCurrencies = ["DOGE", "BTC", "LTC", "DRK"]

public class CoinHelper {
  let session: NSURLSession
  let defaults = NSUserDefaults.standardUserDefaults()

  public class var dateFormatter: NSDateFormatter {
    struct DateFormatter {
      static var token: dispatch_once_t = 0
      static var instance: NSDateFormatter? = nil
    }
    dispatch_once(&DateFormatter.token) {
      let formatter = NSDateFormatter()
      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      DateFormatter.instance = formatter;
    }
    return DateFormatter.instance!
  }

  public class var priceFormatter: NSNumberFormatter {
    struct PriceFormatter {
      static var token: dispatch_once_t = 0
      static var instance: NSNumberFormatter? = nil
    }
    dispatch_once(&PriceFormatter.token) {
      let formatter = NSNumberFormatter()
      formatter.currencyCode = "USD"
      formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
      PriceFormatter.instance = formatter
    }
    return PriceFormatter.instance!
  }

  public init() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    session = NSURLSession(configuration: configuration);
  }

  public func requestPrice(completion: PriceRequestCompletionBlock) {
    let request = NSMutableURLRequest(URL: NSURL(string: URL)!)
    request.HTTPMethod = "POST"
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    var httpBody = "pairs="
    for (index, currency) in enumerate(wantedCurrencies) {
      httpBody += (index != 0 ? "," : "") + "\(currency)_USD"
    }
    request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error == nil {
        var JSONError: NSError?
        let responseArray: NSArray = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &JSONError) as NSArray
        if JSONError == nil {
          var coinData = [Coin]()

          for coinDict in responseArray {
            if let coinDict = coinDict as? NSDictionary {
              if let key = coinDict["id"] as? String {
                if (key as NSString).hasSuffix("/usd") {
                  let currency = key.stringByReplacingOccurrencesOfString("/usd", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).uppercaseString
                  coinData.append(Coin(name: currency, price: (coinDict["price"] as NSString).doubleValue, price24h: (coinDict["price_before_24h"] as NSString).doubleValue, volume: (coinDict["volume_first"] as NSString).doubleValue))
                }
              }
            }
          }

          coinData.sort({ (a, b) -> Bool in
            a.name < b.name
          })
          
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(coinData), forKey: "coinData")
            self.defaults.setObject(NSDate(), forKey: "date")
            self.defaults.synchronize()

            completion(coins: coinData, error: nil)
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(coins: nil, error: JSONError)
          })
        }
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(coins: nil, error: error)
        })
      }
    })
    task.resume()
  }

  public func cachedDate() -> NSDate {
    if let date = defaults.objectForKey("date") as? NSDate {
      return date
    }
    return NSDate()
  }

  public func cachedPrices() -> [Coin] {
    if let coinData = defaults.objectForKey("coinData") as? NSData {
      if let coins = NSKeyedUnarchiver.unarchiveObjectWithData(coinData) as? [Coin] {
        return coins
      }
    }
    return []
  }
}

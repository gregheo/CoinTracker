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

import WatchKit
import Foundation
import CoinKit

class CoinsInterfaceController: WKInterfaceController {
  var coins = [Coin]()
  let coinHelper = CoinHelper()

  @IBOutlet weak var coinTable: WKInterfaceTable!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    coins = coinHelper.cachedPrices()
    reloadTable()

    WKInterfaceController.openParentApplication(["request": "refreshData"], reply: { (replyInfo, error) -> Void in
      if let coinData = replyInfo["coinData"] as? NSData {
        if let coins = NSKeyedUnarchiver.unarchiveObjectWithData(coinData) as? [Coin] {
          self.coinHelper.cachePriceData(coins)

          self.coins = coins
          self.reloadTable()
        }
      }
    })
  }

  func reloadTable() {
    if coinTable.numberOfRows != coins.count {
      coinTable.setNumberOfRows(coins.count, withRowType: "CoinRow")
    }

    for (index, coin) in enumerate(coins) {
      if let row = coinTable.rowControllerAtIndex(index) as? CoinRow {
        row.titleLabel.setText(coin.name)
        row.detailLabel.setText("\(coin.price)")
      }
    }
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}

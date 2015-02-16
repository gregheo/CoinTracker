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

import UIKit
import CoinKit

class CoinsViewController: UITableViewController {
  var coins = [Coin]()
  let coinHelper = CoinHelper()

  override func viewDidLoad() {
    super.viewDidLoad()

    coins = coinHelper.cachedPrices()

    coinHelper.requestPrice { (coins, error) -> () in
      if let coins = coins {
        self.coins = coins
        self.tableView.reloadData()
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let dest = segue.destinationViewController as? CoinDetailViewController {
      dest.coin = coins[tableView.indexPathForSelectedRow()!.row]
    }
  }

}

extension CoinsViewController: UITableViewDataSource {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return coins.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CoinCell") as UITableViewCell
    let coin = coins[indexPath.row]

    cell.textLabel?.text = coin.name
    cell.detailTextLabel?.text = "Last price: \(coin.price) USD"

    return cell
  }

  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return "Last updated: \(CoinHelper.dateFormatter.stringFromDate(coinHelper.cachedDate()))"
    }

    return nil
  }
}

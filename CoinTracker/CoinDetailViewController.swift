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

class CoinDetailViewController: UITableViewController {
  var coin: Coin!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = coin.name
  }
}

extension CoinDetailViewController: UITableViewDataSource {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CoinDetailCell") as UITableViewCell

    if indexPath.row == 0 {
      cell.textLabel?.text = "Current Price"
      cell.detailTextLabel?.text = "\(coin.price) USD"
    } else if indexPath.row == 1 {
      cell.textLabel?.text = "Yesterday's Price"
      cell.detailTextLabel?.text = "\(coin.price24h) USD"
    } else if indexPath.row == 2 {
      cell.textLabel?.text = "24hr Trading Volume"
      cell.detailTextLabel?.text = String(format: "%.4f", coin.volume)
    }

    return cell
  }
}

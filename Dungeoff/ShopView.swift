//
//  ShopView.swift
//  Dungeoff
//
//  Created by david florczak on 21/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import Foundation
import UIKit




let coinPic = UIImage(named: "coin")

var dataDic = [0:SoldProduct(image: nil, price: 10, name: "Torch", soldOut: false, amount: 1), 1:SoldProduct(image: nil, price: 50, name: "Door", soldOut: false, amount: 1), 2:SoldProduct(image: coinPic, price: 999999, name: "A collection coin", soldOut: false, amount: .infinity)]

struct SoldProduct {
    let image: UIImage?
    let price: Int
    let name: String
    var soldOut: Bool
    var amount: Double
    
    mutating func isSoldOut() {
        if amount == 0 {
            soldOut = true
        }
        else {
            soldOut = false
        }
    }
}




class ShopView: UITableView,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var shopTable: UITableView!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .grouped)
        self.delegate = self
        self.dataSource = self
        //        self.backgroundView?.colo
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDic.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = dataDic[indexPath.row]?.name
        cell.imageView?.image = dataDic[indexPath.row]?.image
        cell.detailTextLabel?.text = "\(dataDic[indexPath.row]?.price) Golds"
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.textColor = .white
        dataDic[indexPath.row]?.isSoldOut()
        if dataDic[indexPath.row]!.soldOut {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .black
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Gold : \(coinCounter)"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        coinCounter -= dataDic[indexPath.row]!.price
        self.reloadData()
        //        ShopScene().view?.presentScene(CoinScene(size: (ShopScene().view?.frame.size)!))
        self.removeFromSuperview()
    }
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        let header: UITableViewHeaderFooterView = headerView(forSection: section)!
        header.backgroundColor = .black
        return header
    }

}

class TabCell: UITableViewCell{
    
}

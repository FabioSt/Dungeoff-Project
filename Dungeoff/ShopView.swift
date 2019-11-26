//
//  ShopView.swift
//  Dungeoff
//
//  Created by david florczak on 21/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import Foundation
import UIKit


//let coinPic = UIImage(named: "coin")
let skeletonPic = scaleDown(image: UIImage(named: "skeletons-m")!, withSize: CGSize(width: 50, height: 50))
let doorPic = scaleDown(image: UIImage(named: "door-m")!, withSize: CGSize(width: 50, height: 50))
let torchPic = scaleDown(image: UIImage(named: "torch-m")!, withSize: CGSize(width: 50, height: 50))
let chestPic = scaleDown(image: UIImage(named: "chest-m")!, withSize: CGSize(width: 50, height: 50))
let trapsPic = scaleDown(image: UIImage(named: "traps-m")!, withSize: CGSize(width: 50, height: 50))
let blobsPic = scaleDown(image: UIImage(named: "blobs-m")!, withSize: CGSize(width: 50, height: 50))
let crystalPic = scaleDown(image: UIImage(named: "crystal-m")!, withSize: CGSize(width: 50, height: 50))
let healPic = scaleDown(image: UIImage(named: "heal-m")!, withSize: CGSize(width: 50, height: 50))
var skeletonBought = false
var trapsBought = false

func scaleDown(image: UIImage, withSize: CGSize) -> UIImage {
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(withSize, false, scale)
    image.draw(in: CGRect(x: 0, y: 0, width: withSize.width, height: withSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

// EVERY TIME YOU CHANGE THIS, CHANGE ALSO IN GAME SCENE
var shopList = [[],[SoldProduct(image: crystalPic, price: 10, priceShow:"Spend 10", name: "Light Crystal", soldOut: false, amount: 1), SoldProduct(image: healPic, price: 100, priceShow: "Spend 100", name: "Healing Spot", soldOut: false, amount:1) ,SoldProduct(image: doorPic, price: 100, priceShow: "Spend 100", name: "Doors", soldOut: false, amount: 1), SoldProduct(image: trapsPic, price: -200, priceShow: "Earn 200", name: "Traps", soldOut: false, amount:1) ,SoldProduct(image: torchPic, price:100, priceShow:"Spend 100", name:"Torches", soldOut: false, amount:1), SoldProduct(image: chestPic, price: 1000, priceShow:"Spend 1.000", name:"Chests", soldOut: false, amount:1)],[SoldProduct(image: blobsPic, price: -50, priceShow: "Earn 50 Souls - Kill each for 200", name: "Slimes", soldOut: false, amount: 0), SoldProduct(image: skeletonPic, price: -100, priceShow: "Earn 100 Souls - Kill each for 1.000", name: "Skeletons", soldOut: false, amount: 1)], [SoldProduct(image: nil, price: 0, priceShow: "0", name: "Coming Soon", soldOut: true, amount: 0)]]

let sectionList = ["The Soul Keeper","Environment","Enemies","Weapons"]


struct SoldProduct {
    let image: UIImage?
    let price: Int
    let priceShow: String
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
    
//    @IBOutlet weak var shopTable: UITableView!
        
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        //        self.backgroundView?.colo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopList[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = shopList[indexPath.section][indexPath.row].name
        cell.imageView?.image = shopList[indexPath.section][indexPath.row].image
        cell.detailTextLabel?.text = "\(String(describing: shopList[indexPath.section][indexPath.row].priceShow)) Souls"
        if shopList[indexPath.section][indexPath.row].price > 0 {
            cell.detailTextLabel?.textColor = .red
        } else if shopList[indexPath.section][indexPath.row].price <= 0 {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0.7058475875, blue: 0.3398946524, alpha: 1)
        }
        cell.textLabel?.textColor = .black
        shopList[indexPath.section][indexPath.row].isSoldOut()
        if shopList[indexPath.section][indexPath.row].soldOut {
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.text = "Sold Out"
            cell.detailTextLabel?.textColor = .gray
        } else {
            cell.textLabel?.textColor = .black
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("You selected cell #\(indexPath.row)!")
        if shopList[indexPath.section][indexPath.row].price > coinCounter || shopList[indexPath.section][indexPath.row].soldOut { return }
        
        if shopList[indexPath.section][indexPath.row].name == "Torches" {
            sceneDung.buyLights()
            shopList[indexPath.section][indexPath.row].amount = 0
        } else if shopList[indexPath.section][indexPath.row].name == "Doors" {
            sceneDung.buyDoors()
            shopList[indexPath.section][indexPath.row].amount = 0
        } else if shopList[indexPath.section][indexPath.row].name == "Skeletons" {
            //skeletonBought = true
            sceneDung.hintSpawn()
            shopList[indexPath.section][indexPath.row].amount = 0
        } else if shopList[indexPath.section][indexPath.row].name == "Light Crystal" {
            sceneDung.buyCrystal()
            shopList[indexPath.section][indexPath.row].amount = 0
        }else if shopList[indexPath.section][indexPath.row].name == "Chests" {
            sceneDung.buyChests()
            shopList[indexPath.section][indexPath.row].amount = 0
        }else if shopList[indexPath.section][indexPath.row].name == "Traps" {
            trapsBought = true
            shopList[indexPath.section][indexPath.row].amount = 0
        } else if shopList[indexPath.section][indexPath.row].name == "Healing Spot" {
            sceneDung.buyHeal()
            shopList[indexPath.section][indexPath.row].amount = 0
        } else if shopList[indexPath.section][indexPath.row].name == "Slimes" {
            sceneDung.buySlimes()
            shopList[indexPath.section][indexPath.row].amount = 0
        }
        
        
        
        coinCounter -= shopList[indexPath.section][indexPath.row].price
        self.reloadData()
        self.removeFromSuperview()
        sceneDung.shop.texture = .init(imageNamed: "shop")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { // CHANGE THE FONT HERE
        guard let header = view as? UITableViewHeaderFooterView else { return }
        if section == 0 {header.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)}
        else {header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)}
    }
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        let header: UITableViewHeaderFooterView = headerView(forSection: section)!
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 50 }
        return 30
    }

}

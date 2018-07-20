//
//  MeteoriteTableViewController.swift
//  DataRoutr
//
//  Created by Zukosky,Jonah on 7/19/18.
//  Copyright © 2018 Zukosky,Jonah. All rights reserved.
//

import UIKit

class MeteoriteTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptyView = UIView()
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        emptyLabel.text = "No Current Meteorites 😭\nYou need to select a route!"
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        
        tableView.backgroundView = emptyLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(Singletons.sharedInstance.selectedMeteorites.count)
        if Singletons.sharedInstance.selectedMeteorites.count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        return Singletons.sharedInstance.selectedMeteorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meteoriteCell", for: indexPath)

        if let name = Singletons.sharedInstance.selectedMeteorites[indexPath.row].name,
            let id = Singletons.sharedInstance.selectedMeteorites[indexPath.row].id{
            cell.textLabel?.text = name + "-" + id
        }else {
            cell.textLabel?.text = "No Meteorite Name"
        }
    
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MeteoriteViewController {
            if let name = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].name,
                let recclass = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].recclass,
                let mass = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].mass,
                let year = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].year,
                let location = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].GeoLocation,
                let id = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0].id{
                
                destination.titleText = name + "-" + id
                destination.classText = recclass
                destination.massText = mass
                destination.yearText = year
                destination.coordinatesText = location
                destination.addRouteButtonIsEnabled = false
                destination.meteorite = Singletons.sharedInstance.selectedMeteorites[tableView.indexPathForSelectedRow?.row ?? 0]
                
                
            }

            
        }
    }
 

}

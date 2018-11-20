//
//  EmojiTableViewController.swift
//  EmojiDictionary
//
//  Created by Arvin Zojaji on 2018-11-18.
//  Copyright © 2018 Arvin Zojaji. All rights reserved.
//

import UIKit

class EmojiTableViewController: UITableViewController {

    override func viewDidLoad() {
        // Uncomment below to programatically delete memory in app sandbox
        let fm = FileManager()
        if let _ = try? fm.removeItem(atPath: Emoji.ArchiveURL.path) {
            print("Delete success")
        } else {
            print("Delete fail")
        }
        
        super.viewDidLoad()
        print("View did load")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        if let loadedEmojis = Emoji.loadFromFile() {
            print("Loading saved emojis")
            emojis = loadedEmojis
        } else {
            print("Loading sample emojis")
            emojis = Emoji.loadSampleEmojis()
        }
    }
    
    

    // MARK: - Table view data source
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return emojis.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0..<emojis.count ~= section {
            return emojis[section].count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EmojiTableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
        let emoji = emojis[indexPath.section][indexPath.row]

        cell.update(with: emoji)
        
        cell.showsReorderControl = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedEmoji = emojis.remove(at: sourceIndexPath.row)
        emojis.insert(movedEmoji, at: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String? {
        let sectionName: String?
        switch section {
        case 0:
            sectionName = "Smileys & People"
        case 1:
            sectionName = "Animals"
        case 2:
            sectionName = "Food & Drink"
        case 3:
            sectionName = "Activity"
        case 4:
            sectionName = "Travel & Places"
        case 5:
            sectionName = "Objects"
        case 6:
            sectionName = "Symbols"
        case 7:
            sectionName = "Flags"
        default:
            sectionName = nil
        }
        return sectionName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Emoji.saveToFile(emojis: emojis)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            emojis[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEmoji" {
            let indexPath = tableView.indexPathForSelectedRow!
            let emoji = emojis[indexPath.section][indexPath.row]
            let navigationController = segue.destination as! UINavigationController
            let addEditEmojiTableViewController = navigationController.topViewController as! AddEditEmojiTableViewController
            addEditEmojiTableViewController.emoji = emoji
        }
    }

    var emojis: [[Emoji]] = []
    
    @IBAction func unwindToTableEmojiView(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! AddEditEmojiTableViewController
        
        if let emoji = sourceViewController.emoji {
            print(emoji)
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                emojis[selectedIndexPath.section][selectedIndexPath.row] = emoji
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newRowIndex = emojis.count - 1
                let newIndexPath = IndexPath(row: newRowIndex, section: 0)
                emojis[0].append(emoji)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

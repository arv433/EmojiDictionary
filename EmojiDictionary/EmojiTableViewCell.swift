//
//  EmojiTableViewCell.swift
//  EmojiDictionary
//
//  Created by Arvin Zojaji on 2018-11-19.
//  Copyright © 2018 Arvin Zojaji. All rights reserved.
//

import UIKit

class EmojiTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func update(with emoji: Emoji) {
        symbolLabel.text = " \(emoji.symbol) "
        nameLabel.text = emoji.name
        descriptionLabel.text = emoji.description
    }
}

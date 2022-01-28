//
//  InvertedUserTableViewCell.swift
//  TawkToApp
//
//  Created by ios2 on 28/01/22.
//

import UIKit
class InvertedUserTableViewCell: UITableViewCell {

    @IBOutlet weak var imageNotes: UIImageView!
    @IBOutlet weak var imageUser: ImageLoader!
    @IBOutlet weak var lableDetail: UILabel!
    @IBOutlet weak var lableUserName: UILabel!
    @IBOutlet weak var viewBack: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

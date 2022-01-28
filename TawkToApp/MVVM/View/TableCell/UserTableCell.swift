//
//  UserTableCell.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import UIKit

class UserTableCell: UITableViewCell {

    @IBOutlet weak var imageNote: UIImageView!
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

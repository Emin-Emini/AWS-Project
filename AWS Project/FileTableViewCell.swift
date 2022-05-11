//
//  FileTableViewCell.swift
//  AWS Project
//
//  Created by Emin Emini on 11.05.2022..
//

import UIKit

class FileTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var fileImage: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    
    // MARK: - View
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

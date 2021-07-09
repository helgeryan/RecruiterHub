//
//  ContactInfoCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/15/21.
//

import UIKit

class ContactInfoCell: UITableViewCell {
   
    static let identifier = "ContactInfoCell"
    
    private var model:ContactInfoModel?
    
    private let label:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let attributeLabel:UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(attributeLabel)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: ContactInfoModel) {
        self.model = model
        label.text = model.label
        attributeLabel.text = model.value
    }
    
    /// Prepare the cell to be reused in the tableview
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        attributeLabel.text = nil
    }
    
    /// Layout the subviews of the tableview cell
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Assign Frames
        label.frame = CGRect(x: 5, y: 0, width: contentView.width/4, height: contentView.height)
        attributeLabel.frame =   CGRect(x: label.right + 5,
                               y: 0,
                               width: contentView.width-10-label.width,
                               height: contentView.height)
    }
}

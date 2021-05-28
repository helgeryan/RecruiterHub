//
//  FormTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/1/21.
//

import UIKit

protocol FormTableViewCellDelegate: AnyObject {
    func  formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel)
    func  formTableViewCell(_ cell: FormTableViewCell)
}

class FormTableViewCell: UITableViewCell {
   
    static let identifier = "FormTableViewCell"
    
    public weak var delegate: FormTableViewCellDelegate?
    
    private var model:EditProfileFormModel?
    
    private let formLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let field:UITextField = {
        let field = UITextField()
        field.returnKeyType = .done
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        field.delegate = self
        contentView.addSubview(formLabel)
        contentView.addSubview(field)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: EditProfileFormModel) {
        self.model = model
        formLabel.text = model.label
        field.placeholder = model.placeholder
        field.text = model.value
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        formLabel.text = nil
        field.placeholder = nil
        field.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Assign Frames
        formLabel.frame = CGRect(x: 5, y: 0, width: contentView.width/3, height: contentView.height)
        field.frame =   CGRect(x: formLabel.right + 5,
                               y: 0,
                               width: contentView.width-10-formLabel.width,
                               height: contentView.height)
    }
}


// MARK: - Field
extension FormTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.formTableViewCell(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("Ended Editing")
        
        model?.value = textField.text
        guard let model = model, model.value != "" else {
            return
        }
        delegate?.formTableViewCell(self, didUpdateField: model)
        textField.resignFirstResponder()
        return
    }
}

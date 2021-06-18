//
//  ScoutCollectionViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/6/21.
//

import UIKit

class ScoutCollectionViewCell: UICollectionViewCell {
    static let identifier = "ScoutCollectionViewCell"
    
    private let attributeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let verifiedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Verified"
        label.textColor = .secondaryLabel
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let verifiedValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Verified Value"
        label.textColor = .secondaryLabel
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.borderWidth = 5
        layer.cornerRadius = 10
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
        contentView.addSubview(attributeLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(verifiedLabel)
        contentView.addSubview(verifiedValueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(scoutInfo: ScoutInfo, attribute: ScoutAttributes) {

            var value = 0.0
            var verifiedValue = 0.0
            switch attribute {
            case .fastball:
                attributeLabel.text = "FB"
                value = scoutInfo.fastball
                verifiedValue = scoutInfo.verifiedfastball
                break
            case .curveball:
                attributeLabel.text = "CB"
                value = scoutInfo.curveball
                verifiedValue = scoutInfo.verifiedcurveball
                break
            case .slider:
                attributeLabel.text = "SL"
                value = scoutInfo.slider
                verifiedValue = scoutInfo.verifiedslider
                break
            case .changeup:
                attributeLabel.text = "CH"
                value = scoutInfo.changeup
                verifiedValue = scoutInfo.verifiedchangeup
                break
            case .sixty:
                attributeLabel.text = "60 Time"
                value = scoutInfo.sixty
                verifiedValue = scoutInfo.verifiedsixty
                break
            case .infield:
                attributeLabel.text = "IF"
                value = scoutInfo.infield
                verifiedValue = scoutInfo.verifiedinfield
                break
            case .outfield:
                attributeLabel.text = "OF"
                value = scoutInfo.outfield
                verifiedValue = scoutInfo.verifiedoutfield
                break
            case .exitVelo:
                attributeLabel.text = "Exit Velo"
                value = scoutInfo.exitVelo
                verifiedValue = scoutInfo.verifiedexitVelo
                break
            }
            if value == 0.0 {
                valueLabel.text = "N/A"
            }
            else {
                valueLabel.text = String(value)
            }
            if verifiedValue == 0.0 {
                verifiedValueLabel.text = "N/A"
            }
            else {
                verifiedValueLabel.text = String(verifiedValue)
            }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attributeLabel.frame = CGRect(x: 10 , y: 10, width: contentView.width - 20 , height: 20)
        valueLabel.frame = CGRect(x: 10 , y: attributeLabel.bottom + 20, width: contentView.width - 20 , height: 20)
        verifiedLabel.frame = CGRect(x: 10 , y: valueLabel.bottom + 20, width: contentView.width - 20 , height: 20)
        verifiedValueLabel.frame = CGRect(x: 10 , y: verifiedLabel.bottom + 20, width: contentView.width - 20 , height: 20)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        attributeLabel.text = ""
    }
}

public struct ScoutInfo {
    var fastball: Double
    var curveball: Double
    var slider: Double
    var changeup: Double
    var sixty: Double
    var infield: Double
    var outfield: Double
    var exitVelo: Double
    var verifiedfastball: Double
    var verifiedcurveball: Double
    var verifiedslider: Double
    var verifiedchangeup: Double
    var verifiedsixty: Double
    var verifiedinfield: Double
    var verifiedoutfield: Double
    var verifiedexitVelo: Double
    
    init() {
        fastball = 0.0
        curveball = 0.0
        slider = 0.0
        changeup = 0.0
        sixty = 0.0
        infield = 0.0
        outfield = 0.0
        exitVelo = 0.0
        verifiedfastball = 0.0
        verifiedcurveball = 0.0
        verifiedslider = 0.0
        verifiedchangeup = 0.0
        verifiedsixty = 0.0
        verifiedinfield = 0.0
        verifiedoutfield = 0.0
        verifiedexitVelo = 0.0
    }
}

public enum ScoutAttributes {
    case fastball
    case curveball
    case slider
    case changeup
    case sixty
    case infield
    case outfield
    case exitVelo
}

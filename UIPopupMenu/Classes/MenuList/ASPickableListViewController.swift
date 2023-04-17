
//
//  ASPickableListViewController.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 20.02.2023.
//

import Foundation
import UIKit
/*
public protocol ASPickableListViewControllerDataSource: AnyObject {
    func numberOfSections(in picker: ASPickableListViewController) -> Int
    func pickerView(_ picker: ASPickableListViewController, numberOfRowsInSection section: Int) -> Int
    func pickerView(_ picker: ASPickableListViewController, titleForHeaderIn section: Int) -> String?
    func pickerView(_ picker: ASPickableListViewController, cellItemFor indexPath: IndexPath) -> ASPickableListViewController.CellItem
}

public protocol ASPickableListViewControllerDelegate: AnyObject {
    func pickerView(_ picker: ASPickableListViewController, didSelectItem item: ASPickableListViewController.CellItem, at indexPath: IndexPath)
}

final public class ASPickableListViewController: ASTableTrackingController {
    
    public var dismissesOnSelection: Bool = true
    public var isMultipleSelectionAllowed: Bool = false {
        didSet { tableView.allowsMultipleSelection = isMultipleSelectionAllowed }
    }
    
    public struct CellItem {
        
        let identifier: String
        
        let title: String
        let image: UIImage?
        
        let subTitle: String?
        
        let attributes: Attributes
        let isSelected: Bool
        
        public init(identifier: String = UUID().uuidString, title: String, image: UIImage? = nil, subTitle: String? = nil, attributes: ASPickableListViewController.CellItem.Attributes = [], isSelected: Bool = false) {
            self.identifier = identifier
            self.title = title
            self.image = image
            self.subTitle = subTitle
            self.attributes = attributes
            self.isSelected = isSelected
        }
        
        public struct Attributes: OptionSet {
            public let rawValue: UInt
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
            
            public static let destructive = Attributes(rawValue: 1 << 1)
            public static let disabled = Attributes(rawValue: 1 << 2)
        }
    }
    
    var originalSelection: Set<String> = []
    var mutableSelection: [String: Bool] = [:]
    
    weak public var delegate: ASPickableListViewControllerDelegate?
    weak public var dataSource: ASPickableListViewControllerDataSource? {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsHeaderViewsToFloat = false
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: .init(style: .systemMaterialLight), style: .separator)
        tableView.register(ASPickerCell.self, forCellReuseIdentifier: "pickerCell")
        
        tableView.register(GenericTableViewHeaderFooterView<ASSectionTitleView>.self, forHeaderFooterViewReuseIdentifier: "sectionTitle")
        tableView.register(GenericTableViewHeaderFooterView<ASSectionHeaderView>.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.register(GenericTableViewHeaderFooterView<ASSectionSeparatorView>.self, forHeaderFooterViewReuseIdentifier: "sectionSeparator")
        
        if let title {
            headerView = {
                let header = ASSectionTitleView(frame: .init(origin: .zero, size: .init(width: tableView.bounds.width, height: 40)))
                header.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                header.titleLabel.text = title
                
                return header
            }()
        }
        
        let footer = UIView()
        footer.backgroundColor = .clear
        footer.frame.size.height = 0.01
        tableView.tableFooterView = footer
    }
}

extension ASPickableListViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.pickerView(self, numberOfRowsInSection: section) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! ASPickerCell
        cell.backgroundColor = .clear
        
        guard let dataSource else {
            return cell
        }
        
        let item = dataSource.pickerView(self, cellItemFor: indexPath)
        let isSelected: Bool = mutableSelection[item.identifier] ?? item.isSelected
        let isDescructive: Bool = item.attributes.contains(.destructive)
        let isEnabled: Bool = !item.attributes.contains(.disabled)
        
        cell.selectionStyle = .none
        cell.tintColor = isEnabled
            ? (isDescructive ? UIColor.red : UIColor.label)
            : UIColor.secondaryLabel
        
        //cell.showSelection(isSelected, animated: false)
        cell.setSelected(isSelected, animated: false)
        
        cell.titleLabel.numberOfLines = 2
        cell.titleLabel.textColor = isEnabled
            ? (isDescructive ? UIColor.red : UIColor.label)
            : UIColor.secondaryLabel
        
        cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.titleLabel.lineBreakMode = .byTruncatingTail
        cell.titleLabel.text = item.title
        
        if let subTitle = item.subTitle {
            cell.subTitleLabel.numberOfLines = 2
            cell.subTitleLabel.textColor = UIColor.secondaryLabel
            cell.subTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            cell.subTitleLabel.lineBreakMode = .byTruncatingTail
            cell.subTitleLabel.text = subTitle
            
        } else if cell.hasSubtitleLabel {
            cell.subTitleLabel.text = nil
        }
        
        if let image = item.image {
            cell.imageViewRight.contentMode = .scaleAspectFit
            cell.imageViewRight.image = image.withRenderingMode(.alwaysTemplate)
            
        } else if cell.hasRightImage {
            cell.imageViewRight.image = nil
        }
        
        cell.updateConstraintsIfNeeded()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.dataSource?.numberOfSections?(in: tableView) ?? 1 == 1 {
            return nil
        }
        
        if let text = dataSource?.pickerView(self, titleForHeaderIn: section) {
            if section == 0 && headerView == nil {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionTitle") as! GenericTableViewHeaderFooterView<ASSectionTitleView>
                header.mViewContent.titleLabel.text = text
                header.backgroundColor = .clear
                return header
                
            } else {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! GenericTableViewHeaderFooterView<ASSectionHeaderView>
                header.mViewContent.titleView.titleLabel.text = text
                header.backgroundColor = .clear
                return header
            }
            
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionSeparator") as! GenericTableViewHeaderFooterView<ASSectionSeparatorView>
            header.backgroundColor = .clear
            header.mViewContent.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return header
        }
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let item = dataSource?.pickerView(self, cellItemFor: indexPath) else { return nil }
        if item.attributes.contains(.disabled) {
            return nil
            
        } else {
            return indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource?.pickerView(self, cellItemFor: indexPath) else { return }
        
        let isSelected = mutableSelection[item.identifier] ?? item.isSelected
        mutableSelection[item.identifier] = !isSelected
            
        delegate?.pickerView(self, didSelectItem: item, at: indexPath)
        
        if dismissesOnSelection && !isBeingDismissed {
            dismiss(animated: true)
        }
    }
}
*/

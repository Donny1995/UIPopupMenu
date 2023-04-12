//
//  ASPickableListView.swift
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 11.04.2023.
//

import Foundation
import UIKit

public protocol ASPickableListViewDataSource: AnyObject {
    func numberOfSections(in picker: ASPickableListView) -> Int
    func pickerView(_ picker: ASPickableListView, numberOfRowsInSection section: Int) -> Int
    func pickerView(_ picker: ASPickableListView, titleForHeaderIn section: Int) -> String?
    func pickerView(_ picker: ASPickableListView, cellItemFor indexPath: IndexPath) -> ASPickableListView.CellItem
}

public protocol ASPickableListViewDelegate: AnyObject {
    func pickerView(_ picker: ASPickableListView, didSelectItem item: ASPickableListView.CellItem, at indexPath: IndexPath)
}

final public class ASPickableListView: ASTableTrackingView {
    
    public var dismissesOnSelection: Bool = true
    public var isMultipleSelectionAllowed: Bool = false {
        didSet { tableView.allowsMultipleSelection = isMultipleSelectionAllowed }
    }
    
    public struct CellItem {
        
        public let identifier: String
        
        public let title: String
        public let image: UIImage?
        public let subTitle: String?
        public let attributes: Attributes
        public let isSelected: Bool
        public let selectionType: SelectionType
        
        public init(identifier: String = UUID().uuidString, title: String, image: UIImage? = nil, subTitle: String? = nil, attributes: ASPickableListView.CellItem.Attributes = [], isSelected: Bool = false, seletionType: SelectionType = .tick) {
            self.identifier = identifier
            self.title = title
            self.image = image
            self.subTitle = subTitle
            self.attributes = attributes
            self.isSelected = isSelected
            self.selectionType = seletionType
        }
        
        public struct Attributes: OptionSet {
            public let rawValue: UInt
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
            
            public static let destructive = Attributes(rawValue: 1 << 1)
            public static let disabled = Attributes(rawValue: 1 << 2)
        }
        
        public enum SelectionType {
            case tick
            case gray
        }
    }
    
    var originalSelection: Set<String> = []
    var mutableSelection: [String: Bool] = [:]
    
    weak public var delegate: ASPickableListViewDelegate?
    weak public var dataSource: ASPickableListViewDataSource? {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
    
    override public func viewDidLoad() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsHeaderViewsToFloat = false
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: .init(style: .systemMaterialLight), style: .separator)
        
        tableView.register(ASPickerCell.self, forCellReuseIdentifier: "ASPickerCell")
        tableView.register(GenericTableViewHeaderFooterView<ASSectionTitleView>.self, forHeaderFooterViewReuseIdentifier: "GenericTableViewHeaderFooterView<ASSectionTitleView>")
        tableView.register(GenericTableViewHeaderFooterView<ASSectionHeaderView>.self, forHeaderFooterViewReuseIdentifier: "GenericTableViewHeaderFooterView<ASSectionHeaderView>")
        tableView.register(GenericTableViewHeaderFooterView<ASSectionSeparatorView>.self, forHeaderFooterViewReuseIdentifier: "GenericTableViewHeaderFooterView<ASSectionSeparatorView>")
        
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
        
        super.viewDidLoad()
    }
    
    //Loading
    public internal(set) var isLoading: Bool = false
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: indicator.superview!.centerXAnchor).activate()
        indicator.centerYAnchor.constraint(equalTo: indicator.superview!.centerYAnchor).activate()
        
        indicator.isHidden = !isLoading
        indicator.startAnimating()
        return indicator
    }()
    
    public func setLoading(loading: Bool, animated: Bool) {
        guard loading != isLoading else { return }
        isLoading = loading
        
        func commit() {
            tableView.alpha = isLoading ? 0.0 : 1.0
            headerView?.alpha = isLoading ? 0.0 : 1.0
            footerView?.alpha = isLoading ? 0.0 : 1.0
            activityIndicator.superview?.bringSubviewToFront(activityIndicator)
            activityIndicator.isHidden = !isLoading
            
            if isLoading {
                activityIndicator.startAnimating()
                
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        if animated {
            UIView.animate(withDuration: 1/3, delay: 0.0, options: [.allowAnimatedContent], animations: commit)
            
        } else {
            commit()
        }
    }
}

extension ASPickableListView: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.pickerView(self, numberOfRowsInSection: section) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ASPickerCell", for: indexPath) as! ASPickerCell
        cell.backgroundColor = .clear
        
        guard let dataSource else {
            return cell
        }
        
        let item = dataSource.pickerView(self, cellItemFor: indexPath)
        let isDescructive: Bool = item.attributes.contains(.destructive)
        let isEnabled: Bool = !item.attributes.contains(.disabled)
        
        cell.menuSelectionStyle = item.selectionType
        cell.tintColor = isEnabled
            ? (isDescructive ? UIColor.red : UIColor.label)
            : UIColor.secondaryLabel
        
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
    
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = dataSource?.pickerView(self, cellItemFor: indexPath)
        if item?.isSelected ?? false {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let resultHeader: UIView?
        defer {
            resultHeader?.updateConstraintsIfNeeded()
            resultHeader?.layoutIfNeeded()
        }
        
        if let text = dataSource?.pickerView(self, titleForHeaderIn: section), !text.isEmpty {
            if section == 0 && headerView == nil {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GenericTableViewHeaderFooterView<ASSectionTitleView>") as! GenericTableViewHeaderFooterView<ASSectionTitleView>
                header.mViewContent.titleLabel.text = text
                header.backgroundColor = .clear
                resultHeader = header
                
            } else {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GenericTableViewHeaderFooterView<ASSectionHeaderView>") as! GenericTableViewHeaderFooterView<ASSectionHeaderView>
                header.mViewContent.titleView.titleLabel.text = text
                header.backgroundColor = .clear
                resultHeader = header
            }
            
        } else if section != 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GenericTableViewHeaderFooterView<ASSectionSeparatorView>") as! GenericTableViewHeaderFooterView<ASSectionSeparatorView>
            header.backgroundColor = .clear
            header.mViewContent.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            resultHeader = header
            
        } else {
            resultHeader = nil
        }
        
        return resultHeader
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.updateConstraintsIfNeeded()
        view.layoutIfNeeded()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let hasHeader = !(dataSource?.pickerView(self, titleForHeaderIn: section)?.isEmpty ?? true && section == 0)
        return hasHeader
            ? UITableView.automaticDimension
            : 0.0
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
        
        if !isMultipleSelectionAllowed {
            for cellIndex in tableView.indexPathsForVisibleRows ?? [] where cellIndex != indexPath {
                if let cell = tableView.cellForRow(at: cellIndex), cell.isSelected {
                    tableView.deselectRow(at: cellIndex, animated: false)
                }
            }
        }
        
        delegate?.pickerView(self, didSelectItem: item, at: indexPath)
        
        if dismissesOnSelection {
            dismiss(animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView(tableView, didSelectRowAt: indexPath)
    }
}

//
//  TextFieldTestViewController.swift
//  UIPopupMenu_Example
//
//  Created by Alexandr Sivash on 12.04.2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import UIPopupMenu

class TextFieldTestViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let textField = UITextField()
    let textFieldData: [String] = [
        #"let redSubview = UIView()"#,
        #"redSubview.backgroundColor = .red"#,
        #"scrollView.addSubview(redSubview)"#,
        #"redSubview.translatesAutoresizingMaskIntoConstraints = false"#,
        #"redSubview.centerYAnchor.constraint(equalTo: redSubview.superview!.centerYAnchor, constant: -30.0).isActive = true"#,
        #"redSubview.centerXAnchor.constraint(equalTo: redSubview.superview!.centerXAnchor, constant: 60.0).isActive = true"#,
        #"redSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true"#,
        #"redSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true"#,
        #"let greenSubview = UIView()"#,
        #"greenSubview.backgroundColor = .green"#,
        #"scrollView.addSubview(greenSubview)"#,
        #"greenSubview.translatesAutoresizingMaskIntoConstraints = false"#,
        #"greenSubview.centerYAnchor.constraint(equalTo: greenSubview.superview!.centerYAnchor, constant: -80.0).isActive = true"#,
        #"greenSubview.centerXAnchor.constraint(equalTo: greenSubview.superview!.centerXAnchor, constant: 60.0).isActive = true"#,
        #"greenSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true"#,
        #"greenSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true"#,
        #"let button2 = UIButton()"#,
        #"scrollView.addSubview(button2)"#,
        #"button2.translatesAutoresizingMaskIntoConstraints = false"#,
        #"button2.centerXAnchor.constraint(equalTo: button2.superview!.centerXAnchor).isActive = true"#,
        #"button2.centerYAnchor.constraint(equalTo: button2.superview!.centerYAnchor, constant: 100).isActive = true"#,
        #"button2.bottomAnchor.constraint(equalTo: button2.superview!.bottomAnchor, constant: -400).isActive = true"#,
        #"button2.setTitle("System", for: .normal)"#,
        #"button2.setTitleColor(UIColor.systemBlue, for: .normal)"#,
        #"button2.setTitle("System", for: .highlighted)"#,
        #"button2.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .highlighted)"#,
        #"button1.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)"#,
        #"addSelfDragRecognizer(button1)"#,
        #"addSelfDragRecognizer(button2)"#,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: scrollView.superview!.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: scrollView.superview!.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: scrollView.superview!.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: scrollView.superview!.bottomAnchor),
        ])
        
        scrollView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.placeholder = "Type something"
        textField.addTarget(self, action: #selector(textFieldTextChanged(sender:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 200),
            textField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -1200)
        ])
    }
    
    weak var currentPopup: ASPopupPresentationView?
    @objc func textFieldTextChanged(sender: UITextField) {
        let suggestions = suggestions(for: sender.text ?? "")
        if suggestions.isEmpty {
            if let currentPopup, !currentPopup.isBeingDismissed {
                currentPopup.dismiss(animated: true)
            }
            
        } else {
            if let currentPopup, !currentPopup.isBeingDismissed {
                if currentPopup.isBeingPresented {
                    //reloading table while presenting popup is very illegal at the moment
                    //(currentPopup.contentView as? ASPickableListView)?.tableView.reloadData()
                    
                } else {
                    (currentPopup.contentView as? ASPickableListView)?.tableView.reloadData()
                }
                
            } else {
                let newPopupList = ASPickableListView()
                newPopupList.delegate = self
                newPopupList.dataSource = self
                let newPopup = ASPopupPresentationView(contentView: newPopupList, originView: sender)
                newPopup?.canOverlapSourceViewRect = false
                currentPopup = newPopup
                newPopup?.present(animated: true)
            }
        }
    }
    
    var currentSuggestions: [String] = []
    func suggestions(for text: String) -> [String] {
        guard !text.isEmpty else {
            return []
        }
        
        currentSuggestions = textFieldData.filter { $0.contains(text) }
        return currentSuggestions
    }
}

extension TextFieldTestViewController: ASPickableListViewDelegate, ASPickableListViewDataSource {
    
    
    func numberOfSections(in picker: UIPopupMenu.ASPickableListView) -> Int {
        return 1
    }
    
    func pickerView(_ picker: UIPopupMenu.ASPickableListView, numberOfRowsInSection section: Int) -> Int {
        return currentSuggestions.count
    }
    
    func pickerView(_ picker: UIPopupMenu.ASPickableListView, titleForHeaderIn section: Int) -> String? {
        return nil
    }
    
    func pickerView(_ picker: UIPopupMenu.ASPickableListView, cellItemFor indexPath: IndexPath) -> UIPopupMenu.ASPickableListView.CellItem {
        return .init(title: currentSuggestions[indexPath.row])
    }
    
    func pickerView(_ picker: UIPopupMenu.ASPickableListView, didSelectItem item: UIPopupMenu.ASPickableListView.CellItem, at indexPath: IndexPath) {
        textField.text = item.title
    }
}

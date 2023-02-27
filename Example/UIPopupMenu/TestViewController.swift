//
//  TestViewController.swift
//  UIPopupMenu_Example
//
//  Created by Alexandr Sivash on 27.02.2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import UIPopupMenu

class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let button = UIButton()
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: button.superview!.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor).isActive = true
        
        button.setTitle("Custom", for: .normal)
        button.setTitleColor(UIColor.orange, for: .normal)
        
        button.setTitle("Custom", for: .highlighted)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        
        //button.setBlock(block: { sender in
        //    let alert = UIAlertController(title: "Warning!", message: nil, preferredStyle: .alert)
        //    sender.viewController?.present(alert, animated: true)
        //    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { alert.dismiss(animated: true) })
        //}, forEvent: .touchUpInside)
        
        let redSubview = UIView()
        redSubview.backgroundColor = .red
        view.addSubview(redSubview)
        redSubview.translatesAutoresizingMaskIntoConstraints = false
        redSubview.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30.0).isActive = true
        redSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.0).isActive = true
        redSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        redSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let greenSubview = UIView()
        greenSubview.backgroundColor = .green
        view.addSubview(greenSubview)
        greenSubview.translatesAutoresizingMaskIntoConstraints = false
        greenSubview.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80.0).isActive = true
        greenSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.0).isActive = true
        greenSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        greenSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let button2 = UIButton()
        view.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.centerXAnchor.constraint(equalTo: button2.superview!.centerXAnchor).isActive = true
        button2.centerYAnchor.constraint(equalTo: button2.superview!.centerYAnchor, constant: 100).isActive = true
        
        button2.setTitle("System", for: .normal)
        button2.setTitleColor(UIColor.systemBlue, for: .normal)
        
        button2.setTitle("System", for: .highlighted)
        button2.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .highlighted)
        
        button.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        
        addSelfDragRecognizer(button)
        addSelfDragRecognizer(button2)
        
        if #available(iOS 16.0, *) {
            button2.menu = UIMenu(children: [
                UIMenu(title: "SubMenu1", options: [.displayInline], children: [
                    UIAction(title: "Action1", handler: { _ in
                        print("hello")
                    }),
                    UIAction(
                        title: "Action2 with a very very big and logn name that will barely fit anywhere on screen",
                        subtitle: "subtitle with a very very big and logn name that will barely fit anywhere on screen",
                        handler: { _ in }
                    ),
                ]),
                UIMenu(title: "SubMenu2 With a very long title, title is so big, that nothing can handle it", options: [.displayInline], children: [
                    UIAction(title: "Action3", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.destructive], state: .mixed, handler: { _ in }),
                    UIAction(title: "Action6", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.destructive], state: .on, handler: { _ in }),
                    UIAction(title: "Action4", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.destructive, .disabled], state: .off, handler: { _ in }),
                ]),
                
                UIMenu(options: [.displayInline], children: [
                    UIAction(title: "Action3", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.destructive], state: .mixed, handler: { _ in }),
                    UIAction(title: "Action6", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.disabled], state: .on, handler: { _ in }),
                    UIAction(title: "Action4", subtitle: "subtitle", image: UIImage(systemName: "trash"), attributes: [.destructive, .disabled], state: .off, handler: { _ in }),
                ]),
            ])
        } else {
            // Fallback on earlier versions
        }
    }
    
    fileprivate func addSelfDragRecognizer(_ button: UIButton) {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(didDragCustomButton(sender:)))
        button.addGestureRecognizer(pan)
    }
    
    var startingPoint = CGPoint.zero
    @objc func didDragCustomButton(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            startingPoint = sender.view?.center ?? .zero
            
        } else {
            sender.view?.center = CGPoint(
                x: startingPoint.x + sender.translation(in: nil).x,
                y: startingPoint.y + sender.translation(in: nil).y
            )
        }
    }
    
    @objc func didPressButton(sender: UIButton) {
        let content = ASPickableListViewController()
        content.dismissesOnSelection = false
        content.isMultipleSelectionAllowed = true
        content.dataSource = self
        content.delegate = self
        //content.title = "Test Popup"
        
        let controller = ASPopupPresentationController(contentViewController: content, originView: sender)
        present(controller, animated: true)
    }
    
    let data: [[ASPickableListViewController.CellItem]] = [
        [
            ASPickableListViewController.CellItem(title: "Simple item"),
            ASPickableListViewController.CellItem(title: "Simple item", subTitle: "with sub title"),
            ASPickableListViewController.CellItem(title: "Selected item", subTitle: "with sub title", isSelected: true),
            ASPickableListViewController.CellItem(title: "Disabled item", subTitle: "with sub title", attributes: [.disabled]),
            ASPickableListViewController.CellItem(title: "Desctructive item", subTitle: "with sub title", attributes: [.destructive]),
        ], [
            ASPickableListViewController.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", isSelected: true),
            ASPickableListViewController.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", attributes: [.disabled]),
        ]
    ]
}

extension TestViewController: ASPickableListViewControllerDataSource, ASPickableListViewControllerDelegate {
    
    func numberOfSections(in picker: ASPickableListViewController) -> Int {
        return data.count
    }
    
    func pickerView(_ picker: ASPickableListViewController, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func pickerView(_ picker: ASPickableListViewController, titleForHeaderIn section: Int) -> String? {
        switch section {
        case 0:
            return "First section"
            
        case 1:
            return "SubMenu2 With a very long title, title is so big, that nothing can handle it"
            
        default:
            return nil
        }
    }
    
    func pickerView(_ picker: ASPickableListViewController, cellItemFor indexPath: IndexPath) -> ASPickableListViewController.CellItem {
        return data[indexPath.section][indexPath.row]
    }
    
    func pickerView(_ picker: ASPickableListViewController, didSelectItem item: ASPickableListViewController.CellItem, at indexPath: IndexPath) {
        
        //Title: UIColor.label, 17
        //Subtitle: 12
        //Header: UIColor.secondaryLabel 12
    }
}

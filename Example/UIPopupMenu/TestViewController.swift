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
    
    let button1 = UIButton()
    let scrollView = UIScrollView()
    
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
        
        scrollView.addSubview(button1)
        button1.center = .init(x: 200, y: 300)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.centerXAnchor.constraint(equalTo: button1.superview!.centerXAnchor).isActive = true
        button1.centerYAnchor.constraint(equalTo: button1.superview!.centerYAnchor).isActive = true
        
        button1.setTitle("Custom", for: .normal)
        button1.setTitleColor(UIColor.orange, for: .normal)
        
        button1.setTitle("Custom", for: .highlighted)
        button1.setTitleColor(UIColor.orange, for: .highlighted)
        
        //button.setBlock(block: { sender in
        //    let alert = UIAlertController(title: "Warning!", message: nil, preferredStyle: .alert)
        //    sender.viewController?.present(alert, animated: true)
        //    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { alert.dismiss(animated: true) })
        //}, forEvent: .touchUpInside)
        
        let redSubview = UIView()
        redSubview.backgroundColor = .red
        scrollView.addSubview(redSubview)
        redSubview.translatesAutoresizingMaskIntoConstraints = false
        redSubview.centerYAnchor.constraint(equalTo: redSubview.superview!.centerYAnchor, constant: -30.0).isActive = true
        redSubview.centerXAnchor.constraint(equalTo: redSubview.superview!.centerXAnchor, constant: 60.0).isActive = true
        redSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        redSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let greenSubview = UIView()
        greenSubview.backgroundColor = .green
        scrollView.addSubview(greenSubview)
        greenSubview.translatesAutoresizingMaskIntoConstraints = false
        greenSubview.centerYAnchor.constraint(equalTo: greenSubview.superview!.centerYAnchor, constant: -80.0).isActive = true
        greenSubview.centerXAnchor.constraint(equalTo: greenSubview.superview!.centerXAnchor, constant: 60.0).isActive = true
        greenSubview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        greenSubview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let button2 = UIButton()
        scrollView.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.centerXAnchor.constraint(equalTo: button2.superview!.centerXAnchor).isActive = true
        button2.centerYAnchor.constraint(equalTo: button2.superview!.centerYAnchor, constant: 100).isActive = true
        button2.bottomAnchor.constraint(equalTo: button2.superview!.bottomAnchor, constant: -400).isActive = true
        button2.setTitle("System", for: .normal)
        button2.setTitleColor(UIColor.systemBlue, for: .normal)
        
        button2.setTitle("System", for: .highlighted)
        button2.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .highlighted)
        
        button1.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        
        addSelfDragRecognizer(button1)
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
    
    var fuckingButtonPos: CGPoint = .zero
    override func viewWillLayoutSubviews() {
        fuckingButtonPos = button1.center
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button1.center = fuckingButtonPos
    }
    
    var isLoading: Bool = false
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
        let content = ASPickableListView()
        content.dismissesOnSelection = true // false
        content.isMultipleSelectionAllowed = false // true
        content.dataSource = self
        content.delegate = self
        //content.title = "Test Popup"
        
        isLoading = true
        content.setLoading(loading: true, animated: false)
        
        let presentationView = ASPopupPresentationView(contentView: content, originView: sender)
        presentationView?.present(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            content.setLoading(loading: false, animated: true)
            content.tableView.reloadData()
        }
    }
    
    let data: [[ASPickableListView.CellItem]] = [
        [
            ASPickableListView.CellItem(title: "Simple item"),
            ASPickableListView.CellItem(title: "Simple item", subTitle: "with sub title"),
            ASPickableListView.CellItem(title: "Selected item", subTitle: "with sub title", isSelected: true),
            ASPickableListView.CellItem(title: "Disabled item", subTitle: "with sub title", attributes: [.disabled]),
            ASPickableListView.CellItem(title: "Desctructive item", subTitle: "with sub title", attributes: [.destructive]),
        ], [
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", isSelected: true),
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", attributes: [.disabled]),
        ], [
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", isSelected: true),
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", attributes: [.disabled]),
        ], [
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", isSelected: true),
            ASPickableListView.CellItem(title: "Simple item with very long title that barely fits to the screen", image: UIImage(systemName: "trash"), subTitle: "with sub title that barely fits to the screen", attributes: [.disabled]),
        ], [
            ASPickableListView.CellItem(title: "Simple item"),
            ASPickableListView.CellItem(title: "Simple item", subTitle: "with sub title"),
            ASPickableListView.CellItem(title: "Selected item", subTitle: "with sub title", isSelected: true),
            ASPickableListView.CellItem(title: "Disabled item", subTitle: "with sub title", attributes: [.disabled]),
            ASPickableListView.CellItem(title: "Desctructive item", subTitle: "with sub title", attributes: [.destructive]),
        ],
    ]
}

extension TestViewController: ASPickableListViewDataSource, ASPickableListViewDelegate {
    
    func numberOfSections(in picker: ASPickableListView) -> Int {
        if isLoading {
            return 1
        }
        
        return data.count
    }
    
    func pickerView(_ picker: ASPickableListView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        
        return data[section].count
    }
    
    func pickerView(_ picker: ASPickableListView, titleForHeaderIn section: Int) -> String? {
        switch section {
        case 0:
            return "First section"
            
        case 1:
            return "SubMenu2 With a very long title, title is so big, that nothing can handle it"
            
        default:
            return nil
        }
    }
    
    func pickerView(_ picker: ASPickableListView, cellItemFor indexPath: IndexPath) -> ASPickableListView.CellItem {
        return data[indexPath.section][indexPath.row]
    }
    
    func pickerView(_ picker: ASPickableListView, didSelectItem item: ASPickableListView.CellItem, at indexPath: IndexPath) {
        
    }
}

//
//  CustomSearchController.swift
//  CustomSearchBar
//
//  Created by Gabriel Theodoropoulos on 8/9/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

protocol CustomSearchControllerDelegate {
    func didStartSearching()
    
    func didEndSearching()
    
    func didTapOnSearchButton()
    
    func didTapOnCancelButton()
    
    func didChangeSearchText(searchText: String)
    
    func searchBarCancelButtonClicked()

    func filterSearchController(id: Int)
}


class CustomSearchController: UISearchController, UISearchBarDelegate {

    var customSearchBar: CustomSearchBar!
    
    var customDelegate: CustomSearchControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Initialization
    
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        
        super.init(searchResultsController: searchResultsController)
        
        
        configureSearchBar(frame: searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Custom functions
    
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        customSearchBar = CustomSearchBar(frame: frame, font: font , textColor: textColor)        
        customSearchBar.barTintColor = bgColor
        customSearchBar.tintColor = textColor
        customSearchBar.showsBookmarkButton = false
        customSearchBar.showsCancelButton = true        
        customSearchBar.delegate = self
        customSearchBar.sizeToFit()
    }

    // MARK: UISearchBarDelegate functions
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        customDelegate.searchBarCancelButtonClicked()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        customDelegate.didStartSearching()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        customDelegate.didEndSearching()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        customDelegate.didChangeSearchText(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        customDelegate.filterSearchController(id: selectedScope)
    }
    
}

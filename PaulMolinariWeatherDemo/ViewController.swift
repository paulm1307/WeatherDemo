//
//  ViewController.swift
//  PaulMolinariWeatherDemo
//
//  Created by Paul Molinari on 6/5/2023.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    lazy var searchBar = {
        let result = UISearchBar(frame: .zero)
        result.delegate = self
        result.autocorrectionType = .no
        result.autocapitalizationType = .none
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var weatherViewHostingController: UIHostingController<WeatherView> = {
        let result = UIHostingController(rootView: WeatherView(viewModel: viewModel))
        result.view.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    let viewModel: ViewModel
    required init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // !
        view.backgroundColor = UIColor.white
        
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 56.0)
        ])
        
        view.addSubview(weatherViewHostingController.view)
        NSLayoutConstraint.activate([
            weatherViewHostingController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            weatherViewHostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            weatherViewHostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            weatherViewHostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        Task {
            await viewModel.updateSearchText(searchText)
        }
    }
}


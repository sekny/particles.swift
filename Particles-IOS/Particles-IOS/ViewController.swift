//
//  ViewController.swift
//  Particles-IOS
//
//  Created by SEKNY YIM on 25/1/25.
//

import UIKit

class ViewController: UIViewController {
    // Properties
    let gradientLayer = CAGradientLayer()
    var animateView: ParticleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        animateView = ParticleView()
        animateView.backgroundColor = .systemMint
        animateView.frame = view.bounds
        
        view.addSubview(animateView)
    }
    
    
}

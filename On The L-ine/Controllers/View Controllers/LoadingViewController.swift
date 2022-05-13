//
//  LoadingViewController.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 5/4/22.
//

import UIKit

class LoadingViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var blur: UIVisualEffectView!
    
    @IBOutlet weak var topLeft: UIView!
    @IBOutlet weak var topCenter: UIView!
    @IBOutlet weak var topRight: UIView!
    @IBOutlet weak var middleRight: UIView!
    @IBOutlet weak var bottomRight: UIView!
    @IBOutlet weak var bottomCenter: UIView!
    @IBOutlet weak var bottomLeft: UIView!
    @IBOutlet weak var middleLeft: UIView!
    
    lazy var views: [UIView] = [
        topLeft,
        topCenter,
        topRight,
        middleRight,
        bottomRight,
        bottomCenter,
        bottomLeft,
        middleLeft
    ]
    
    var viewIndex = 0
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateViews()
    }
    
    // MARK: - Helper Functions
    
    func setupViews() {
        blur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        blur.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func animateViews() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: { [weak self] in
            guard let self = self else { return }
            
            let originalCenter = self.views[self.viewIndex].center
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                if [0,1].contains(self.viewIndex) {
                    self.views[self.viewIndex].center.y -= 30
                } else if [2,3].contains(self.viewIndex) {
                    self.views[self.viewIndex].center.x += 30
                } else if [4,5].contains(self.viewIndex) {
                    self.views[self.viewIndex].center.y += 30
                } else if [6,7].contains(self.viewIndex) {
                    self.views[self.viewIndex].center.x -= 30
                }
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.views[self.viewIndex].center = originalCenter
            })
            
        }, completion: { [weak self] (_) in
            guard let self = self else { return }
            
            self.nextViewIndex()
            self.animateViews()
        })
    }
    
//    func animateViews() {
//        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: { [weak self] in
//            guard let self = self else { return }
//
//            if [0,1].contains(self.viewIndex) {
//                self.views[self.viewIndex].center.y -= 30
//            } else if [2,3].contains(self.viewIndex) {
//                self.views[self.viewIndex].center.x += 30
//            } else if [4,5].contains(self.viewIndex) {
//                self.views[self.viewIndex].center.y += 30
//            } else if [6,7].contains(self.viewIndex) {
//                self.views[self.viewIndex].center.x -= 30
//            }
//        }, completion: { success in
//            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
//                if [0,1].contains(self.viewIndex) {
//                    self.views[self.viewIndex].center.y += 30
//                } else if [2,3].contains(self.viewIndex) {
//                    self.views[self.viewIndex].center.x -= 30
//                } else if [4,5].contains(self.viewIndex) {
//                    self.views[self.viewIndex].center.y -= 30
//                } else if [6,7].contains(self.viewIndex) {
//                    self.views[self.viewIndex].center.x += 30
//                }
//            }, completion: { success in
//                self.nextViewIndex()
//                self.animateViews()
//            })
//        })
//    }
    
    func nextViewIndex() {
        viewIndex = viewIndex == views.count - 1 ? 0 : viewIndex + 1
    }
}

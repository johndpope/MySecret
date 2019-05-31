//
//  ZoomAnimator.swift
//  MySecret
//
//  Created by Amir lahav on 18/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

protocol ZoomAnimatorDelegate: class {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator)
    func transitionDidEndWith(zoomAnimator: ZoomAnimator)
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView?
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect?
    func referenceImage(for zoomAnimator:ZoomAnimator) -> UIImage?
}

class ZoomAnimator: NSObject {
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    var transitionImageView: UIImageView?
    var isPresenting: Bool = true
    
    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoGridVC,
            let toVC = transitionContext.viewController(forKey: .to) as? PhotoDetailViewController,
            let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
            let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
            let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {

                return

        }
        containerView.frame = UIScreen.main.bounds
        print("zoom in")


        
        toVC.view.alpha = 0.0
        toReferenceImageView.isHidden = true
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)

        let referenceImage = self.fromDelegate?.referenceImage(for: self)!
        
        if self.transitionImageView == nil {
            print("transitionImageView is nil")
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFit
            transitionImageView.clipsToBounds = false
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
//        let blurEffect = UIBlurEffect(style: .extraLight)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//        blurView.frame = fromVC.tabBarController?.tabBar.frame ?? CGRect.zero
//        containerView.addSubview(blurView)

//
        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage ?? UIImage() , forView: toVC.view)
        
        toVC.view.layoutIfNeeded()
        print(finalTransitionSize)
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [UIView.AnimationOptions.transitionCrossDissolve],
                       animations: {
                        self.transitionImageView?.frame = finalTransitionSize
                        toVC.view.alpha = 1.0
                        fromVC.view.alpha = 1.0
                        fromVC.backGroundToolBar?.alpha = 1
                        fromVC.tabBarController?.tabBar.alpha = 0

        },
                       completion: { completed in
                        
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        self.transitionImageView?.alpha = 0.0
//                        blurView.removeFromSuperview()
                        self.transitionImageView?.removeFromSuperview()
                        self.transitionImageView = nil
                        fromVC.view.alpha = 1.0

                        
                        
                        transitionContext.completeTransition(true)
                        self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                        self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
        })
    }
    
    fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        self.fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        self.toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PhotoGridVC,
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)

            else {
                
                print("didnt find to vc")
                return
        }
        


        
        
        
        guard let fromReferenceImageView = self.fromDelegate?.referenceImageView(for: self),
        let toReferenceImageView = self.toDelegate?.referenceImageView(for: self),
        let fromReferenceImageViewFrame = self.fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
        let toReferenceImageViewFrame = self.toDelegate?.referenceImageViewFrameInTransitioningView(for: self) else {
                return
        }
        
        let referenceImage = fromReferenceImageView.image!
        
        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        fromReferenceImageView.isHidden = true
        toReferenceImageView.isHidden = true

        let finalTransitionSize = toReferenceImageViewFrame
        toVC.backGroundToolBar?.alpha = 1.0
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = fromVC.tabBarController?.tabBar.frame ?? CGRect.zero
        containerView.addSubview(blurView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {
                        fromVC.view.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
        }, completion: { completed in
            
            toVC.tabBarController?.tabBar.alpha = 1.0
            self.transitionImageView?.removeFromSuperview()
            toReferenceImageView.isHidden = false
            fromReferenceImageView.isHidden = false
            
            blurView.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
            self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
            
        })
    }
    
    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio > UIScreen.main.bounds.width - 2 ? UIScreen.main.bounds.width : view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2 < 1 ? 0 : view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return 0.45
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}


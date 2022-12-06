//
//  DynamicBehaviorViewController.swift
//  dynamic_behaviour
//
//  Created by Ilya Filinovich on 24.11.2022.
//

import UIKit

class DynamicBehaviorViewController: UIViewController {

    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: view)
        return animator
    }()
    lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        collision.collisionMode = .items
        return collision
    }()
    lazy var behavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 0.5
        behavior.resistance = 1000.0
        behavior.density = 1
        return behavior
    }()
    lazy var gravity: UIFieldBehavior = {
        let gravity = UIFieldBehavior.springField()
        gravity.strength = 0.008
        return gravity
    }()
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        return panGesture
    }()

    var snaps = [UISnapBehavior]()
    var circles = [CircleView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(panGesture)
        animator.setValue(true, forKey: "debugEnabled")
        addCircles()
        addBehaviors()

        collision.collisionDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gravity.position = view.center
        snaps.forEach {
            $0.snapPoint = view.center
        }
    }

    func addCircles() {
        (1...30).forEach { index in
            let xIndex = index % 2
            let yIndex: Int = index / 3
            let circle = CircleView(frame: CGRect(origin: CGPoint(x: xIndex == 0 ? CGFloat.random(in: (-300.0 ... -100)) : CGFloat.random(in: (500 ... 800)), y: CGFloat(yIndex) * 200.0), size: CGSize(width: 100, height: 100)))
            circle.backgroundColor = .red
            circle.text = "\(index)"
            circle.textAlignment = .center
            view.addSubview(circle)
            gravity.addItem(circle)
            collision.addItem(circle)
            behavior.addItem(circle)
            circles.append(circle)
        }
    }

    func addBehaviors() {
        animator.addBehavior(collision)
        animator.addBehavior(behavior)
        animator.addBehavior(gravity)
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        switch sender.state {
            case .began:
                animator.removeAllBehaviors()
                fallthrough
            case .changed:
                circles.forEach { $0.center = CGPoint(x: $0.center.x + translation.x, y: $0.center.y + translation.y)}
            case .possible, .cancelled, .failed:
                break
            case .ended:
                circles.forEach { $0.center = CGPoint(x: $0.center.x + translation.x, y: $0.center.y + translation.y)}
                addBehaviors()
            @unknown default:
                break
        }
        sender.setTranslation(.zero, in: sender.view)
    }
}

extension DynamicBehaviorViewController: UICollisionBehaviorDelegate {

}

final class CircleView: UILabel {

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .rectangle
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
    }
}

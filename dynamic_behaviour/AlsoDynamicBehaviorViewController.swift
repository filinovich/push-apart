//
//  ViewController2.swift
//  dynamic_behavior
//
//  Created by Ilya Filinovich on 25.11.2022.
//

import UIKit

class AlsoDynamicBehaviorViewController: UIViewController {

    var pinViews: [PinView2] {
        [
            .init(color: .red),
            .init(color: .black),
            .init(color: .green),
            .init(color: .red),
            .init(color: .black),
            .init(color: .green)
        ]
    }

    var allViews: [PinView2] = []

    lazy var animator: UIDynamicAnimator = {
        return $0
    }(UIDynamicAnimator(referenceView: view))

    let highDencityDynamicItemBehavior: UIDynamicItemBehavior = {
        $0.allowsRotation = false
        $0.elasticity = 0
//        $0.friction = 1000000
//        $0.density = 1000000
//        $0.resistance = .greatestFiniteMagnitude
        return $0
    }(UIDynamicItemBehavior())

    let mediumDencityDynamicItemBehavior: UIDynamicItemBehavior = {
        $0.allowsRotation = false
            //        $0.elasticity = 0
            //        $0.friction = 1000000
        $0.density = 1000
        $0.resistance = 1
        return $0
    }(UIDynamicItemBehavior())

    let lowDencityDynamicItemBehavior: UIDynamicItemBehavior = {
        $0.allowsRotation = false
            //        $0.elasticity = 0
            //        $0.friction = 1000000
        $0.density = 0.001
        $0.resistance = 1
        return $0
    }(UIDynamicItemBehavior())

    var snapBehaviors: [UISnapBehavior] = []

    let collisionBehavior: UICollisionBehavior = {
        $0.translatesReferenceBoundsIntoBoundary = true
        $0.action = {
            print("Action!")
        }
        return $0
    }(UICollisionBehavior())

    override func viewDidLoad() {
        super.viewDidLoad()

        addPins()
        addBehaviors()
        addButton()
        addSwitcher()

        collisionBehavior.collisionDelegate = self
    }

    lazy var button: UIButton = {
        $0.addTarget(self, action: #selector(addPins), for: .touchUpInside)
        $0.setTitleColor(.black, for: .normal)
        return $0
    }(UIButton())

    lazy var switcher: UISwitch = {
        return $0
    }(UISwitch(frame: .zero, primaryAction: UIAction { [weak self] state in
        guard let self else { return }

        self.toggleCollision(self.switcher.isOn)
    }))
}

extension AlsoDynamicBehaviorViewController: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        print(p)
    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {

    }


        // The identifier of a boundary created with translatesReferenceBoundsIntoBoundary or setTranslatesReferenceBoundsIntoBoundaryWithInsets is nil
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {

    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {

    }
}

private extension AlsoDynamicBehaviorViewController {

    @objc
    func addPins() {
        let views = pinViews

        views.enumerated().forEach {
            view.addSubview($0.element)
            $0.element.translatesAutoresizingMaskIntoConstraints = false
            $0.element.frame = CGRect(origin: .zero, size: $0.element.intrinsicContentSize)

//            $0.element.center = CGPoint(
//                x: view.center.x + CGFloat($0.offset) * 15,
//                y: view.center.y + CGFloat($0.offset) * 15
//            )

            let snapBehavior = UISnapBehavior(
                item: $0.element,
                snapTo: .init(
                    x: view.center.x + CGFloat($0.offset) * 15,
                    y: view.center.y + CGFloat($0.offset) * 15
                )
            )
            snapBehaviors.append(snapBehavior)
            animator.addBehavior(snapBehavior)
            collisionBehavior.addItem($0.element)
            switch $0.offset / 3 {
                case 0:
                    highDencityDynamicItemBehavior.addItem($0.element)
                case 1:
                    mediumDencityDynamicItemBehavior.addItem($0.element)
                case 2:
                    lowDencityDynamicItemBehavior.addItem($0.element)
                default:
                    break
            }
//            highDencityDynamicItemBehavior.addItem($0.element)
        }

        allViews.append(contentsOf: views)
    }

    func addBehaviors() {
        animator.addBehavior(highDencityDynamicItemBehavior)
        animator.addBehavior(mediumDencityDynamicItemBehavior)
        animator.addBehavior(lowDencityDynamicItemBehavior)
        animator.addBehavior(collisionBehavior)
    }

    func addButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("add pins", for: .normal)
        button.sizeToFit()
        button.center = .init(x: view.center.x, y: 150)
    }

    func addSwitcher() {
        view.addSubview(switcher)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.sizeToFit()
        switcher.center = .init(x: view.center.x, y: 250)
    }

    func toggleCollision(_ on: Bool) {
        switch on {
            case true:
                animator.addBehavior(collisionBehavior)

            case false:
                animator.removeBehavior(collisionBehavior)
        }
    }
}

class PinView2: UIView {

    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
    }

    override var intrinsicContentSize: CGSize {
        .init(width: 250, height: 330)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

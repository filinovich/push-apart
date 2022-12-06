//
//  PushApartViewController.swift
//  dynamic_behaviour
//
//  Created by Ilya Filinovich on 29.11.2022.
//

import UIKit

class PushApartViewController: UIViewController {

    var pins: [PinView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        addPins()
        addGesture()
    }

    override func viewDidLayoutSubviews() {
        pins.forEach {
            $0.center = $0.centerPoint
        }
    }
}

private extension PushApartViewController {

    func addPins() {
        pins.append(contentsOf: [
            .init(point: .init(x: 130, y: 200), color: .blue),
            .init(point: .init(x: 130, y: 300), color: .yellow, ignoreCollision: false),
            .init(point: .init(x: 140, y: 130), color: .systemPink, ignoreCollision: false),
            .init(point: .init(x: 135, y: 130), color: .green, ignoreCollision: false),
            .init(point: .init(x: 130, y: 330), color: .black),
            .init(point: .init(x: 50, y: 50), color: .red)
        ])

        pins.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 100),
                $0.heightAnchor.constraint(equalToConstant: 100)
            ])
            $0.center = $0.centerPoint
        }
    }

    func addGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    @objc
    func tap(sender: UITapGestureRecognizer) {
        print(sender.location(in: view))

        for view in pins {
            for other in pins {
                if view != other {
                    view.collide(with: other)
                }
            }
        }

        print(pins)
    }
}

// Collide with other box
class PinView: UIView {

    var centerPoint: CGPoint = .zero
    var ignoreCollision: Bool

    init(point: CGPoint, color: UIColor, ignoreCollision: Bool = false) {
        self.centerPoint = point
        self.ignoreCollision = ignoreCollision

        super.init(frame: .zero)

        backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var vx: CGFloat = 0
    var vy: CGFloat = 0
}

extension PinView {

    private enum MoveAxis {
        case vertical
        case horizontal
    }

    private enum HorizontalMoveDirection {
        case right
        case left
    }

    private enum VerticalMoveDirection {
        case up
        case down
    }

    private enum MoveDirection {
        case right
        case left
        case up
        case down
    }

    private enum MovementQuantity {
        case none
        case equal
        case twice

        var selfMovementCoefficient: CGFloat {
            switch self {
                case .none:
                    return 0
                case .equal:
                    return 1
                case .twice:
                    return 2
            }
        }

        var otherMovementCoefficient: CGFloat {
            switch self {
                case .none:
                    return 2
                case .equal:
                    return 1
                case .twice:
                    return 0
            }
        }
    }

    // Выставляет у пина origin. И записывает ему движение VX,VY
    func collide(with other: PinView) {
        let intersection = frame.intersection(other.frame)
        let selfMovement: MovementQuantity = {
            if ignoreCollision == other.ignoreCollision {
                return .equal
            } else {
                return ignoreCollision ? .none : .twice
            }
        }()

        func moveDirection() -> MoveDirection {
            intersection.height > intersection.width
            ? (intersection.origin.x < frame.origin.x + frame.size.width / 2) ? .right : .left
            : (intersection.origin.y < frame.origin.y + frame.size.height / 2) ? .up : .down
        }

        if (!CGRectIsNull(intersection)) {
            let rvx: CGFloat = 0//((vx + other.vx) / 2)
            let rvy: CGFloat = 0//((vy + other.vy) / 2)
            let horizontalMove = (intersection.width / 2).rounded(.up)
            let verticalMove = (intersection.height / 2).rounded(.up)
            let selfHorizontalMove = selfMovement.selfMovementCoefficient * horizontalMove
            let otherHorizontalMove = selfMovement.otherMovementCoefficient * horizontalMove
            let selfverticalMove = selfMovement.selfMovementCoefficient * verticalMove
            let otherVerticalMove = selfMovement.otherMovementCoefficient * verticalMove

            switch moveDirection() {
                case .up:
                    frame.origin.y += selfverticalMove
                    vy = rvy * selfMovement.selfMovementCoefficient
                    other.frame.origin.y -= otherVerticalMove
                    other.vy = -rvy * selfMovement.otherMovementCoefficient

                case .down:
                    frame.origin.y -= selfverticalMove
                    vy = -rvy * selfMovement.selfMovementCoefficient
                    other.frame.origin.y += otherVerticalMove
                    other.vy = rvy * selfMovement.otherMovementCoefficient

                case .right:
                    frame.origin.x = frame.origin.x + selfHorizontalMove
                    vx = rvx * selfMovement.selfMovementCoefficient
                    other.frame.origin.x -= otherHorizontalMove
                    other.vx = -rvx * selfMovement.otherMovementCoefficient

                case .left:
                    frame.origin.x -= selfHorizontalMove
                    vx = -rvx * selfMovement.selfMovementCoefficient
                    other.frame.origin.x += otherHorizontalMove
                    other.vx = rvx * selfMovement.otherMovementCoefficient
            }
        }
    }
}


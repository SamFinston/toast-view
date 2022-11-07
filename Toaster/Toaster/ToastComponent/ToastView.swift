//
//  ToastView.swift
//  Toaster
//
//  Created by Sam Finston on 11/4/22.
//

import UIKit

public class ToastView: UIView {
    
    // constants
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
        static let textPadding: CGFloat = 2
        static let fontSize: CGFloat = 16
        static let cornerRadius: CGFloat = 24
        
        static let animationDuration: CGFloat = 0.25
        static let bottomMargin: CGFloat = 64
        static let horizontalMargin: CGFloat = 32
        static let viewTimeOut: CGFloat = 4
        
        static let shadowOpacity: Float = 0.25
        static let shadowRadius: CGFloat = 5
    }
    
    // structs

    struct ViewModel {
        let image: UIImage?
        let title: String?
        let message: String
        let cta: InlineButton?
    }
    
    struct InlineButton {
        let text: String
        let action: () -> Void
    }
    
    // fields
    
    let viewModel: ViewModel
    let parentView: UIView
    let dynamicWidth: Bool
    var bottomConstraint: NSLayoutConstraint?
    
    // subviews
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .bold)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        return button
    }()
    
    // initializers
    
    init(viewModel: ViewModel, parentView: UIView, dynamicWidth: Bool = false) {
        self.viewModel = viewModel
        self.parentView = parentView
        self.dynamicWidth = dynamicWidth
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        isOpaque = true
        backgroundColor = .black
        
        configureSubviews()
        configureSwipeGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// public functions
public extension ToastView {
    
    // adds toast to the parent view with an animation
    func display() {
        
        // configure view
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        bottomConstraint = self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: self.frame.height)
        
        bottomConstraint?.isActive = true
        parentView.layoutIfNeeded()
        
        // animate entry
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.bottomConstraint?.constant = -Constants.bottomMargin
            self.parentView.layoutIfNeeded()
        }, completion: { _ in
            // hide the view after specified amount of time
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.viewTimeOut) {
                self.hide()
            }
        })
    }
    
    // removes toast from the parent view with an animation
    func hide() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.bottomConstraint?.constant = self.frame.height
            self.parentView.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

// private functions
private extension ToastView {
    
    // adds swipe down gesture
    func configureSwipeGesture() {
        isUserInteractionEnabled = true
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeRecognizer.direction = .down
        addGestureRecognizer(swipeRecognizer)
    }
    
    // hides view on swipe down
    @objc func onSwipe() {
        hide()
    }
    
    // applies viewModel and constraints to subviews
    func configureSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // image configuration
        if let image = viewModel.image {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image
            addSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding).isActive = true
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        // text configuration
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.spacing = Constants.textPadding
        textStack.axis = .vertical
        addSubview(textStack)
        textStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        if viewModel.image == nil {
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding).isActive = true
        } else {
            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.horizontalPadding).isActive = true
        }
        
        if let titleText = viewModel.title {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = titleText
            textStack.addArrangedSubview(titleLabel)
        }
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = viewModel.message
        textStack.addArrangedSubview(messageLabel)
        
        // height configuration
        topAnchor.constraint(equalTo: textStack.topAnchor, constant: -Constants.verticalPadding).isActive = true
        bottomAnchor.constraint(equalTo: textStack.bottomAnchor, constant: Constants.verticalPadding).isActive = true
        
        // button configuration
        if let cta = viewModel.cta {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(cta.text, for: .normal)
            button.addAction(UIAction(handler: { _ in
                cta.action()
                self.hide()
                }), for: .touchUpInside)
            button.titleLabel?.font = .systemFont(ofSize: Constants.fontSize, weight: .bold)
            addSubview(button)
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: Constants.horizontalPadding),
                button.centerYAnchor.constraint(equalTo: textStack.centerYAnchor),
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
            ])
            
        }
        
        // width configuration
        if dynamicWidth {
            let leadingContentAnchor = viewModel.image == nil ? textStack.leadingAnchor : imageView.leadingAnchor
            leadingAnchor.constraint(equalTo: leadingContentAnchor, constant: -Constants.horizontalPadding).isActive = true
            
            let trailingContentAnchor = viewModel.cta == nil ? textStack.trailingAnchor : button.trailingAnchor
            trailingAnchor.constraint(equalTo: trailingContentAnchor, constant: Constants.horizontalPadding).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Constants.horizontalMargin * 2).isActive = true
        }
        
        // add shadow
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOffset = .zero
    }
}

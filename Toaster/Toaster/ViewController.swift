//
//  ViewController.swift
//  Toaster
//
//  Created by Sam Finston on 11/4/22.
//

import UIKit

class ViewController: UIViewController {
    
    // values for creating toast view
    
    // title will be hidden if field left empty
    var toastTitle: String = "Title"
    // message will be set to "default" if field left empty
    var toastMessage: String = "message goes here"
    // button will be hidden if field left empty
    var buttonText: String = "button"
    // toggles bell icon
    var showImage: Bool = true
    // adjusts toast to width of its content if true
    var dynamicWidth: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // toast customization form
        
        let titleField = UITextField()
        titleField.clearButtonMode = .always
        titleField.borderStyle = .line
        titleField.text = toastTitle
        titleField.tag = 0
        titleField.addTarget(self, action: #selector(onTextChange), for: .editingChanged)
        
        let messageField = UITextField()
        messageField.clearButtonMode = .whileEditing
        messageField.borderStyle = .line
        messageField.text = toastMessage
        messageField.tag = 1
        messageField.addTarget(self, action: #selector(onTextChange), for: .editingChanged)
        
        let buttonField = UITextField()
        buttonField.clearButtonMode = .always
        buttonField.borderStyle = .line
        buttonField.text = buttonText
        buttonField.tag = 2
        buttonField.addTarget(self, action: #selector(onTextChange), for: .editingChanged)
        
        let imageLabel = UILabel()
        imageLabel.text = "show image"
        let imageToggle = UISwitch()
        imageToggle.tag = 3
        imageToggle.isOn = showImage
        imageToggle.addTarget(self, action: #selector(onToggle), for: .valueChanged)
        let imageForm = UIStackView(arrangedSubviews: [imageLabel, imageToggle])
        
        let widthLabel = UILabel()
        widthLabel.text = "dynamic width"
        let widthToggle = UISwitch()
        widthToggle.tag = 4
        widthToggle.isOn = dynamicWidth
        widthToggle.addTarget(self, action: #selector(onToggle), for: .valueChanged)
        let widthForm = UIStackView(arrangedSubviews: [widthLabel, widthToggle])
        
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("toast!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
        
        let formStack = UIStackView(arrangedSubviews: [titleField, messageField, buttonField, imageForm, widthForm, button])
        formStack.translatesAutoresizingMaskIntoConstraints = false
        formStack.axis = .vertical
        formStack.spacing = 8
        formStack.alignment = .fill
        
        view.addSubview(formStack)
        
        NSLayoutConstraint.activate([
            formStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            formStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            formStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
    }
}

// input handlers
private extension ViewController {
    // sets corresponding text variable on text field edit
    @objc private func onTextChange(_ sender: UITextField) {
        switch sender.tag {
        case 0:
            toastTitle = sender.text ?? ""
        case 1:
            toastMessage = sender.text ?? ""
        case 2:
            buttonText = sender.text ?? ""
        default:
            return
        }
    }
    
    // sets corresponding boolean variable on toggle press
    @objc private func onToggle(_ sender: UISwitch) {
        switch sender.tag {
        case 3:
            showImage = sender.isOn
        case 4:
            dynamicWidth = sender.isOn
        default:
            return
        }
    }
    
    // creates and displays a toast view based on current form entry
    @objc private func onButtonTap(_ sender: UIButton) {
        let image = UIImage(systemName: "bell")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let button = ToastView.InlineButton(text: buttonText, action: {
            print("button pressed!")
        })
        
        let viewModel = ToastView.ViewModel(image: showImage ? image : nil,
                                            title: toastTitle.isEmpty ? nil : toastTitle,
                                            message: toastMessage.isEmpty ? "default" : toastMessage,
                                            cta: buttonText.isEmpty ? nil : button)
        
        let toast = ToastView(viewModel: viewModel, parentView: self.view, dynamicWidth: dynamicWidth)
        toast.display()
    }
}


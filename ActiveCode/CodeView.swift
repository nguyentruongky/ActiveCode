//
//  CodeView.swift
//  ActiveCode
//
//  Created by Ky Nguyen on 5/23/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

var defaultFontSize: CGFloat = 40

struct Color {
    static let currentColor = UIColor.blackColor()
    static let activeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
    static let inactiveColor = UIColor.lightGrayColor()
}

class CharacterView: UIView {
    
    private var codeLabel : UILabel!
    private var underlineView: UIView!
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCode()
        setupUnderline()
    }
    
    func activate() { changeStateWithColor(Color.activeColor) }
    
    func deactivate() { changeStateWithColor(Color.inactiveColor) }
    
    func markEntered() { changeStateWithColor(Color.currentColor) }
    
    func changeCodeWithString(string: String) { codeLabel.text = string }
    
    private func setupCode() {
        
        codeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        codeLabel.font = UIFont.systemFontOfSize(defaultFontSize)
        codeLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(codeLabel)
    }
    
    private func setupUnderline() {
        underlineView = UIView(frame: CGRect(
            x: codeLabel.frame.origin.x,
            y: codeLabel.frame.origin.y + codeLabel.frame.height + 4,
            width: codeLabel.frame.width,
            height: codeLabel.frame.width / 10))
        underlineView.backgroundColor = Color.inactiveColor
        self.addSubview(underlineView)
    }
    
    private func changeStateWithColor(color: UIColor) { codeLabel.textColor = color; underlineView.backgroundColor = color; }
}

class CodeView: UIView, UITextFieldDelegate {

    var validateCode: ((String) -> ())?
    var codeCharacter : String!
    var numberOfCharacter : Int {
        get { return _numberOfCharacter }
        
        set(value) {
            _numberOfCharacter = value
            characterViews.removeAll()
            for v in subviews {
                v.removeFromSuperview()
            }
            setupView()
        }
    }
    
    private var _numberOfCharacter = 4
    private var characterViews = [CharacterView]()
    private var horizontalSpacing: CGFloat = 16
    private var codeField = UITextField()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(frame: CGRect, numberOfCharacter: Int) {
        
        self.init(frame: frame)
        self.numberOfCharacter = numberOfCharacter
    }

    func enterCode() {
        codeField.becomeFirstResponder()
    }
    
    private func setupView() {
        
        setupCodeField()
        let value = calculateSizeForScreenBaseOnWidth(frame.width, numberOfCharacter: numberOfCharacter)
        let horizontalSpacing: CGFloat = value.spacing
        let characterSize = value.chracterSize
        var labelX = calculateFirstLabelXBaseOnLabelWidth(characterSize.width,
                                                          viewWidth: frame.width,
                                                          numberOfCharacter: numberOfCharacter,
                                                          horizontalSpacing: horizontalSpacing)
        
        for _ in 0 ..< numberOfCharacter {
            addSubview(createCharacterViewWithSize(characterSize, atX: labelX))
            labelX += horizontalSpacing + characterSize.width
        }
        
        activeCodeAtIndex(0)
    }
    
    private func setupCodeField() {
        codeField.delegate = self
        addSubview(codeField)
        codeField.becomeFirstResponder()
        codeField.autocorrectionType = UITextAutocorrectionType.No
        codeField.autocapitalizationType = UITextAutocapitalizationType.None
    }
    
    private func calculateSizeForScreenBaseOnWidth(viewWidth: CGFloat, numberOfCharacter: Int) -> (chracterSize: CGSize, spacing: CGFloat) {
        
        let baseSize = calculateSizeBaseOnFontSize(defaultFontSize)
        if viewWidth / CGFloat(numberOfCharacter) > baseSize.width + horizontalSpacing { return (baseSize, horizontalSpacing) }
        
        horizontalSpacing -=  horizontalSpacing > 8 ? 2 : 0
        defaultFontSize -= 4
        return calculateSizeForScreenBaseOnWidth(viewWidth, numberOfCharacter: numberOfCharacter)
    }
    
    private func calculateFirstLabelXBaseOnLabelWidth(width: CGFloat,
                                              viewWidth: CGFloat,
                                              numberOfCharacter: Int,
                                              horizontalSpacing spacing: CGFloat) -> CGFloat {
        
        var labelX: CGFloat = width * CGFloat(numberOfCharacter)
        labelX += spacing * CGFloat(numberOfCharacter - 1)
        labelX = (viewWidth - labelX) / 2
        return labelX
    }
    
    private func calculateSizeBaseOnFontSize(fontSize: CGFloat) -> CGSize {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(fontSize)
        label.text = "0"
        label.sizeToFit()
        return CGSize(width: label.frame.width + 8, height: label.frame.height + 4)
    }
    
    private func createCharacterViewWithSize(size: CGSize, atX x: CGFloat) -> CharacterView {
        let newFrame = CGRect(x: x, y: 0,
                              width: size.width + 4, height: size.height)
        let characterView = CharacterView(frame: newFrame)
        characterViews.append(characterView)
        return characterView
    }
    
    private func activeCodeAtIndex(index: Int, withString string: String) {
        let character = characterViews[index]
        character.changeCodeWithString(string.uppercaseString)
        character.activate()
        deactivateCodeAtIndex(index - 1)
    }
    
    private func deactivateCodeAtIndex(index: Int) {
        guard index >= 0 && index < characterViews.count else { return }
        characterViews[index].deactivate()
    }
    
    private func activeCodeAtIndex(index: Int) {
        
        guard index >= 0 && index < characterViews.count else { return }
        let character = characterViews[index]
        character.activate()
    }

    private func markCodeEntered(index: Int) {
        guard index >= 0 && index < characterViews.count else { return }
        let character = characterViews[index]
        character.markEntered()
    }
    
    private func enterCodeAtIndex(index: Int, withString string: String) {
        let newString = codeCharacter != nil ? codeCharacter : string
        characterViews[index].changeCodeWithString(newString)
        activeCodeAtIndex(index + 1)
        markCodeEntered(index)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let codeLength = textField.text!.characters.count
        // delete character
        guard string.isEmpty == false && range.length != 1 else {
            characterViews[codeLength - 1].changeCodeWithString(string)
            activeCodeAtIndex(codeLength - 1)
            deactivateCodeAtIndex(codeLength)
            return true
        }
        
        // enter new character
        guard codeLength < characterViews.count else { return false }
        enterCodeAtIndex(codeLength, withString: string)
        
        // validate code
        if codeLength + 1 == characterViews.count {
            let code = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            textField.text = code
            if let validateCode = validateCode {
                validateCode(code)
            }
            return false 
        }
        
        return true
    }
}



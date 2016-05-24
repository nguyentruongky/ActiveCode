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
    
    static let activeColor = UIColor.darkGrayColor()
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
    
    func activate() { changeStateWithColor(Color.activeColor) }
    
    func deactivate() { changeStateWithColor(Color.inactiveColor) }
    
    private func changeStateWithColor(color: UIColor) { codeLabel.textColor = color; underlineView.backgroundColor = color; }
    
    func changeCodeWithString(string: String) { codeLabel.text = string }
}

class CodeView: UIView, UITextFieldDelegate {

    var characterViews = [CharacterView]()
    var horizontalSpacing: CGFloat = 16
    var codeField = UITextField()
    var validateCode: ((String) -> ())?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    convenience init(frame: CGRect, numberOfCharacter: Int) {
        
        self.init(frame: frame)
        setupCodeField()
        
        let value = calculateSizeForScreenBaseOnWidth(frame.width, numberOfCharacter: numberOfCharacter)
        let horizontalSpacing: CGFloat = value.spacing
        let characterSize = value.chracterSize
        var labelX = calculateFirstLabelXBaseOnLabelWidth(characterSize.width,
                                                          viewWidth: frame.width,
                                                          numberOfCharacter: numberOfCharacter,
                                                          horizontalSpacing: horizontalSpacing)
        
        for _ in 0 ..< numberOfCharacter {
            self.addSubview(createCharacterViewWithSize(characterSize, atX: labelX))
            labelX += horizontalSpacing + characterSize.width
        }
        
        activeCodeAtIndex(0)
    }
    
    private func setupCodeField() {
        codeField.delegate = self
        self.addSubview(codeField)
        codeField.becomeFirstResponder()
        codeField.autocorrectionType = UITextAutocorrectionType.No
        codeField.autocapitalizationType = UITextAutocapitalizationType.None
    }
    
    
    func calculateSizeForScreenBaseOnWidth(viewWidth: CGFloat, numberOfCharacter: Int) -> (chracterSize: CGSize, spacing: CGFloat) {
        
        let baseSize = calculateSizeBaseOnFontSize(defaultFontSize)
        if viewWidth / CGFloat(numberOfCharacter) > baseSize.width + horizontalSpacing { return (baseSize, horizontalSpacing) }
        
        horizontalSpacing -=  horizontalSpacing > 8 ? 2 : 0
        defaultFontSize -= 4
        return calculateSizeForScreenBaseOnWidth(viewWidth, numberOfCharacter: numberOfCharacter)
    }
    
    func calculateFirstLabelXBaseOnLabelWidth(width: CGFloat,
                                              viewWidth: CGFloat,
                                              numberOfCharacter: Int,
                                              horizontalSpacing spacing: CGFloat) -> CGFloat {
        
        var labelX: CGFloat = width * CGFloat(numberOfCharacter)
        labelX += spacing * CGFloat(numberOfCharacter - 1)
        labelX = (viewWidth - labelX) / 2
        return labelX
    }
    
    func calculateSizeBaseOnFontSize(fontSize: CGFloat) -> CGSize {
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
    
    func activeCodeAtIndex(index: Int, withString string: String) {
        let character = characterViews[index]
        character.changeCodeWithString(string.uppercaseString)
        character.activate()
        deactivateCodeAtIndex(index - 1)
    }
    
    func deactivateCodeAtIndex(index: Int) {
        guard index >= 0 && index < characterViews.count else { return }
        characterViews[index].deactivate()
    }
    
    func activeCodeAtIndex(index: Int) {
        
        guard index >= 0 && index < characterViews.count else { return }
        let character = characterViews[index]
        character.activate()
    }

    func enterCodeAtIndex(index: Int, withString string: String) {
        characterViews[index].changeCodeWithString(string)
        activeCodeAtIndex(index + 1)
        deactivateCodeAtIndex(index)
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
            print("validate code \(code)")
            if let validateCode = validateCode {
                
                validateCode(code)
            }
        }
        
        return true
    }
}



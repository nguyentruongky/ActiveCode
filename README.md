#Code Input View

####Purpose 
Create a code input view to validate when forgot password or activate to complete registration. Try it now. 

![](http://g.recordit.co/E7AVZubaOT.gif)

####Requirement 
- Dynamic number of character, maybe 6 or 8, maximum is 12. 
- Active the current character underline. 
- Auto active/validate when enter enough character. 

####Idea
- Create a custom view named `CharacterView` to display a code character with underline. 
- Create an array of `CharacterView` with the number of character base on demand. 
- Calculate and decrease the font size, the distance between 2 views to make sure all characters will be displayed at the center of the screen. 

Let's do it. 
####Character View 
The character view includes 2 elements: 1 label for code and 1 view for underline. 

Setup the code label and underline view 

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
    
There are some errors here. 

- The `defaultFontSize` is a global variable, it'll be changed base on the number of characters. 
- The `Color.inactiveColor` is a static variable, you can change any color you want. 

The character view has active, inactive states. These methods to do that. 

	func activate() { 
		changeStateWithColor(Color.activeColor) 
	}
    func deactivate() { 
    	changeStateWithColor(Color.inactiveColor) 
    }
    private func changeStateWithColor(color: UIColor) { 
    	codeLabel.textColor = color; - 
    	underlineView.backgroundColor = color; 
    }
    
And another method to change to string in code label. 

	func changeCodeWithString(string: String) { 
		codeLabel.text = string 
	}
	
####Code View 
The code view will have some variables: 

- `characterViews : [CharacterView]`:  An array of character views. 
- `horizontalSpacing: CGFloat`: the spacing between 2 characters. 
- `codeField : UITextField`: A hidden textfield, the code will be enter directly here and parse to character view. 
- `validateCode: ((String) -> ())?`: a method will be executed when the code enter completely.

Initialize the view

	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    convenience init(frame: CGRect, numberOfCharacter: Int) {
        self.init(frame: frame)
        setupCodeField()
        let value = calculateSizeForScreenBaseOnWidth(frame.width, numberOfCharacter: numberOfCharacter)
        let horizontalSpacing: CGFloat = value.spacing
        let baseSize = value.baseSize
        var labelX = calculateFirstLabelXBaseOnLabelWidth(baseSize.width,
                                                          viewWidth: frame.width,
                                                          numberOfCharacter: numberOfCharacter,
                                                          horizontalSpacing: horizontalSpacing)
        
        for _ in 0 ..< numberOfCharacter {
            self.addSubview(createCharacterViewWithSize(baseSize, atX: labelX))
            labelX += horizontalSpacing + baseSize.width
        }
        
        activeCodeAtIndex(0)
    }

We have to setup the hidden textfield. Don't forget conform UITextFieldDelegate

    private func setupCodeField() {
        codeField.delegate = self
        self.addSubview(codeField)
        codeField.becomeFirstResponder()
        codeField.autocorrectionType = UITextAutocorrectionType.No
        codeField.autocapitalizationType = UITextAutocapitalizationType.None
    }
We have to calculate the character size and font size base on the code view and number of character. For example: with 6-character-code, the font size can be 40+pt and the horizontal spacing is 16. But with 12-character-code, we can't do that. The font size has to be decreased. This is a recursion method to find the suitable size. 

	func calculateSizeForScreenBaseOnWidth(viewWidth: CGFloat, numberOfCharacter: Int) -> (chracterSize: CGSize, spacing: CGFloat) {
        
        let baseSize = calculateSizeBaseOnFontSize(defaultFontSize)
        if viewWidth / CGFloat(numberOfCharacter) > baseSize.width + horizontalSpacing { return (baseSize, horizontalSpacing) }
        
        horizontalSpacing -=  horizontalSpacing > 8 ? 2 : 0
        defaultFontSize -= 4
        return calculateSizeForScreenBaseOnWidth(viewWidth, numberOfCharacter: numberOfCharacter)
    }
This method returns a tuple with the character view size and the horizontal spacing between 2 character views.

Next, we have to calculate the x coordinate for the first character view. 
	
	func calculateFirstLabelXBaseOnLabelWidth(width: CGFloat,
                                              viewWidth: CGFloat,
                                              numberOfCharacter: Int,
                                              horizontalSpacing spacing: CGFloat) -> CGFloat {
        
        var labelX: CGFloat = width * CGFloat(numberOfCharacter)
        labelX += spacing * CGFloat(numberOfCharacter - 1)
        labelX = (viewWidth - labelX) / 2
        return labelX
    }

And the most important method is the textfield delegate. 

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
    
We have to handle the delete key, when input new character, when fill all characters and execute `validateCode` method. 

- Delete key: clear text, activate the current character and deactivate the previous character view. Make sure your character index will not out of index. View detail in the sample project. 
- Add new character: add text to current character, active next character. 
- Auto execute the method: check the count of character, use `stringByReplacingCharactersInRange` to create new text and execute the method. 

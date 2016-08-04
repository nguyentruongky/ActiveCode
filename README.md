#Code Input View

####Purpose 
Create a code input view to validate when forgot password or activate to complete registration. Try it now. 

![](http://recordit.co/kAuVq0Gs3V.gif)

####Requirement 
- Dynamic number of character, maybe 6 or 8, maximum is 12. 
- Active the current character underline. 
- Auto active/validate when enter enough character. 

####Idea
- Create a custom view named `CharacterView` to display a code character with underline. 
- Create an array of `CharacterView` with the number of character base on demand. 
- Calculate and decrease the font size, the distance between 2 views to make sure all characters will be displayed at the center of the screen. 

####How to use 

- Copy the `CodeView.swift` to your project
- Use 1 of 3 ways: 

	a. Change subclass on IB
	
	b. Add programmatically with init(frame)
	
	c. Add programmatically with init(frame:numberOfCharacter)

- Change the number of character (default is 4)

		codeView.numberOfCharacter = 6
- Change the code character (default is the character you typed)

		codeView.codeCharacter = "•"

- Add `validateCode` method 

		codeView.validateCode = { (code) in
		            let alert = UIAlertController(title: "Active Code", message: "Your code is \(code)", preferredStyle: .Alert)
		            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
		            alert.addAction(defaultAction)
		            self.presentViewController(alert, animated: true, completion: nil)
		        }

- You can change the underline color in struct `Color` in `CodeView.swift`

####Improvement 
- The code doesn't work good on iPhone 6+, the font size is a little small. 
- The recursion code makes the performance down a lot. 

<h1>RLTextField</h1>
<p>
  A custom iOS TextField.
</p>

![screenshot1](https://user-images.githubusercontent.com/18121897/76358454-d8aacf00-62ef-11ea-9cc7-ecffeea0b20f.gif)
![screenshot2](https://user-images.githubusercontent.com/18121897/76358463-dcd6ec80-62ef-11ea-9cb8-bf56730c7b39.gif)


<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Installation](#installation)
* [Usage](#usage)
  * [How to: Import](#to-import)
  * [How to: Add](#to-add)
  * [How to: Add Validation](#to-add-validation)
  * [How to: Disable Validation](#to-disable-validation)
  * [How to: Hide Input](#to-hide-input)
  * [How to: Dismiss Keyboard](#to-dismiss-keyboard)
  * [How to: Manage Colors](#to-manage-colors)
  * [How to: Hide Input](#to-hide-input)
* [License](#license)

<!-- GETTING STARTED -->
## Installation

Use Swift Package Manager (SPM) to install this dependency into your iOS project. 

In Xcode, go to File->Swift Packages->Add Package Dependency and paste the following dependency URL into the search bar:

```sh
https://github.com/thecht/RLTextField.git
```

## Usage

#### To import:

```sh
import RLTextField
```
#### To add:
```sh
var newTextField = RLTextField(placeholderText: "USERNAME")
parentView.addSubview(newTextField)
NSLayoutConstraint.activate([*insert constraints here*])
```

#### To add validation:

```sh
newTextField.addValidation(errorMessage: "Requires 4+ Characters") { (input) -> Bool in
  if input.count >= 4 {
    return true
  } else {
    return false
  }
}
```

To change colors on successful input, set enableSuccessColors to true. 

```sh
myTextField.enableSuccessColors = true
```

Note that error colors will be activated automatically if a validation handler is added and incorrect user input is entered. (NOTE: To change success/error colors, see 'managing colors' below.)

#### To disable validation:

By default, validation will only happen if you add validation handlers to your RLTextField. (See 'To add validation' above). If you want to enable/disable validation, set the useValidation property.

```sh
newTextField.useValidation = false
```

#### To hide input:

To hide user input (in case of passwords), enable the isSecureTextEntry property.

```sh
newTextField.isSecureTextEntry = true
```

#### To dismiss keyboard:

RLTextField has a UITextFieldDelegate property, allowing you to respond to text field events just like a normal UITextField.

To dismiss the keyboard, set the RLTextField's delegate property to an object which implements UITextFieldDelegate, and call the RLTextField's endEditing() method in delegate methods like textFieldShouldReturn or textFieldDidEndEditing. 

```sh
newTextField.delegate = SomeUITextFieldDelegateClass()
```

```sh
extension SomeUITextFieldDelegateClass: UITextFieldDelegate {

  func textFieldDidEndEditing(_ textField: UITextField) {
      usernameTextField.endEditing()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      newTextField.endEditing()
      return true
  }
}
```

To ensure proper functionality on a form with multiple RLTextFields, you'll want to make sure the endEditing method is called on the textfield(s) you aren't editing when you begin editing a new one. However, the textfield you get from UITextField delegate is an internal UITextField of an RLTextField object, not an RLTextField itself. So to get the RLTextField an internal UITextField belongs to, you can pass in the UITextField to RLTextField's static getRLTextField(from: [RLTextField], containingInternalUITextField: UITextField). The runtime complexity of this method is O(N), but in practice, you probably wont have very many textfields on a single screen at one time, so performance shouldn't be an issue.

```sh
extension SomeUITextFieldDelegateClass: UITextFieldDelegate {

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      guard let tf = RLTextField.getRLTextField(from: [myTextField, mySecondTextField], containingInternalUITextField: textField) else { return false }

      if tf !== myTextField {
          myTextField.endEditing()
      }

      if tf !== passwordTextField {
          mySecondTextField.endEditing()
      }

      return true
  }
}
```

#### To manage colors:

RLTextField exposes all of its color properties, which can be set however you like.

* primaryBorderColor
* secondaryBorderColor
* errorColor
* successColor
* primaryBackgroundColor
* secondaryBackgroundColor
* primaryTextColor
* secondaryTextColor
* cancelButtonColor

## License

Coming Soon

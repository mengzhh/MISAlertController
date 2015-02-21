MISAlertController
=============

If you want to use UIAlertController, but still need to support iOS 7 this project is for you.

MISAlertController is a wrapper around UIAlertController and UIAlertView / UIActionSheet. On iOS 7 MISAlertController uses UIAlertView or UIActionSheet and on iOS 8 it uses UIAlertController to show Alerts and Action Sheets.

MISAlertController uses ARC and supports iOS 7.0+

## Installing

MISAlertController can be installed by [CocoaPods](http://cocoapods.org). Simply add this line to your `Podfile`:
````
pod 'MISAlertController'
````

And run `pod install`.

Or just add the files from the MISAlertController folder to your project.

## Usage

First create a ``MISAlertController`` object

```
MISAlertController *alertController = [MISAlertController alertControllerWithTitle:@"Title" message:@"Message" preferredStyle:UIAlertControllerStyleActionSheet];
```

Second, create ``MISAlertAction`` objects

```
MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(MISAlertAction *action) {
    NSLog(@"Cancel");
}];

MISAlertAction *actionOne = [MISAlertAction actionWithTitle:NSLocalizedString(@"Action 1", nil) style:UIAlertActionStyleDefault handler:^(MISAlertAction *action) {
    NSLog(@"Action 1");
}];

MISAlertAction *actionTwo = [MISAlertAction actionWithTitle:NSLocalizedString(@"Action 2", nil) style:UIAlertActionStyleDefault handler:^(MISAlertAction *action) {
    NSLog(@"Action 2");
}];
```

Add actions to controller

```
[alertController addAction:cancelAction];
[alertController addAction:actionOne];
[alertController addAction:actionTwo];
```

Show the controller

```
// Show it from bottom on iPhone and centered on iPad in the view of view controller
// [alertController showInViewController:self animated:YES];

// Show from a source view, from the bottom on iPhone and via a popover on iPad
[alertController showFromSourceView:sender inViewController:self animated:YES];
```


Hide the controller

```
[alertController dismissViewControllerAnimated:YES completion:^{

}];
```

In the sample project you will find how to show an alert view via MISAlertController.

## Creator

[Michael Schneider](http://mischneider.net)
[@maicki](https://twitter.com/maicki)

## License

MISAlertController is available under the MIT license. See the LICENSE file for more info.

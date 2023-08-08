# image_captioner
 A Flutter/Dart Android app written by a noob for producing Text files (Captions/Annotations) against a folder of Pictures, with a view to support producing a valid Stable Diffusion Dataset for training

![image](https://github.com/graffight/image_captioner/assets/141745229/96c3ba0b-cd8b-4388-bd39-6c05ed39e69f)

# Notes
* The application will prompt you to create a directory that is has permissions to read/write from on first boot; since Android is dumb and won't let it access anywhere, even with the "Full Files Permission" toggle enabled.
* To make your folder of images available to the app:
  * When prompted to select a directory by the app, it will also prompt you to create a new directory. Create that directory
  * With the new (empty) directory created, come out of the app, and copy your dataset images into the new directory with something like Google Files or Total Commander etc
  * Re-open the app to load your directory of images.
  * You will then be able to sift through the images, and create captions/annotations as you go.
* There is no multi-select/batch operations support, or anything fancy really, but this was a decent first slice to learning Flutter/Dart.
* Text files are added next to the selected images, as ```<image_name>.txt```
* Though there is an iOS part to this project, it is unbuilt, and untested
* Currently using Android Studio "Giraffe" for development
* App is only in Dark Mode theme, because i'm too lazy to implement a toggle or anything fancy

# Wishlist for Future Features
* Fix the App Name being displayed as ```image_captioner``` in the Apps list. Should be nicer.
* Fix the App logo being the default Flutter Icon
* Display the images in a Grid (similar to a regular photo gallery app), and allow batch operations when selecting multiple (eg. Append a Prefix/Suffix tag // add/remove specific tag across all selected images etc)
* Still allow for viewing single images from the grid by selecting one, and then support next/previous as usual
* Make a note of common tags used during an annotation job, and provide auto-complete options and/or a selectable list of tags under the text input to save time
* Be able to read/write where we want, without stupid permissions getting in the way
* Support generating flipped versions of all images in a dataset, and handle the tagging of the flipped duplicates as part of a single process (ie. tags changed on one image should be reflected on the flipped image too, without showing both images to the end user)
* iOS app testing/build
* Github Actions for automated APK builds
* Publish to F-Droid
* Add some tests?
* Validate on multiple Android versions (currently only manually tested against Android 11 + 13)
* Review features of other applications (like <https://github.com/toshiaki1729/stable-diffusion-webui-dataset-tag-editor>) to see if other features would be good to port to mobile?
* See if there's any demand to build this out to a Desktop app for Windows/Mac/Browser from Flutter too?

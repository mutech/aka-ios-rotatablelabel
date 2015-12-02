# AKA Rotatable Label

## What is does

AKARotatableLabel is a UILabel sub class that supports rotations at multiples of 90º.

It looks like this (Animations are jumpy due to framerate or the animated gif):

![Demo](RotatableLabelDemo.gif)

An in interface builder:

![IB custom class](IB-custom-class.png)

and:

![IB properties](IB-properties.png)

## How to install

For the moment, just clone the framework from Github or copy the AKARotatableLabel.[mh] files to your project. If I see that there is more than one user asking I'll make a pod.

## What works and what doesn't

### Angles

The label only supports angles which are multiples of 90ºs. Other values will be rounded to meet this requirement.

### Autolayout

Works fine with autolayout, as long as the label's size is determined by it's intrinsic size. If you see problems, embed the label in a view and add &gt;= constraints (one or more for either horizontal and/or vertical sides), that should work fine.

### Animations

Changing the rotation angle in animations works ok-ish (Run the demo to see for yourself. There are some quirks, depends on what you're doing).

## How it works

I'm using two labels, the one that's actually rotated is a subview of the first. I'm using the container view so that you can setup the label using interface builder (with a UIView and IBInspectable properties you can't set fonts).

This is probably not the best way to do this and it can be done better, but it's basically doing the job I need it to do.

## Status

I only had the time to make the features work that I need just now. Will come back to this later.

The class will probably move to [AKACommons](https://github.com/mutech/aka-ios-commons)

## License

2-clause BSD, see LICENSE.txt

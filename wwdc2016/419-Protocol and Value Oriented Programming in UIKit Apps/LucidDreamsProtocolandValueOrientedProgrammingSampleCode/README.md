# Lucid Dreams

## Version
1.0

## Build Requirements
+ Xcode 8.0 or later
+ iOS 10.0 SDK or later

## Runtime Requirements
+ iOS 10.0 SDK or later

## About LucidDreams

LucidDreams is a sample that accompanies the "Protocol and Value Oriented Programming in UIKit Apps" WWDC 2016 session (#419). It's recommended that you watch the talk before looking at this sample. The app lets users log their dreams with detailed content like effects that occurred during the dream, creatures that they saw, and more.

This application demonstrates how you can take advantage of value types and protocol oriented programming in Cocoa applications. We have examples of using these approaches in the model, view, and controller (MVC) layers. This is important because Cocoa apps are built using the MVC design pattern. We focus on the view and controller layers in this application more than the model layer because the view and controller layers are the least commonly thought of place to take advantage of these techniques. In this sample we show that value types are just as powerful in the view and controller layers as in the model layer.

**note**: Some of these techniques may initially feel foreign. Don't worry——that's normal. It's a different way of thinking about how to solve certain kinds of problems.

Our goal for this sample is to make you think about how to architect the next solution to a problem you're having in code. If you're thinking about using classes with inheritance for customizing, think about using value types and composition instead. If your view controller has a lot of individual properties consider composing the properties into a value, i.e. your model and state properties, so that you can isolate the logic of that model into unit that can be tested and more easily reasoned about.

## Application Architecture

This app is grouped into Model, View, and Controller Xcode groups. Each of these Xcode groups maps one-to-one with the section in the WWDC session. A summary of each section is described below for convenience——the session goes more in depth about why these are important.

### Model

The main model type in the LucidDreams app is the `Dream` struct, a value type. The `Dream` type has a few nested types that are also value types: `Dream.Effect` and `Dream.Creature`. Because these types are value types we can test them in isolation; we don't need to worry if the dreams, effects, or creatures are being implicitly shared across the application. Note that because these are value types we are able to easily compose these values into other value types in our application, for example in the `Controller` section.

### View

In the LucidDreams app we use value types to handle layout of the content we display. The main reason we designed this system is because we wanted to reuse layout code between UIKit views, SpriteKit nodes, and image rendering. 

We defined a single `Layout` protocol (LucidDreams -> View -> Layout -> Layout.swift) to accomplish that. This protocol is the building block for our other primitive layout types like `InsetLayout`, `BackgroundLayout`, `ZStackLayout`, etc. These primitive layout types are generic on their underlying layout. These primitive layout types provide the abstraction that allows us to build more interesting layout types like `DecoratingLayout`, `MultiPaneLayout`, and `DreamEffectLayout`. All of these more complex layout types use composition with the primitive layout types in order to accomplish this.

All of these layout types are used by UIKit views, SpriteKit scenes, and image layout code to enable all of this code re-use. For some examples, see `CreatureCell`, `DreamCell`, and the `DreamScene` files.

### Controller

There are three view controllers in this application:

1) `DreamListViewController`: presents the user's list of dreams. This view controller isolates its state and model properties into a `State` enum value and a `Model` struct. In the WWDC session we describe how this was important to write a maintainable, single code path for our undo logic. Look specifically at the `withValues(...)` method that allows the view controller to mutate its state or model properties that coalesces all UI updates in the view controller.

2) `DreamDetailViewController`: allows the ability to edit a dream. The user sees this view controller when he/she taps on a dream from the `DreamListViewController`. Note the `withDream(...)` method that is similar to `DreamListViewController`'s `withValues(...)` that coalesces UI updates. This view controller uses the same approach except that it only does so for its model (it has no state properties).

3) `FavoriteCreatureListViewController`: displays a list of creatures that can be selected as a favorite creature. This view controller is very basic——it does not have any model properties. However, it does have a single model property: the currently selected favorite creature. Although its a smaller view controller we use the same approaches to state and model properties as we did in (1) and (2).

## Testing

We've added some unit tests to this sample to demonstrate how easy value types are to test since they have no dependencies. See the Swift files in the "Tests" Xcode group for more detailed descriptions of these tests.

Copyright (C) 2016 Apple Inc. All rights reserved.

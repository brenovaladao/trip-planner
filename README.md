# Trip Planner
```
 _        _        
| |_ _ __(_)_ __   
| __| '__| | '_ \  
| |_| |  | | |_) | 
 \__|_|  |_| .__/  
           |_|     
       _                             
 _ __ | | __ _ _ __  _ __   ___ _ __ 
| '_ \| |/ _` | '_ \| '_ \ / _ \ '__|
| |_) | | (_| | | | | | | |  __/ |   
| .__/|_|\__,_|_| |_|_| |_|\___|_|   
|_| 
```
![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![iOS](https://img.shields.io/badge/iOS-16+-cyan) ![Xcode](https://img.shields.io/badge/Xcode-15+-blue) [![CI - Build & Test](https://github.com/brenovaladao/trip-planner/actions/workflows/CI.yml/badge.svg)](https://github.com/brenovaladao/trip-planner/actions/workflows/CI.yml)


## Setup:

There is no extra `setup` step to be done, just be sure you have the correct Xcode version (Xcode 15+) installed.

The App downloads information from this base [url](https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/connections.json). If you want to use a different base URL, it can be done by updating the `API_URL` variable, defined at `Debug.xcconfig` (_TripPlanner/Configurations/Debug.xcconfig_). 
>  Note that we need the `/$()/` for escaping the `//`.

## Technical decisions:
- The App goal is to find the cheapest route between two cities (`Departure` and `Destination`) based on its accumulated price. To achieve such a result the `Dijkstra` algorithm was chosen.

- The App was almost fully built with `SwiftUI`, the only exception was the `AnnotationsMapView` components, which is a `UIViewRepresentable` that wraps an `MKMapView` for building the map UI. This decision was made given the limitation that `SwiftUI.Map` still has.

- In the current version of the App, I'm injecting the `URLSession` instance into the `FlightConnectionsService` directly. Ideally, I would create another component that is the interface of the `URLSession` in a more reusable way (`HTTPClient` generic component or similar), but given this app has only one single request to one endpoint, I decided that is fair to have it in this way. Later if a new endpoint comes it'll be time to refactor to a more reusable way.

- Currently, all requests hit the networking, ideally, we would also have a `cache` layer to avoid hitting the networking all the time.

- Given the simple nature of the app, I decided to have multiple `Published` properties as a public interface for the view, but one other approach would be to have a single `state` property for having a centralized place for performing mutations.

## Next steps / Improvements:

- Move Strings to a `.strings` file for handling localization properly.

- Define better styles for all UI components.

- Create an HTTPClient generic component for being the interface on top of `URLSession`.
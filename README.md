# drone-control
drone-control is iOS application made for everyone who wants to discover programming. The aim of the project is to build a programming interface with an interpreter and to create a DSL to write a flight plan to pilot a drone. 

## Getting Started

The application is for iOS and is build for Parrot Bebop 2 drone

### Prerequisites

drone-control requires the following materials and environments:

* macOS High Sierra
* An iPad with iOS 11.3 or higher
* Xcode version 9.3
* [Parrot Bebop 2 drone](https://www.parrot.com/fr/drones/parrot-bebop-2-fpv#parrot-bebop-2-fpv-details)


### Installing

To compile and use the application you have to:

* clone the repository
```
git clone https://github.com/cui-unige/drone-control.git

```
* open the Xcode project and verify [these fields](http://developer.parrot.com/docs/SDK3/#ios) are properly filled

The Samples folder and droneProgrammer folder must be in the same directory (if you cannot retrieve the Samples folder you can find it [here](https://developer.parrot.com/docs/SDK3/#use-samples))

The project contains all the elements of the [Parrot SDK3](http://developer.parrot.com/docs/SDK3/#general-information) we need to develop the application and also the Parrot library which contains all the settings of the drone 

## Documentation

The full documentation of the library is available [here](https://developer.parrot.com/docs/reference/bebop_2/index.html#bebop-2-reference)

[Here](http://developer.parrot.com/docs/SDK3/#start-coding) are the instruction about how to use the SDK to control the Bebop drone

The SDK is written in Objective C and the application code is written in Swift, so you can use the [Apple documentation](https://developer.apple.com/documentation) for these two languages and the Xcode concepts

All the other informations related to the application is commented in the code

## Author

Marvin Fourastié
Patrick Sardinha

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/cui-unige/drone-control/blob/issue%231/LICENSE) file for details

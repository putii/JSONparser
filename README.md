# JSONparser

> :warning: **IMPORTANT**: This project is currently under development and may not function as expected. Please check back later for updates.

JSONparser is a C++, functional implementation-to-be of JSON parser.

## Features

So far only implemented:
- Functor implementation
- JSON parser tree class

## Getting Started

### Prerequisites

- C++ compiler with support for C++20; tested on: 
  - gcc 13.2.0
- CMake 3.26 or higher.

### Building the Project

1. Clone the repository.
2. Navigate to the project directory.
3. Run `cmake --preset <chosen-preset-build-to-find-in-CMakePresets.json>` to generate the build files.
1. cd to root build directory
5. Run `cmake --build --target main` to build the main binary.
5. Run ```cmake --build --target testsTarget``` to build tests binary.

## Running the Tests

After building the project, you can run the tests by executing the test binary in the `test` directory.

## Contributing

Contributions are welcome. Please open an issue to discuss your proposed changes or create a pull request.


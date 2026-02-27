# PWHL Schedule Menu Bar App

A native macOS menu bar application that beautifully displays the Professional Women's Hockey League (PWHL) schedule.

Built entirely with Swift and SwiftUI, this lightweight app lives in your menu bar and dynamically fetches the latest rolling schedule. It displays past results, today's games, and upcoming matchups, and when a game goes live, the app visually transforms into the official PWHL dark purple!

## Features
- **Native Menu Bar App:** Operates silently in the menu bar with no dock icon to clutter your workspace.
- **Dynamic API Fetching:** Fetches from the official PWHL schedule endpoints, seamlessly transitioning through seasons.
- **Live Game Mode:** The application dynamically changes its background to deep PWHL purple (#33058D) when live hockey is happening.
- **Rich TV Network Data:** Displays granular "Where to Watch" information (e.g., TSN, MSG, SRC) so you know exactly what channel to tune into.
- **Timezone Aware:** Automatically converts all puck drops into your mac's local timezone.

## Prerequisites
- macOS 13.0 or later
- Xcode Command Line Tools. You can install these by opening your terminal and running:
  ```bash
  xcode-select --install
  ```

## Installation (Easiest Way)

For users who just want to run the app without building it from source:

1. Download the `[PWHLSchedule.zip](https://github.com/iChris/unofficial-pwhl-schedule-menubar/blob/main/PWHLSchedule.zip)` file from the repository.
2. Double-click the downloaded zip file to extract it.
3. Drag the extracted `PWHLSchedule.app` into your `Applications` folder.
4. Double-click the app to launch it!

*Note: Since this app isn't signed by an Apple Developer account, you may need to bypass macOS Gatekeeper the first time you open it. To do this, Right-Click (or Control-Click) the app and select "Open" from the context menu, then confirm you want to open it.*

## For Developers: How to Build from Source

This project leverages a simple `Makefile` so you can compile the entire application directly from the command line without opening Xcode!

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd PWHLSchedule
   ```

2. **Build the application:**
   ```bash
   make build
   ```
   *This command compiles the Swift sources and generates the `PWHLSchedule.app` bundle in the current directory.*

3. **Run the application:**
   ```bash
   open PWHLSchedule.app
   ```
   *(Alternatively, you can double-click the `PWHLSchedule.app` file in Finder.)*

Look for the hockey player icon (`figure.hockey`) in your macOS menu bar!

## Project Structure
- `Sources/`: Contains all the Swift and SwiftUI source code.
  - `PWHLApp.swift`: App lifecycle and MenuBarExtra setup.
  - `PWHLScheduleService.swift`: Handles network requests, background merging of TV networks, and state logic.
  - `PWHLModels.swift`: Codable JSON models mapping the HockeyTech API.
  - `ScheduleView.swift`: The SwiftUI visual layout.
- `Makefile`: Automates compiling the Swift code into the `.app` bundle.
- `Info.plist`: Application parameters, uniquely configured with `LSUIElement` set to `true` to ensure the app is purely a menu bar extra.

## Cleanup

To delete the generated compiled app bundle:
```bash
make clean
```

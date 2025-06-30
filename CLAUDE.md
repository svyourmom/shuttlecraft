# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Shuttlecraft is a macOS menu bar utility for managing sshuttle VPN connections. It's built with SwiftUI and runs as a pure menu bar application (no main window).

- Project Name: Shuttlecraft

## Development Commands

### Building and Running
- **Build**: Use Xcode to build the project (`Shuttlecraft.xcodeproj`)
- **Run**: Build and run from Xcode, or run the built app from Applications folder
- **Dependencies**: Requires `sshuttle` installed at `/opt/homebrew/bin/sshuttle` (install via `brew install sshuttle`)

### Testing
- Unit tests should be run through Xcode's test navigator or `Cmd+U`

## Architecture Overview

### App Structure
- **Entry Point**: `ShuttlecraftApp.swift` - Minimal SwiftUI App that delegates to AppDelegate
- **Core Logic**: `AppDelegate.swift` - ObservableObject managing menu bar, SSH connections, and app state
- **No Main Window**: App runs purely as menu bar utility with on-demand preferences window

### Key Components
- **Data Model**: `SSHHostConfig` - Codable struct representing SSH connection configurations with VPN mode support (Process objects managed separately)
- **State Management**: AppDelegate acts as single source of truth with `@Published` properties
- **Menu Bar Integration**: NSStatusItem with Star Trek themed text-based icons (△ disconnected, 🚀 connected, 🛡️ VPN mode)
- **Process Management**: Separate `activeProcesses` dictionary maps host UUIDs to Process instances

### SwiftUI Views
- **PreferencesView**: Modern Tahoe-style configuration interface with glass effects (.thinMaterial, .ultraThinMaterial, .regularMaterial) for managing SSH hosts (uses sheet(item:) for reliable edit functionality)
- **AddHostView**: Enhanced modal form with VPN mode toggle, NavigationStack, and modern form elements for adding/editing host configurations (dual-mode: add vs edit)
- **ContentView**: Currently unused (app has no main window)

### sshuttle Integration
- **Hardcoded Path**: `/opt/homebrew/bin/sshuttle` 
- **Output Parsing**: Real-time monitoring of sshuttle stdout/stderr for connection status
- **Command Building**: Dynamic argument construction based on host configuration, with VPN mode auto-configuring 0/0, ::/0 with DNS
- **Status Detection**: Pattern matching on sshuttle output to detect connected/error states

### Data Persistence
- **Storage**: UserDefaults with JSON encoding/decoding
- **Auto-save**: Changes to hostConfigurations automatically persist
- **State Recovery**: Processes reset to disconnected on app launch

## Key Implementation Details

### Connection Status Management
- Uses `ConnectionStatus` enum: disconnected, connecting, connected, error
- Visual feedback via menu item states and menu bar icon switching
- Real-time updates through ObservableObject pattern

### Memory Management
- Proper `[weak self]` usage in Process termination handlers
- Careful cleanup of Process instances and pipes

### Current Limitations
- sshuttle path is hardcoded to Homebrew location
- Limited error handling for edge cases

## macOS Integration
- **Menu Bar Only**: Set as accessory app (hidden from dock)
- **Compatibility**: Tested on macOS 15.5 (Sequoia/Tahoe/26)
- **Gatekeeper**: App requires manual approval on first launch
- **sudo Requirements**: sshuttle needs admin privileges for network changes
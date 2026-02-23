# 🚗 AutoPin - WatchOS Capstone Project

<div align="center">

![watchOS](https://img.shields.io/badge/watchOS-10.0+-blue?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-WatchOS-lightgrey?style=flat-square)

*A location-based personal item tracker for Apple Watch*

</div>

---

## 📱 Project Overview

### App Description

**AutoPin** is a productivity and personal organization WatchOS application that helps users save and retrieve the location of personal belongings such as bags, laptops, jackets, bikes, or parked cars. The app is designed specifically for short interactions, glanceable feedback, and hands-free usage, making it highly suitable for Apple Watch.

### Tagline

> *"Automatically remember where you parked or where you left important personal belongings — directly from your Apple Watch."*

---

## 🎯 Why This App Belongs on Apple Watch

| Feature | WatchOS Suitability |
|---------|-------------------|
| Quick Save | Save location in seconds without phone |
| Haptic Alerts | Immediate awareness through vibration |
| Wrist Navigation | Simple arrow-based guidance |
| Glanceable UI | Minimal UI optimized for small screens |

- ✅ **Short interaction time** - Complete tasks in under 10 seconds
- ✅ **Glanceable information** - Status visible at a glance
- ✅ **Simple user flows** - Minimal taps required
- ✅ **Hands-free options** - Siri voice commands available

---

## 👥 Target User

| User Type | Use Case |
|-----------|----------|
| Commuters | Remember where they parked |
| Travelers | Track belongings at airports/stations |
| Students | Remember lecture hall/bag locations |
| Anyone with memory challenges | Quick location recall |

---

## ✨ Features Implemented

### Core Features

| Feature | Description | Status |
|---------|-------------|--------|
| Save Location | One-tap GPS location saving | ✅ |
| View Items | List all saved locations | ✅ |
| Navigate | Arrow-based navigation to item | ✅ |
| Delete | Remove saved items | ✅ |
| Categories | Organize by item type | ✅ |
| Proximity Alerts | Notification when approaching item | ✅ |

### Advanced Features

| Feature | Description | Status |
|---------|-------------|--------|
| Movement Detection | Auto-detect when user stops | ✅ |
| Siri Integration | Voice commands | ✅ |
| Widget Complication | Quick glance at saved count | ✅ |
| Local Notifications | Meaningful timely alerts | ✅ |
| Haptic Feedback | Tactile response for actions | ✅ |

---

## 🏗️ Technical Architecture

### Apple Frameworks Used

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI                              │
│                   (UI Framework)                            │
├─────────────────────────────────────────────────────────────┤
│  SwiftData  │  CoreLocation  │  CoreMotion  │ WidgetKit    │
│   (Storage) │   (GPS)       │   (Motion)   │ (Complica.)  │
├─────────────────────────────────────────────────────────────┤
│              UserNotifications  │  AppIntents              │
│               (Local Alerts)    │  (Siri Shortcuts)        │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
AutoPin Watch App/
├── 📁 Views/
│   ├── HomeView.swift          # Main dashboard
│   ├── NewPinView.swift       # Save new location
│   ├── PinListView.swift       # List all items
│   ├── PinDetailView.swift     # Item details
│   └── NavigationView.swift    # Arrow navigation
│
├── 📁 Models/
│   └── SavedItemPin.swift      # Data model
│
├── 📁 Services/
│   ├── LocationService.swift   # GPS management
│   ├── MotionService.swift     # Movement detection
│   ├── NotificationService.swift # Alerts & haptics
│   └── PersistenceService.swift  # Data operations
│
├── 📁 Intents/
│   └── SaveItemIntent.swift    # Siri commands
│
├── 📁 Widgets/
│   └── AutoPinWidget.swift     # Watch complication
│
├── 📁 Extensions/
│   └── Date+Extensions.swift  # Date formatting
│
└── 📁 Utilities/
    └── Logger.swift            # Debug logging
```

---

## 📋 Technical Requirements Met

### 4.1 WatchOS UI (SwiftUI)
- ✅ Built entirely using SwiftUI
- ✅ Follows Apple Watch Human Interface Guidelines
- ✅ Proper use of VStack / HStack / NavigationStack
- ✅ System fonts and colors
- ✅ Large tap targets (minimum 44pt)
- ✅ UI usable on multiple watch sizes

### 4.2 Notifications
- ✅ Local notifications implemented
- ✅ Meaningful and appropriately timed
- ✅ Follows WatchOS notification best practices
- ✅ Interactive actions implemented

### 4.3 Complication OR Background Feature
- ✅ WatchOS complication (WidgetKit)
- ✅ Siri Shortcut / App Intent
- ✅ Background location monitoring

### 4.4 Data Handling
- ✅ SwiftData for local storage
- ✅ In-memory state management
- ✅ Proper data model with SavedItemPin

### 4.5 Performance & Accessibility
- ✅ Quick launch time
- ✅ No unnecessary background work
- ✅ Respects battery constraints
- ✅ Readable text sizes
- ✅ VoiceOver labels on interactive elements
- ✅ Adequate color contrast
- ✅ No reliance on color alone

---

## 📱 How to Build & Run

### Requirements

| Tool | Version |
|------|---------|
| Xcode | 15.0+ |
| Swift | 5.9+ |
| watchOS | 10.0+ |
| iOS | 17.0+ |

### Build Instructions

```bash
# 1. Clone or download the project
cd AutoPin

# 2. Open in Xcode
open AutoPin.xcodeproj

# 3. Select target
Product > Destination > Apple Watch Simulator

# 4. Build
Cmd + B

# 5. Run
Cmd + R
```

### Installation on Physical Watch

1. Connect Apple Watch to Mac
2. Select your watch as destination
3. Build and run (Cmd + R)
4. App will install automatically

---

## 🧪 Testing Checklist

### Functional Tests

- [x] Save item with valid GPS
- [x] View all saved items
- [x] Navigate to saved item
- [x] Delete items
- [x] Filter by category
- [x] Receive proximity notifications
- [x] Siri voice commands work

### UI Tests

- [x] Responsive on all watch sizes
- [x] Dark theme displays correctly
- [x] Empty states show properly
- [x] Loading indicators work
- [x] Error messages display

### Accessibility Tests

- [x] VoiceOver navigation works
- [x] Haptic feedback triggers
- [x] Text readable at arm's length
- [x] Color contrast sufficient

---

## 📱 Screenshots

### Main Screens

<div align="center">

| | | |
|:---:|:---:|:---:|
| <img src="AutoPin Watch App/screenshots/home.png" width="200"/> | <img src="AutoPin Watch App/screenshots/save_pin.png" width="200"/> | <img src="AutoPin Watch App/screenshots/my_items.png" width="200"/> |
| **Home** | **Save Pin** | **My Items** |
| <img src="AutoPin Watch App/screenshots/item_details.png" width="200"/> | <img src="AutoPin Watch App/screenshots/item_distance.png" width="200"/> | <img src="AutoPin Watch App/screenshots/delete.png" width="200"/> |
| **Item Details** | **Distance** | **Delete** |

</div>

---

## 🔒 Privacy & Permissions

### Permissions Required

| Permission | Justification |
|------------|---------------|
| Location | To save and navigate to item locations |
| Motion | To detect when user stops moving |

### Privacy Statement

> *"AutoPin uses your location and motion data only to help you remember and find your personal belongings. All data is stored locally on your Apple Watch and is never shared with third parties."*

---

## 📝 Known Limitations

1. **GPS Accuracy** - Indoor accuracy may vary (±10m typical)
2. **Altitude** - Relative elevation only, not floor numbers
3. **No Sync** - Data exists only on single device
4. **No Photos** - Location only, no image attachment (v1.0)

---

## 🚀 Future Enhancements

| Feature | Description |
|---------|-------------|
| iPhone Companion | Manage items from iPhone |
| iCloud Sync | Cross-device data sharing |
| Photo Attachment | Add images to saved items |
| Voice Labels | Siri "Where is my bag?" |
| Geofence Reminders | Automatic proximity alerts |

---

## 📄 License

This project is submitted as a capstone assignment. All code is original work.

---

## 👨‍💻 Author

**Name:** Dhruv Rasikbhai Jivani  
**Course:** WatchOS Development Capstone  
**Date:** February 23, 2026

---

## ✅ Submission Checklist

- [x] Xcode project folder included
- [x] Clean build (no errors)
- [x] README.md complete
- [x] All features implemented
- [x] Accessibility features added
- [x] No derived data
- [x] Proper project structure
- [x] Tested on simulator
- [x] Documentation complete

---

*Last Updated: February 2026*
*Version: 1.0.0*


# Dark Mode Migration Guide for Discernment180W

## Overview
This guide provides step-by-step instructions to make your app fully dark mode compatible. The app currently has significant visibility issues in dark mode due to hardcoded colors.

## Quick Start

### 1. Add the AppColors System
The `AppColors.swift` file has been created with adaptive colors. Import it in any file that needs color updates:

```swift
import SwiftUI
// Your file will automatically have access to AppColors
```

### 2. Add Color Scheme Detection
In views that need custom dark/light mode logic, add:

```swift
@Environment(\.colorScheme) var colorScheme
```

## Color Replacement Guide

### Most Common Replacements

| Old Code | New Code | Purpose |
|----------|----------|---------|
| `Color.white` | `AppColors.secondaryBackground` | Backgrounds that should adapt |
| `Color.black` | `AppColors.primaryText` | Text that should be visible |
| `.foregroundColor(.black)` | `.foregroundColor(AppColors.primaryText)` | Adaptive text |
| `.background(Color.white)` | `.background(AppColors.secondaryBackground)` | Adaptive backgrounds |
| `.stroke(Color.black, lineWidth: 1)` | `.stroke(AppColors.separator, lineWidth: 1)` | Borders/separators |

### Hex Color Replacements

| Old Hex Color | Light Mode | Dark Mode | Usage |
|---------------|------------|-----------|-------|
| `#132A47` (dark blue) | Keep as-is | `#4D7FCC` | Use `AppColors.primaryBlue(for: colorScheme)` |
| `#DAA520` (gold) | Keep as-is | `#FFD700` | Use `AppColors.goldAccent(for: colorScheme)` |
| `#d89e63` (orange) | Keep as-is | `#FF9F40` | Use `AppColors.orangeAccent(for: colorScheme)` |

## File-by-File Migration Instructions

### Priority 1: Critical Files (Most Broken in Dark Mode)

#### 1. MyPlanningAheadView.swift
**Status**: Example created as `MyPlanningAheadView_DarkMode.swift`

Key changes needed:
- Replace all 6 instances of `.background(Color.white)` with `.background(AppColors.secondaryBackground)`
- Replace all 12 instances of `.stroke(Color.black, lineWidth: 1)` with `.stroke(AppColors.separator, lineWidth: 1)`
- Replace all 10 instances of `.foregroundColor(.black)` with `.foregroundColor(AppColors.primaryText)`

#### 2. SignUpPageView.swift
Lines to fix: 37, 51, 68, 94, 159, 172, 185, 198

```swift
// Old (line 159):
.background(Color.white)

// New:
.background(AppColors.formFieldBackground)

// Old (line 37):
.foregroundColor(.white)

// New:
.foregroundColor(AppColors.primaryText)
```

#### 3. RuleOfLifeFormView.swift
Lines to fix: 487 (9 instances of white backgrounds)

```swift
// Replace all instances of:
.background(Color.white)

// With:
.background(AppColors.cardBackground)
```

### Priority 2: High Impact Files

#### 4. HomePageView.swift
Add at the top of the struct:
```swift
@Environment(\.colorScheme) var colorScheme
```

Replace hardcoded hex colors:
```swift
// Old:
Color(hexString: "#132A47")

// New:
AppColors.primaryBlue(for: colorScheme)

// Old:
Color(hexString: "#DAA520")

// New:
AppColors.goldAccent(for: colorScheme)
```

#### 5. WeekReviewView.swift
Multiple white backgrounds and black borders need updating:
```swift
// Replace:
.background(Color.white)
// With:
.background(AppColors.cardBackground)

// Replace:
.foregroundColor(.black)
// With:
.foregroundColor(AppColors.primaryText)
```

### Priority 3: Other Views

#### DailyReadingView.swift
This file already has some dark mode support but needs completion:
- Keep the existing `@Environment(\.colorScheme) var colorScheme`
- Update remaining hardcoded colors
- The notes input background needs to be adaptive

#### NavigationHubView.swift, ExcursusView.swift, etc.
Apply the same replacement patterns as above.

## Testing Dark Mode

### In Xcode Previews
Add preview variants to test both modes:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
```

### In Simulator/Device
1. Go to Settings → Developer → Dark Appearance
2. Toggle between light and dark modes
3. Or use Control Center to switch appearance

## Common Patterns to Fix

### 1. Button Toggle States
```swift
// Old pattern:
.foregroundColor(isSelected ? .white : .black)
.background(isSelected ? Color.blue : Color.white)

// New pattern:
.foregroundColor(isSelected ? .white : AppColors.primaryText)
.background(isSelected ? Color.blue : AppColors.secondaryBackground)
```

### 2. Form Fields
```swift
// Old:
TextField("Placeholder", text: $text)
    .background(Color.white)
    .foregroundColor(.black)

// New:
TextField("Placeholder", text: $text)
    .background(AppColors.formFieldBackground)
    .foregroundColor(AppColors.primaryText)
```

### 3. Cards/Containers
```swift
// Old:
VStack {
    // content
}
.background(Color.white)
.shadow(color: Color.black.opacity(0.1), radius: 5)

// New:
VStack {
    // content
}
.background(AppColors.cardBackground)
.shadow(color: Color.black.opacity(0.1), radius: 5)
```

### 4. Gradients
```swift
// Old:
LinearGradient(
    gradient: Gradient(colors: [Color(hex: "#132A47"), Color(hex: "#1A3556")]),
    startPoint: .top,
    endPoint: .bottom
)

// New:
AdaptiveGradient.blueGradient(for: colorScheme)
```

## Quick Wins

1. **Global Text Color**: Replace all `.foregroundColor(.black)` with `.foregroundColor(AppColors.primaryText)`
2. **Global Backgrounds**: Replace all `.background(Color.white)` with `.background(AppColors.secondaryBackground)`
3. **Global Borders**: Replace all `.stroke(Color.black,` with `.stroke(AppColors.separator,`

## Verification Checklist

- [ ] All text is visible in both light and dark modes
- [ ] Buttons show proper contrast when selected/unselected
- [ ] Form fields have visible backgrounds and text
- [ ] Navigation elements are clearly visible
- [ ] Icons and symbols adapt appropriately
- [ ] Shadows and borders are subtle but visible
- [ ] Brand colors maintain identity while being accessible

## Advanced: Custom Adaptive Colors

For views needing custom light/dark colors:

```swift
struct MyView: View {
    @Environment(\.colorScheme) var colorScheme

    var myCustomColor: Color {
        colorScheme == .dark
            ? Color(hex: "#AABBCC")  // Dark mode color
            : Color(hex: "#112233")  // Light mode color
    }

    var body: some View {
        Text("Hello")
            .foregroundColor(myCustomColor)
    }
}
```

## Migration Order Recommendation

1. **Day 1**: Update MyPlanningAheadView, SignUpPageView, RuleOfLifeFormView
2. **Day 2**: Update HomePageView, WeekReviewView, DailyReadingView
3. **Day 3**: Update remaining views
4. **Day 4**: Test thoroughly and refine

## Need Help?

Common issues and solutions:

**Issue**: DatePicker looks wrong in dark mode
**Solution**: DatePickers automatically adapt, but ensure surrounding views use adaptive colors

**Issue**: TextEditor background is not visible
**Solution**: Use `.background(AppColors.formFieldBackground)` explicitly

**Issue**: Custom drawn shapes/paths are invisible
**Solution**: Use `.stroke(AppColors.primaryText)` or `.fill(AppColors.primaryText)`

## Summary

The main principle is simple: **Never use hardcoded colors**. Always use adaptive colors from the AppColors system or SwiftUI's built-in adaptive colors like `.primary`, `.secondary`, etc.

With these changes, your app will look great in both light and dark modes!
# TXIndia City Themes 🎨

The app now features dynamic themes that change based on the selected city. Each city has a unique color palette and background gradient that reflects its character and identity.

## City Themes

### 🏢 Dallas - Blue & Gold (Corporate)
- **Primary Color**: Blue (#0066CC)
- **Secondary Color**: Gold (#FFD700)
- **Background Gradient**: Deep Blue to Bright Blue
- **Theme**: Professional, corporate, and established business hub

### 🚀 Houston - Orange & Teal (Energy)
- **Primary Color**: Orange (#FF8C00)
- **Secondary Color**: Teal (#00CCFF)
- **Background Gradient**: Deep Orange to Vibrant Teal
- **Theme**: Energetic, dynamic, and innovation-focused

### 🎸 Austin - Purple & Green (Creative)
- **Primary Color**: Purple (#9933FF)
- **Secondary Color**: Green (#33FF66)
- **Background Gradient**: Deep Purple to Bright Green
- **Theme**: Creative, vibrant, and artistic community

### 🏛️ San Antonio - Red & Cream (Historic)
- **Primary Color**: Red (#D91A1A)
- **Secondary Color**: Cream (#FFFADD)
- **Background Gradient**: Deep Red to Light Red
- **Theme**: Historic, traditional, and culturally rich

### 🏖️ Corpus Christi - Turquoise & Sand (Beach)
- **Primary Color**: Turquoise (#00CCEE)
- **Secondary Color**: Sand (#FFE6B0)
- **Background Gradient**: Teal to Bright Turquoise
- **Theme**: Coastal, relaxing, and beachy atmosphere

## Dynamic Elements

The following elements automatically update based on the selected city theme:

1. **Home Screen Background**: Full-screen gradient
2. **Events Screen Background**: Full-screen gradient
3. **Category Filter Button**: Uses city primary and secondary colors
4. **City Selector Button**: Active state uses city theme colors
5. **Tab Bar Accent Color**: Changes to city's primary color
6. **Shadow Colors**: Match the city's primary color

## Implementation Details

The theme system is implemented in the `City` enum in `ContentView.swift`:

```swift
var themeColors: (primary: Color, secondary: Color, gradient1: Color, gradient2: Color)
var backgroundGradient: LinearGradient
```

Each view that needs to be themed accesses these properties through the `@EnvironmentObject var cityManager: CityManager`.

## Future Enhancements

- City-specific navigation bar colors
- City-specific text color variations for better contrast
- Animation transitions when switching cities
- City-specific fonts or typography variations

# TwinFlame

An iOS re-implementation of the HeartCurve generative art piece using Swift and SpriteKit.

## About

TwinFlame recreates a p5.js generative artwork that animates two intertwined heart shapes formed by particles connected with lace-like threads. The particles flow between inner and outer heart positions, creating a breathing, organic visual effect.

### The Heart Curve

The hearts are generated using the parametric heart equation:

```
x = 16r · sin³(θ)
y = -r · (13cos(θ) - 5cos(2θ) - 2cos(3θ) - cos(4θ))
```

Where `r` controls the size of the heart and `θ` ranges from 0 to 2π. Two hearts are generated at different radii (20 and 8), creating the inner and outer shapes.

### Animation Behavior

- **Vehicles**: Particles that seek target positions on the heart curves using steering behaviors
- **Laces**: Chains of segments connecting vehicle pairs using inverse kinematics
- **Interaction**: Touch the screen to make particles flee from your finger

The vehicles alternate between inner and outer heart positions over time, creating a pulsing effect as the two hearts breathe in and out.

## Architecture

```
GameScene          - Main SpriteKit scene managing the animation loop
├── Vehicle        - Particle with position, velocity, and steering behaviors
├── Lace           - Chain of connected segments
│   └── Segment    - Single segment with inverse kinematics
```

## Requirements

- iOS 18.0+
- Xcode 26.0+
- Swift 5.0+

## Building

Open `TwinFlame.xcodeproj` in Xcode and build for an iOS Simulator or device.

## Development with Non-Xcode IDEs

To get proper Swift language support (autocomplete, type checking, go-to-definition) in editors like Zed, VS Code, or Neovim, you need SourceKit-LSP configured with the Xcode toolchain.

### 1. Set Xcode as the Active Developer Directory

The iOS SDK (containing UIKit types like `UITouch` and `UIEvent`) is only available in the full Xcode installation, not Command Line Tools.

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Verify the change:

```bash
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer
```

### 2. Build the Project Once

SourceKit-LSP needs build artifacts to understand multi-file project structure. Build via Xcode or command line:

```bash
xcodebuild -project TwinFlame.xcodeproj -scheme TwinFlame -destination 'generic/platform=iOS Simulator' build
```

### 3. Verify SourceKit-LSP Path

Ensure your editor uses the Xcode toolchain's SourceKit-LSP:

```bash
xcrun --find sourcekit-lsp
# Should return a path inside /Applications/Xcode.app/...
```

If it returns a Command Line Tools path, repeat step 1.

### 4. Restart Your Editor

After completing the above steps, restart your editor or reload the workspace. The LSP should now resolve all types correctly.

## Credits

Based on my original HeartCurve p5.js sketch you can find here: https://github.com/julian-abhari/HeartCurve.

## License

MIT

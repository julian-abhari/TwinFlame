# Sparkle Button Implementation Plan

## Objective

The goal is to implement a button with a sparkle icon that appears in the center of the inner heart on the `GameScene`. When the user taps the button, it will disappear with an animation, and a beautifully animated message will appear at the bottom of the screen.

## File Changes

- **Create:** `TwinFlame/SparkleButtonNode.swift` - A new file for the sparkle button node.
- **Modify:** `TwinFlame/GameScene.swift` - The main game scene where the button and animations will be added.

## Implementation Steps

1.  **Create `SparkleButtonNode.swift`**
    -   Create a new Swift file named `SparkleButtonNode.swift`.
    -   This class will subclass `SKSpriteNode`.
    -   It will have an `init(size: CGSize)` method to set up the button's appearance.
    -   The button's appearance will be a simple four-pointed star created programmatically with `SKShapeNode`.
    -   It will have a `tapped()` method that runs a sequence of `SKAction`s to fade out, scale down, and remove the button from the scene.

2.  **Add Sparkle Button to `GameScene.swift`**
    -   In `GameScene.swift`, add a new property for the `SparkleButtonNode`: `private var sparkleButton: SparkleButtonNode?`.
    -   In the `didMove(to:)` method, create an instance of `SparkleButtonNode` and add it as a child to the scene.
    -   Set the button's position to the center of the screen, which is `CGPoint(x: size.width / 2, y: size.height / 2)` in SpriteKit's coordinate system. Since the heart is centered at (0,0) in its own coordinate space and then added to the scene, placing the button at `(0,0)` relative to the scene's anchor point (which is default `(0,0)` center for this scene) should be correct. I will confirm this.

3.  **Handle Tap Gesture**
    -   In `GameScene.swift`, modify the `touchesBegan(_:with:)` method.
    -   Check if the touched node is the `sparkleButton`.
    -   If it is, call the `tapped()` method on the button and then trigger the message animation.

4.  **Implement Message Animation**
    -   Create a new method in `GameScene.swift` called `animateMessage()`.
    -   This method will be called from `touchesBegan(_:with:)` after the button is tapped.
    -   Inside `animateMessage()`:
        -   Create an `SKLabelNode` with the text "TwinFlame".
        -   Set the font color to white, and choose a suitable font and size.
        -   Position the label at the bottom of the screen.
        -   Create a sequence of `SKAction`s to animate the label's appearance (e.g., fade in and move up from the bottom).
        -   Run the action on the label node.

## Open Questions/Considerations

-   **Message Text:** The final text of the message can be easily changed. "TwinFlame" is a placeholder.
-   **Animation Timings:** The duration and style of the animations (button disappearance and message appearance) can be fine-tuned for the best visual effect.
-   **Sparkle Icon:** The programmatic sparkle icon is a placeholder. A custom texture could be used for a more polished look.
-   **Centering:** Double check the coordinate system to ensure the button is perfectly centered. For a scene with `scaleMode = .aspectFill`, the center of the view is not necessarily `(0,0)` in the scene's coordinates. I'll need to use the frame's midpoint. `CGPoint(x: self.frame.midX, y: self.frame.midY)` is the way to go.

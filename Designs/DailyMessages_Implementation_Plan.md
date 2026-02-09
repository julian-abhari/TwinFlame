# Daily Messages Implementation Plan

## Objective

The goal is to display a daily message from a predefined list. The messages will cycle day by day, starting from an arbitrary date.

## File Changes

-   **Create:** `TwinFlame/MessageStore.swift` - A new file to store and manage the daily messages.
-   **Modify:** `TwinFlame/GameScene.swift` - The main game scene, which will display the message.

## Implementation Steps

1.  **Create `MessageStore.swift`**
    -   Create a new Swift file named `MessageStore.swift`.
    -   This file will define a `struct` called `MessageStore`.
    -   Inside `MessageStore`, create a static array of strings that will hold the messages.
    -   Define a static `startDate` property. This will be the date for the first message.
    -   Create a static function, `getTodaysMessage() -> String`, which will:
        -   Calculate the number of days that have passed between `startDate` and the current date.
        -   Use the modulo operator (`%`) with the number of messages to get the index of the current day's message.
        -   Return the message at that index.

2.  **Modify `GameScene.swift`**
    -   In the `animateMessage()` method, change the line that sets the `messageLabel.text` to call `MessageStore.getTodaysMessage()`.

## Open Questions/Considerations

-   **Message List:** The initial list of messages will be placeholders. This list can be expanded or changed easily in `MessageStore.swift`.
-   **Start Date:** The `startDate` will be an arbitrary date. I'll pick a date that makes sense for the project, for example, the day the project was started.
-   **No Messages:** The `getTodaysMessage()` function should handle the case where the message list is empty to avoid a crash, perhaps by returning a default message.

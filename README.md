# AnimationTrackBuilder

A type-safe helper class for creating AnimationPlayer tracks programmatically in Godot (GDScript).

## The Problem

In Godot, animations are typically created through the editor using the AnimationPlayer panel. While this visual approach works fine for simple projects, it creates some headaches:

- **Editor Dependencies**: Your animations are locked in `.tscn` files, making them hard to version control and review.
- **Difficult to Refactor**: Renaming a method? Good luck finding all the animation tracks that call it.
- **Hard to Generate**: Want to create animations dynamically or from data? You're stuck with verbose, error-prone manual API calls.
- **Silent Failures**: Godot's animation API often fails silently - you won't know something's wrong until runtime.

## The Solution

`AnimationTrackBuilder` lets you define animations entirely in code with a clean, fluent API. It leverages GDScript 2.0 `Callables` for type safety and validates operations with assertions.

```gdscript
var builder = AnimationTrackBuilder.from_player(anim_player, "player_jump")
builder.method_track(self).insert_method_key(0.1, jump, []) # uses Callable 'jump'
```

## Features

- **Type-Safe**: Uses node references and Callables instead of string paths/names.
- **Compile-Time Safety**: By using `Callable` (e.g., `my_func`), the Godot editor flags typos immediately before you even run the game.
- **Fluent API**: Chain method calls for clean, readable animation definitions.
- **Comprehensive Assertions**: Every operation is validated - fail fast with clear error messages.
- **No Silent Failures**: Verifies that tracks and keys are actually created successfully.
- **Node Reference Based**: Pass actual node references instead of calculating paths manually.

## Installation

1. Copy `AnimationTrackBuilder.gd` into your Godot project.
2. The class is automatically available as `AnimationTrackBuilder` (thanks to `class_name`).

## Quick Start

> [!WARNING]
> **AnimationTree Filter Compatibility**: When using an AnimationTree with blend nodes that have filters enabled, you must call `AnimationTrackBuilder.prevent_track_overwrite()` for each affected node. Without this, method tracks will be filtered out and their function calls won't execute. This is a general Godot requirement when working with AnimationTree filters.

### Basic Method Track

```gdscript
extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
    var builder = AnimationTrackBuilder.from_player(anim_player, "my_animation")
    
    # Add a method track that calls your functions
    # Note: We pass the function itself (Callable), not a string
    builder.method_track(self) \
        .insert_method_key(0.5, play_sound, []) \
        .insert_method_key(1.0, spawn_effect, ["explosion"])

func play_sound():
    print("Sound playing")

func spawn_effect(type):
    print("Effect: ", type)
```

### Animating Properties

```gdscript
func _ready():
    var builder = AnimationTrackBuilder.from_player(anim_player, "fade_in")
    
    # Animate the modulate property
    builder.value_track(self, "modulate") \
        .set_interpolation(Animation.INTERPOLATION_LINEAR) \
        .insert_value_key(0.0, Color(1, 1, 1, 0)) \
        .insert_value_key(1.0, Color(1, 1, 1, 1))
```

### Creating New Animations

```gdscript
func _ready():
    # Create a new 2-second animation
    var builder = AnimationTrackBuilder.create_new(anim_player, "custom_anim", 2.0)
    
    builder.method_track(self) \
        .insert_method_key(1.0, do_something)
```

## API Reference

### Static Methods

#### `from_player(anim_player: AnimationPlayer, animation_name: String, base_node: Node = null) -> AnimationTrackBuilder`
Creates a builder from an existing animation.

#### `create_new(anim_player: AnimationPlayer, animation_name: String, length: float = 1.0, base_node: Node = null) -> AnimationTrackBuilder`
Creates a new animation and returns a builder for it.

#### `prevent_track_overwrite(anim_tree: AnimationTree, raw_path: String, target_node: Node) -> void`
Configures an AnimationTree node to prevent track filtering issues.
```gdscript
AnimationTrackBuilder.prevent_track_overwrite(anim_tree, "parameters/OneShot/active", sprite)
```

### Track Creation Methods

#### `method_track(reference_node: Node) -> AnimationTrackBuilder`
Adds a method call track for the specified node.

#### `value_track(reference_node: Node, property: String) -> AnimationTrackBuilder`
Adds a property animation track. Validates that the property exists on the node.

#### `audio_track(reference_node: Node) -> AnimationTrackBuilder`
Adds an audio track. Node must be an AudioStreamPlayer variant.

#### `animation_track(reference_node: Node) -> AnimationTrackBuilder`
Adds an animation playback track. Node must be an AnimationPlayer.

### Key Insertion Methods

#### `insert_method_key(time: float, callable: Callable, args: Array = []) -> AnimationTrackBuilder`
Inserts a method call at the specified time. 
*   **callable**: The function to call (e.g., `my_function`). Must be valid.
*   **args**: Optional array of arguments to pass to the method.

#### `insert_value_key(time: float, value: Variant) -> AnimationTrackBuilder`
Inserts a property value at the specified time.

#### `insert_audio_key(time: float, stream: AudioStream, start_offset: float = 0.0, end_offset: float = 0.0) -> AnimationTrackBuilder`
Inserts an audio stream key.

#### `insert_animation_key(time: float, animation_name: String) -> AnimationTrackBuilder`
Inserts an animation playback key.

### Configuration Methods

#### `set_interpolation(interpolation: Animation.InterpolationType) -> AnimationTrackBuilder`
Sets the interpolation type (Linear, Cubic, etc.) for the current track.

#### `set_update_mode(mode: Animation.UpdateMode) -> AnimationTrackBuilder`
Sets the update mode (Continuous, Discrete, etc.) for value tracks.

#### `set_loop_wrap(enabled: bool) -> AnimationTrackBuilder`
Enables or disables loop wrapping.

## Why Use Assertions?

The `assert(condition, message)` syntax provides immediate feedback when something goes wrong:

- **Fail Fast**: Errors are caught immediately when you run the scene.
- **Clear Messages**: Know exactly what went wrong and where.

Example error message (for a property track):
```
SCRIPT ERROR: Assertion failed: Property 'positionn' does not exist on node 'Player'
          at: value_track (res://AnimationTrackBuilder.gd:105)
```

For method tracks, using `Callables` ensures that if you write `insert_method_key(0.0, func_that_does_not_exist)`, the Godot editor itself will likely flag it as an error before you even run the project.

## License

Free to use for any purpose. No attribution required.


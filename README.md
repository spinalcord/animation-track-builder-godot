# AnimationTrackBuilder

A more type-safe approach helper GDScript class for creating AnimationPlayer tracks programmatically in Godot.

## The Problem

In Godot, animations are typically created through the editor using the AnimationPlayer panel. While this visual approach works fine for simple projects, it creates some headaches:

- **Editor Dependencies**: Your animations are locked in `.tscn` files, making them hard to version control and review
- **No Type Safety**: The editor won't warn you if you reference a method that doesn't exist or misspell a property name
- **Difficult to Refactor**: Renaming a method? Good luck finding all the animation tracks that call it
- **Hard to Generate**: Want to create animations dynamically or from data? You're stuck with verbose, error-prone manual API calls
- **Silent Failures**: Godot's animation API often fails silently - you won't know something's wrong until runtime

## The Solution

`AnimationTrackBuilder` lets you define animations entirely in code with a clean, fluent API. Every operation is validated with assertions, so you catch errors immediately rather than discovering them during gameplay.

```gdscript
var builder = AnimationTrackBuilder.from_player(anim_player, "player_jump")
builder.add_method_track(self).insert_method_key(0.1, "jump", []) # self => script owner
```

## Features

- **Type-Safe**: Uses node references instead of string paths - no more typos
- **Method Validation**: Automatically checks if methods and properties exist before creating tracks
- **Fluent API**: Chain method calls for clean, readable animation definitions
- **Comprehensive Assertions**: Every operation is validated - fail fast with clear error messages
- **No Silent Failures**: Verifies that tracks and keys are actually created successfully
- **Node Reference Based**: Pass actual node references instead of calculating paths manually

## Installation

1. Copy `AnimationTrackBuilder.gd` into your Godot project
2. The class is automatically available as `AnimationTrackBuilder` (thanks to `class_name`)

## Quick Start

### Basic Method Track

```gdscript
extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
    var builder = AnimationTrackBuilder.from_player(anim_player, "my_animation")
    
    # Add a method track that calls your functions
    builder.add_method_track(self) \
        .insert_method_key(0.5, "play_sound", []) \
        .insert_method_key(1.0, "spawn_effect", ["explosion"])
```

### Animating Properties

```gdscript
func _ready():
    var builder = AnimationTrackBuilder.from_player(anim_player, "fade_in")
    
    # Animate the modulate property
    builder.add_value_track(self, "modulate") \
        .set_interpolation(Animation.INTERPOLATION_LINEAR) \
        .insert_value_key(0.0, Color(1, 1, 1, 0)) \
        .insert_value_key(1.0, Color(1, 1, 1, 1))
```

### Creating New Animations

```gdscript
func _ready():
    # Create a new 2-second animation
    var builder = AnimationTrackBuilder.create_new(anim_player, "custom_anim", 2.0)
    
    builder.add_method_track(self) \
        .insert_method_key(1.0, "do_something")
```

### Multiple Tracks

```gdscript
func _ready():
    var builder = AnimationTrackBuilder.from_player(anim_player, "complex_anim")
    
    # Add method track
    builder.add_method_track(self) \
        .insert_method_key(0.5, "step_one") \
        .insert_method_key(1.0, "step_two")
    
    # Add value track for a different node
    var sprite = $Sprite2D
    builder.add_value_track(sprite, "position") \
        .insert_value_key(0.0, Vector2(0, 0)) \
        .insert_value_key(1.0, Vector2(100, 0))
```

## API Reference

### Static Methods

#### `from_player(anim_player: AnimationPlayer, animation_name: String, base_node: Node = null) -> AnimationTrackBuilder`

Creates a builder from an existing animation.

- `anim_player`: The AnimationPlayer containing the animation
- `animation_name`: Name of the animation to modify
- `base_node`: Node to use for path calculations (defaults to AnimationPlayer's parent)

#### `create_new(anim_player: AnimationPlayer, animation_name: String, length: float = 1.0, base_node: Node = null) -> AnimationTrackBuilder`

Creates a new animation and returns a builder for it.

- `animation_name`: Name for the new animation
- `length`: Duration in seconds (default: 1.0)

### Track Creation Methods

#### `add_method_track(reference_node: Node) -> AnimationTrackBuilder`

Adds a method call track for the specified node.

#### `add_value_track(reference_node: Node, property: String) -> AnimationTrackBuilder`

Adds a property animation track. Validates that the property exists on the node.

#### `add_audio_track(reference_node: Node) -> AnimationTrackBuilder`

Adds an audio track. Node must be an AudioStreamPlayer variant.

#### `add_animation_track(reference_node: Node) -> AnimationTrackBuilder`

Adds an animation playback track. Node must be an AnimationPlayer.

### Key Insertion Methods

#### `insert_method_key(time: float, method_name: String, args: Array = []) -> AnimationTrackBuilder`

Inserts a method call at the specified time. **Validates that the method exists on the reference node.**

#### `insert_value_key(time: float, value: Variant) -> AnimationTrackBuilder`

Inserts a property value at the specified time.

#### `insert_audio_key(time: float, stream: AudioStream, start_offset: float = 0.0, end_offset: float = 0.0) -> AnimationTrackBuilder`

Inserts an audio stream key.

#### `insert_animation_key(time: float, animation_name: String) -> AnimationTrackBuilder`

Inserts an animation playback key. **Validates that the animation exists in the target AnimationPlayer.**

### Configuration Methods

#### `set_interpolation(interpolation: Animation.InterpolationType) -> AnimationTrackBuilder`

Sets the interpolation type for the current track.

```gdscript
.set_interpolation(Animation.INTERPOLATION_LINEAR)
.set_interpolation(Animation.INTERPOLATION_CUBIC)
```

#### `set_update_mode(mode: Animation.UpdateMode) -> AnimationTrackBuilder`

Sets the update mode for value tracks.

```gdscript
.set_update_mode(Animation.UPDATE_CONTINUOUS)
.set_update_mode(Animation.UPDATE_DISCRETE)
```

#### `set_loop_wrap(enabled: bool) -> AnimationTrackBuilder`

Enables or disables loop wrapping for the current track.

### Utility Methods

#### `remove_current_track() -> AnimationTrackBuilder`

Removes the currently selected track.

#### `get_animation() -> Animation`

Returns the Animation object being modified.

#### `get_current_track_idx() -> int`

Returns the index of the currently selected track.

#### `get_base_node() -> Node`

Returns the base node used for path calculations.

## Advanced Example

```gdscript
extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func setup_jump_animation():
    var builder = AnimationTrackBuilder.create_new(anim_player, "jump", 0.5)
    
    # Method calls during jump
    builder.add_method_track(self) \
        .insert_method_key(0.0, "on_jump_start") \
        .insert_method_key(0.25, "on_jump_peak") \
        .insert_method_key(0.5, "on_jump_land")
    
    # Animate sprite position
    builder.add_value_track(sprite, "position") \
        .set_interpolation(Animation.INTERPOLATION_CUBIC) \
        .insert_value_key(0.0, Vector2(0, 0)) \
        .insert_value_key(0.25, Vector2(0, -50)) \
        .insert_value_key(0.5, Vector2(0, 0))
    
    # Squash and stretch
    builder.add_value_track(sprite, "scale") \
        .insert_value_key(0.0, Vector2(1, 1)) \
        .insert_value_key(0.1, Vector2(0.8, 1.2)) \
        .insert_value_key(0.25, Vector2(1, 1)) \
        .insert_value_key(0.45, Vector2(1.2, 0.8)) \
        .insert_value_key(0.5, Vector2(1, 1))
    
    # Play jump sound
    var jump_sound = preload("res://sounds/jump.wav")
    builder.add_audio_track(audio) \
        .insert_audio_key(0.0, jump_sound)

func on_jump_start():
    print("Jump started!")

func on_jump_peak():
    print("Reached peak!")

func on_jump_land():
    print("Landed!")
```

## Why Use Assertions?

The `assert(condition, message)` syntax provides immediate feedback when something goes wrong:

- **Fail Fast**: Errors are caught immediately when you run the scene
- **Clear Messages**: Know exactly what went wrong and where
- **Development Aid**: Assertions are removed in release builds, so there's no performance cost

Example error message:
```
SCRIPT ERROR: Assertion failed: Method 'jumpp' does not exist on node 'Player'
          at: insert_method_key (res://AnimationTrackBuilder.gd:125)
```

This immediately tells you that you misspelled "jump" as "jumpp", saving you debugging time.

## License

Free to use for any purpose. No attribution required.

## Contributing

Found a bug or want to add a feature? Feel free to modify and extend this class for your needs!

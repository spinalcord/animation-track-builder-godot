class_name AnimationTrackBuilder
extends RefCounted

## Specialized class for programmatically defining AnimationPlayer tracks
## Provides type-safe methods to create and configure animation tracks

var _animation: Animation
var _base_node: Node
var _current_track_idx: int = -1
var _current_reference_node: Node = null

func _init(animation: Animation, base_node: Node) -> void:
	assert(animation != null, "Animation cannot be null")
	assert(base_node != null, "Base node cannot be null")
	assert(is_instance_valid(base_node), "Base node is not a valid instance")
	
	_animation = animation
	_base_node = base_node

## Find existing track by path and type, returns -1 if not found
func _find_track(target_path: NodePath, track_type: Animation.TrackType) -> int:
	for i in range(_animation.get_track_count()):
		if _animation.track_get_path(i) == target_path and _animation.track_get_type(i) == track_type:
			return i
	return -1

## Remove all tracks for a specific node and type
func remove_tracks_for_node(reference_node: Node, track_type: Animation.TrackType) -> AnimationTrackBuilder:
	assert(reference_node != null, "Reference node cannot be null")
	assert(is_instance_valid(reference_node), "Reference node is not a valid instance")
	
	var target_path := _base_node.get_path_to(reference_node)
	
	# Remove in reverse order to avoid index shifting issues
	for i in range(_animation.get_track_count() - 1, -1, -1):
		var track_path = _animation.track_get_path(i)
		# For value tracks, check if path starts with target_path
		if track_type == Animation.TYPE_VALUE:
			var track_path_str = str(track_path)
			var target_path_str = str(target_path)
			if track_path_str.begins_with(target_path_str + ":"):
				if _animation.track_get_type(i) == track_type:
					_animation.remove_track(i)
		else:
			if track_path == target_path and _animation.track_get_type(i) == track_type:
				_animation.remove_track(i)
	
	return self

## Add a method call track (reuses existing track if found)
func method_track(reference_node: Node, reuse_existing: bool = true) -> AnimationTrackBuilder:
	assert(reference_node != null, "Reference node cannot be null")
	assert(is_instance_valid(reference_node), "Reference node is not a valid instance")
	
	var target_path := _base_node.get_path_to(reference_node)
	assert(target_path != NodePath(), "Could not calculate path to reference node")
	assert(!target_path.is_empty(), "Calculated path is empty")
	
	if reuse_existing:
		_current_track_idx = _find_track(target_path, Animation.TYPE_METHOD)
		if _current_track_idx >= 0:
			_current_reference_node = reference_node
			return self
	
	_current_track_idx = _animation.add_track(Animation.TYPE_METHOD)
	assert(_current_track_idx >= 0, "Failed to add method track")
	
	_animation.track_set_path(_current_track_idx, target_path)
	assert(_animation.track_get_path(_current_track_idx) == target_path, "Failed to set track path")
	
	_current_reference_node = reference_node
	
	return self

## Add a property value track (reuses existing track if found)
func value_track(reference_node: Node, property: String, reuse_existing: bool = true) -> AnimationTrackBuilder:
	assert(reference_node != null, "Reference node cannot be null")
	assert(is_instance_valid(reference_node), "Reference node is not a valid instance")
	assert(property != "", "Property name cannot be empty")
	assert(!property.contains(":"), "Property should not contain ':' separator")
	assert(!property.contains("/"), "Property should not contain '/' separator")
	assert(!property.begins_with("."), "Property should not start with '.'")
	assert(property in reference_node, "Property '%s' does not exist on node '%s'" % [property, reference_node.name])
	
	var target_path := _base_node.get_path_to(reference_node)
	assert(target_path != NodePath(), "Could not calculate path to reference node")
	assert(!target_path.is_empty(), "Calculated path is empty")
	
	var full_path = NodePath(str(target_path) + ":" + property)
	
	if reuse_existing:
		_current_track_idx = _find_track(full_path, Animation.TYPE_VALUE)
		if _current_track_idx >= 0:
			_current_reference_node = reference_node
			return self
	
	_current_track_idx = _animation.add_track(Animation.TYPE_VALUE)
	assert(_current_track_idx >= 0, "Failed to add value track")
	
	_animation.track_set_path(_current_track_idx, full_path)
	assert(_animation.track_get_path(_current_track_idx) == full_path, "Failed to set track path")
	
	_current_reference_node = reference_node
	
	return self

## Add an audio stream track (reuses existing track if found)
func audio_track(reference_node: Node, reuse_existing: bool = true) -> AnimationTrackBuilder:
	assert(reference_node != null, "Reference node cannot be null")
	assert(is_instance_valid(reference_node), "Reference node is not a valid instance")
	assert(reference_node is AudioStreamPlayer or reference_node is AudioStreamPlayer2D or reference_node is AudioStreamPlayer3D, "Reference node must be an AudioStreamPlayer variant")
	
	var target_path := _base_node.get_path_to(reference_node)
	assert(target_path != NodePath(), "Could not calculate path to reference node")
	assert(!target_path.is_empty(), "Calculated path is empty")
	
	if reuse_existing:
		_current_track_idx = _find_track(target_path, Animation.TYPE_AUDIO)
		if _current_track_idx >= 0:
			_current_reference_node = reference_node
			return self
	
	_current_track_idx = _animation.add_track(Animation.TYPE_AUDIO)
	assert(_current_track_idx >= 0, "Failed to add audio track")
	
	_animation.track_set_path(_current_track_idx, target_path)
	assert(_animation.track_get_path(_current_track_idx) == target_path, "Failed to set track path")
	
	_current_reference_node = reference_node
	
	return self

## Add an animation playback track (reuses existing track if found)
func animation_track(reference_node: Node, reuse_existing: bool = true) -> AnimationTrackBuilder:
	assert(reference_node != null, "Reference node cannot be null")
	assert(is_instance_valid(reference_node), "Reference node is not a valid instance")
	assert(reference_node is AnimationPlayer, "Reference node must be an AnimationPlayer")
	
	var target_path := _base_node.get_path_to(reference_node)
	assert(target_path != NodePath(), "Could not calculate path to reference node")
	assert(!target_path.is_empty(), "Calculated path is empty")
	
	if reuse_existing:
		_current_track_idx = _find_track(target_path, Animation.TYPE_ANIMATION)
		if _current_track_idx >= 0:
			_current_reference_node = reference_node
			return self
	
	_current_track_idx = _animation.add_track(Animation.TYPE_ANIMATION)
	assert(_current_track_idx >= 0, "Failed to add animation track")
	
	_animation.track_set_path(_current_track_idx, target_path)
	assert(_animation.track_get_path(_current_track_idx) == target_path, "Failed to set track path")
	
	_current_reference_node = reference_node
	
	return self

## Insert a method call key using Callable
func insert_method_key(time: float, callable: Callable, args: Array = []) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(_animation.track_get_type(_current_track_idx) == Animation.TYPE_METHOD, "Current track is not a method track")
	assert(_current_reference_node != null, "No reference node set for current track")
	assert(is_instance_valid(_current_reference_node), "Reference node is no longer valid")
	assert(time >= 0.0, "Time must be positive")
	assert(time <= _animation.length, "Time exceeds animation length")
	assert(callable.is_valid(), "Callable is not valid")
	assert(args != null, "Args cannot be null")
	assert(args is Array, "Args must be an Array")
	
	var method_name = callable.get_method()
	assert(method_name != "", "Method name cannot be empty")
	
	var key_data = {
		"method": method_name,
		"args": args
	}
	
	# Generate unique hash for this specific key
	var key_hash = _generate_key_hash(time, key_data)
	
	# Check if this exact key already exists
	var existing_key_idx = _find_key_by_hash(key_hash)
	if existing_key_idx >= 0:
		# Key already exists, skip insertion (idempotent operation)
		return self
	
	var key_idx = _animation.track_insert_key(_current_track_idx, time, key_data)
	assert(key_idx >= 0, "Failed to insert method key")
	
	# Store hash metadata for future lookups
	_store_key_hash(key_idx, key_hash)
	
	return self

## Insert a value key
func insert_value_key(time: float, value: Variant) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(_animation.track_get_type(_current_track_idx) == Animation.TYPE_VALUE, "Current track is not a value track")
	assert(time >= 0.0, "Time must be positive")
	assert(time <= _animation.length, "Time exceeds animation length")
	
	# Generate unique hash
	var key_hash = _generate_key_hash(time, value)
	
	# Check if this exact key already exists
	var existing_key_idx = _find_key_by_hash(key_hash)
	if existing_key_idx >= 0:
		return self
	
	var key_idx = _animation.track_insert_key(_current_track_idx, time, value)
	assert(key_idx >= 0, "Failed to insert value key")
	
	_store_key_hash(key_idx, key_hash)
	
	return self

## Insert an audio stream key
func insert_audio_key(time: float, stream: AudioStream, start_offset: float = 0.0, end_offset: float = 0.0) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(_animation.track_get_type(_current_track_idx) == Animation.TYPE_AUDIO, "Current track is not an audio track")
	assert(time >= 0.0, "Time must be positive")
	assert(time <= _animation.length, "Time exceeds animation length")
	assert(stream != null, "AudioStream cannot be null")
	assert(stream is AudioStream, "Stream must be an AudioStream")
	assert(start_offset >= 0.0, "Start offset must be positive")
	assert(end_offset >= 0.0, "End offset must be positive")
	
	# Generate unique hash (use stream resource path for uniqueness)
	var key_hash = _generate_key_hash(time, {
		"stream_path": stream.resource_path,
		"start_offset": start_offset,
		"end_offset": end_offset
	})
	
	var existing_key_idx = _find_key_by_hash(key_hash)
	if existing_key_idx >= 0:
		return self
	
	_animation.audio_track_insert_key(_current_track_idx, time, stream, start_offset, end_offset)
	
	# Note: We can't get the key_idx from audio_track_insert_key, so we find it
	var key_idx = _animation.track_find_key(_current_track_idx, time, Animation.FIND_MODE_EXACT)
	if key_idx >= 0:
		_store_key_hash(key_idx, key_hash)
	
	return self

## Insert an animation playback key
func insert_animation_key(time: float, animation_name: String) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(_animation.track_get_type(_current_track_idx) == Animation.TYPE_ANIMATION, "Current track is not an animation track")
	assert(_current_reference_node != null, "No reference node set for current track")
	assert(is_instance_valid(_current_reference_node), "Reference node is no longer valid")
	assert(_current_reference_node is AnimationPlayer, "Reference node must be an AnimationPlayer")
	assert(time >= 0.0, "Time must be positive")
	assert(time <= _animation.length, "Time exceeds animation length")
	assert(animation_name != "", "Animation name cannot be empty")
	assert(_current_reference_node.has_animation(animation_name), "Animation '%s' does not exist in AnimationPlayer" % animation_name)
	
	var key_hash = _generate_key_hash(time, animation_name)
	
	var existing_key_idx = _find_key_by_hash(key_hash)
	if existing_key_idx >= 0:
		return self
	
	_animation.animation_track_insert_key(_current_track_idx, time, animation_name)
	
	var key_idx = _animation.track_find_key(_current_track_idx, time, Animation.FIND_MODE_EXACT)
	if key_idx >= 0:
		_store_key_hash(key_idx, key_hash)
	
	return self

## Hash system for tracking unique keys
var _key_hashes: Dictionary = {}  # Format: {track_idx: {key_idx: hash}}

## Generate a deterministic hash for a key based on time and value
func _generate_key_hash(time: float, value: Variant) -> int:
	# Create a unique string representation
	var hash_string = "%s_%d_%s" % [
		_animation.resource_path,
		_current_track_idx,
		str(time) + str(value)
	]
	return hash_string.hash()

## Find key index by hash
func _find_key_by_hash(target_hash: int) -> int:
	if not _key_hashes.has(_current_track_idx):
		return -1
	
	var track_hashes = _key_hashes[_current_track_idx]
	for key_idx in track_hashes:
		if track_hashes[key_idx] == target_hash:
			return key_idx
	
	return -1

## Store hash for a key
func _store_key_hash(key_idx: int, hash_value: int) -> void:
	if not _key_hashes.has(_current_track_idx):
		_key_hashes[_current_track_idx] = {}
	
	_key_hashes[_current_track_idx][key_idx] = hash_value

## Clear hash cache for current track (useful when removing track)
func clear_track_hashes() -> AnimationTrackBuilder:
	if _current_track_idx >= 0 and _key_hashes.has(_current_track_idx):
		_key_hashes.erase(_current_track_idx)
	return self



## Set interpolation type for current track
func set_interpolation(interpolation: Animation.InterpolationType) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	var track_type = _animation.track_get_type(_current_track_idx)
	assert(track_type == Animation.TYPE_VALUE or track_type == Animation.TYPE_BLEND_SHAPE or track_type == Animation.TYPE_POSITION_3D or track_type == Animation.TYPE_ROTATION_3D or track_type == Animation.TYPE_SCALE_3D, "Current track type does not support interpolation")
	assert(interpolation >= Animation.INTERPOLATION_NEAREST and interpolation <= Animation.INTERPOLATION_CUBIC_ANGLE, "Invalid interpolation type")
	
	_animation.track_set_interpolation_type(_current_track_idx, interpolation)
	
	return self

## Set update mode for current track
func set_update_mode(mode: Animation.UpdateMode) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(_animation.track_get_type(_current_track_idx) == Animation.TYPE_VALUE, "Current track is not a value track")
	assert(mode >= Animation.UPDATE_CONTINUOUS and mode <= Animation.UPDATE_CAPTURE, "Invalid update mode")
	
	_animation.value_track_set_update_mode(_current_track_idx, mode)
	
	return self

## Enable/disable looping for current track
func set_loop_wrap(enabled: bool) -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected. Call add_*_track() first")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	assert(enabled is bool, "Enabled must be a boolean")
	
	_animation.track_set_interpolation_loop_wrap(_current_track_idx, enabled)
	
	return self

## Remove the current track
func remove_current_track() -> AnimationTrackBuilder:
	assert(_current_track_idx >= 0, "No track selected")
	assert(_current_track_idx < _animation.get_track_count(), "Track index out of bounds")
	
	var track_count_before = _animation.get_track_count()
	
	# Clear hash cache before removing
	clear_track_hashes()
	
	_animation.remove_track(_current_track_idx)
	
	assert(_animation.get_track_count() == track_count_before - 1, "Track was not removed")
	
	_current_track_idx = -1
	_current_reference_node = null
	
	return self
## Get the animation object
func get_animation() -> Animation:
	return _animation

## Get current track index
func get_current_track_idx() -> int:
	return _current_track_idx

## Get the base node used for path calculations
func get_base_node() -> Node:
	return _base_node

## Static helper to create builder from AnimationPlayer
static func from_player(anim_player: AnimationPlayer, animation_name: String, base_node: Node = null) -> AnimationTrackBuilder:
	assert(anim_player != null, "AnimationPlayer cannot be null")
	assert(is_instance_valid(anim_player), "AnimationPlayer is not a valid instance")
	assert(animation_name != "", "Animation name cannot be empty")
	assert(anim_player.has_animation(animation_name), "Animation '%s' does not exist in AnimationPlayer" % animation_name)
	
	var animation: Animation = anim_player.get_animation(animation_name)
	assert(animation != null, "Failed to get animation '%s'" % animation_name)
	
	# Use AnimationPlayer's parent as base node if not specified
	var node_base := base_node if base_node != null else anim_player.get_parent()
	assert(node_base != null, "Base node cannot be null. Provide base_node or ensure AnimationPlayer has a parent")
	assert(is_instance_valid(node_base), "Base node is not a valid instance")
	
	return AnimationTrackBuilder.new(animation, node_base)

static func prevent_track_overwrite(anim_tree: AnimationTree, raw_path: String, target_node: Node) -> void:
	if not is_instance_valid(anim_tree) or not is_instance_valid(target_node):
		return
	
	# 1. Clean up path: remove "parameters/" if present
	var internal_path = raw_path.trim_prefix("parameters/")
	
	# 2. Remove property suffix (e.g. "/active", "/request") if present
	if internal_path.contains("/"):
		var last_slash_idx = internal_path.rfind("/")
		var potential_property = internal_path.substr(last_slash_idx + 1)
		# Check if it looks like a property name (not a node name)
		if potential_property in ["active", "request", "blend_amount", "scale"]:
			internal_path = internal_path.substr(0, last_slash_idx)
	
	# 3. Calculate path to target object
	var tree_root_obj = anim_tree.get_node(anim_tree.root_node)
	if not tree_root_obj: return
	var path_to_allow = tree_root_obj.get_path_to(target_node)
	
	# 4. Get node (now without "parameters/" and without property suffix)
	var specific_node = anim_tree.tree_root.get_node(internal_path)
	
	# Assert that the node exists and is an AnimationNode
	assert(specific_node != null, "Could not find AnimationNode: " + internal_path)
	assert(specific_node is AnimationNode, "Node '" + internal_path + "' is not an AnimationNode")
	
	if specific_node and specific_node is AnimationNode:
		if "filter_enabled" in specific_node:
			if not specific_node.filter_enabled:
				specific_node.filter_enabled = true
			
			specific_node.set_filter_path(path_to_allow, true)
		else:
			push_warning("Node '" + internal_path + "' has no filter.")

## Static helper to create builder with new animation
static func create_new(anim_player: AnimationPlayer, animation_name: String, length: float = 1.0, base_node: Node = null) -> AnimationTrackBuilder:
	assert(anim_player != null, "AnimationPlayer cannot be null")
	assert(is_instance_valid(anim_player), "AnimationPlayer is not a valid instance")
	assert(animation_name != "", "Animation name cannot be empty")
	assert(!anim_player.has_animation(animation_name), "Animation '%s' already exists" % animation_name)
	assert(length > 0.0, "Animation length must be positive")
	
	var animation := Animation.new()
	assert(animation != null, "Failed to create Animation instance")
	
	animation.length = length
	assert(animation.length == length, "Failed to set animation length")
	
	# Godot 4 requires animations to be added to an AnimationLibrary
	var library: AnimationLibrary
	if anim_player.has_animation_library(""):
		library = anim_player.get_animation_library("")
	else:
		library = AnimationLibrary.new()
		anim_player.add_animation_library("", library)

	library.add_animation(animation_name, animation)
	assert(anim_player.has_animation(animation_name), "Failed to add animation to AnimationPlayer")
	
	# Use AnimationPlayer's parent as base node if not specified
	var node_base := base_node if base_node != null else anim_player.get_parent()
	assert(node_base != null, "Base node cannot be null. Provide base_node or ensure AnimationPlayer has a parent")
	assert(is_instance_valid(node_base), "Base node is not a valid instance")
	
	return AnimationTrackBuilder.new(animation, node_base)


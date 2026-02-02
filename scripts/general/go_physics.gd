extends Node
class_name GoPhysics

const EPSILON = 0.001
const MAX_RAY_ORIGIN_OVERLAPS = 1

# Credits to marimitoTH for the original go_physics.gd
# This largely goes unchanged, however it has been reorganized and fit for Godot 4.

static func cast_ray(world: World2D, origin: Vector2, direction: Vector2, length: float, exclude: Array = [], layer: int = 1) -> Dictionary:
	var destination = origin + direction * length
	var space_state = world.direct_space_state
	
	# Create ray query parameters
	var ray_query = PhysicsRayQueryParameters2D.create(origin, destination)
	ray_query.exclude = exclude
	ray_query.collision_mask = layer
	
	var result = space_state.intersect_ray(ray_query)
	
	# Create point query parameters for overlap check
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = origin
	point_query.exclude = exclude
	point_query.collision_mask = layer
	
	var overlaps = space_state.intersect_point(point_query, MAX_RAY_ORIGIN_OVERLAPS)
	
	if result and overlaps.size() == 0:
		var penetration = destination.distance_to(result.position)
		return { 'position': result.position, 'normal': result.normal, 'penetration': penetration, 'collider': result.collider }
	
	return {}

static func cast_parallel_rays(world: World2D, origin: Vector2, offset: Vector2, direction: Vector2, length: float, exclude: Array = [], layer: int = 1) -> Dictionary:
	var right_ray = cast_ray(world, origin + offset, direction, length, exclude, layer)
	var left_ray = cast_ray(world, origin - offset, direction, length, exclude, layer)
	
	if right_ray or left_ray:
		var closest_ray = right_ray if right_ray else left_ray
		
		if left_ray and right_ray:
			var right_ray_distance = origin.distance_to(right_ray.position)
			var left_ray_distance = origin.distance_to(left_ray.position)
			closest_ray = right_ray if right_ray_distance <= left_ray_distance else left_ray
		
		return { 'right_hit': right_ray, 'left_hit': left_ray, 'closest_hit': closest_ray }
	
	return {}

static func overlap_shape(world: World2D, shape: Shape2D, origin: Vector2, rotation: float):
	var space_state = world.direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.transform = Transform2D(rotation, origin)
	params.shape = shape
	
	return space_state.intersect_shape(params)

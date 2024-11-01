class_name AutoScrollCamera
extends CameraControllerBase

@export var top_left: Vector2 = Vector2(-10, 10)
@export var bottom_right: Vector2 = Vector2(10, -10)
@export var autoscroll_speed: Vector3 = Vector3(1, 0, 1)  
@export var box_width:float = bottom_right.x - top_left.x
@export var box_height:float = top_left.y - bottom_right.y

var frame_position: Vector3
var already_switched:bool = false

func switch_camera_1() -> void:
	if !already_switched:
		rotation_degrees.x = -90
		frame_position = Vector3(%Vessel.position.x, dist_above_target, %Vessel.position.z)
		global_position = Vector3(%Vessel.position.x, dist_above_target, %Vessel.position.z)
		already_switched = true

func _process(delta: float) -> void:
	if %CameraSelector.current_controller == 1:
		switch_camera_1()
		frame_position.x += autoscroll_speed.x * delta
		global_position = frame_position

		if draw_camera_logic:
			draw_logic()
		super(delta)

		var frame_left = frame_position.x + top_left.x
		var frame_right = frame_position.x + bottom_right.x
		var frame_top = frame_position.z + top_left.y
		var frame_bottom = frame_position.z + bottom_right.y

		position.x = clamp(frame_left + top_left.x, 0, frame_right + bottom_right.x)
		position.z = clamp(frame_top + top_left.y, 0, frame_bottom + bottom_right.y)
		position.y = target.position.y + dist_above_target

		if target.position.x <= frame_left:
			target.position.x = frame_left + 0.1 
		elif target.position.x >= frame_right:
			target.position.x = frame_right - 0.1
	
		if target.position.z <= frame_bottom:
			target.position.z = frame_bottom + 0.1
		elif target.position.z >= frame_top:
			target.position.z = frame_top - 0.1

		frame_position.x += autoscroll_speed.x * delta
		global_position = frame_position

func draw_logic() -> void:

	if %CameraSelector.current_controller == 1:
		var mesh_instance := MeshInstance3D.new()
		var immediate_mesh := ImmediateMesh.new()
		var material := ORMMaterial3D.new()
		
		mesh_instance.mesh = immediate_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		var left:float = -box_width / 2
		var right:float = box_width / 2
		var top:float = -box_height / 2
		var bottom:float = box_height / 2
		
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_end()

		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.WHITE
		
		add_child(mesh_instance)
		mesh_instance.global_transform = Transform3D.IDENTITY
		mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)

		await get_tree().process_frame
		mesh_instance.queue_free()

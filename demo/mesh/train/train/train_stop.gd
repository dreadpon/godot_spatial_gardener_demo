extends Resource


enum StopType {STOP, SLOWDOWN}
@export var stop_type:int = StopType.STOP
@export var start_pos:float = 0.0
@export var end_pos:float = 0.0
@export var speed_limit:float = 0.0
@export var stop_duration:float = 0.0

@export var stop_applied:bool = false
@export var stop_time_left:float = 0.0

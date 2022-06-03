shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_burley, specular_schlick_ggx, depth_draw_alpha_prepass;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0);
uniform vec4 transmission : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float sway1_speed = 0.5;
uniform vec3 sway1_strength = vec3(1, 0.1, 1);
uniform float sway1_phase_len = 0.0;
uniform float sway1_time_offset_tile_size : hint_range(0.001, 2048, 0.0) = 10.0;


vec3 get_sway(vec3 vertex, float phase_len, float speed, vec3 strength, float time_offset) {
	float time_speed = (TIME + time_offset) * speed;
	
	return vec3(
		sin(vertex.x * phase_len * 1.123 + time_speed) * strength.x,
		sin(vertex.y * phase_len + time_speed * 1.12412) * strength.y,
		sin(vertex.z * phase_len * 0.9123 + time_speed * 1.3123) * strength.z);
}


void vertex() {
	vec3 world_pos = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float time_offset1 = length(world_pos / sway1_time_offset_tile_size);
	VERTEX += get_sway(VERTEX, sway1_phase_len, sway1_speed, COLOR.r * sway1_strength, time_offset1);
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	if (albedo.a * albedo_tex.a <= alpha_scissor_threshold) {
		discard;
	}
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	TRANSMISSION = transmission.rgb;
}
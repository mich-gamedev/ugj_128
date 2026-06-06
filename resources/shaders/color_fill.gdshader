shader_type canvas_item;

uniform vec4 fill_color: source_color = vec4(1,1,1,0);

void fragment() {
	COLOR = mix(COLOR, vec4(fill_color.rgb, COLOR.a), fill_color.a);
}
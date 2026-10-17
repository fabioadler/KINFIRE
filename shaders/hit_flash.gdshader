shader_type canvas_item;
// Pisca o sprite em uma cor sólida ao receber dano; também desenha contorno (elites/hover).

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(1.0, 0.2, 0.1, 0.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 col = tex * COLOR;
	if (outline_color.a > 0.0 && tex.a < 0.1) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float a = texture(TEXTURE, UV + vec2(px.x, 0.0)).a + texture(TEXTURE, UV - vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV + vec2(0.0, px.y)).a + texture(TEXTURE, UV - vec2(0.0, px.y)).a;
		if (a > 0.0) {
			col = outline_color;
		}
	}
	col.rgb = mix(col.rgb, flash_color.rgb, flash * step(0.1, tex.a));
	COLOR = col;
}

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void light() {
	LIGHT.rgb = vec3(0);
	if (LIGHT_COLOR == vec4(1)) {
		LIGHT = texture(SCREEN_TEXTURE, SCREEN_UV);
	}
}

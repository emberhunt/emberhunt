shader_type canvas_item;
render_mode unshaded;

void fragment()
{
	vec4 pixel_color = texture(TEXTURE, UV);
	pixel_color.r += 0.5;
	pixel_color.r /= 1.7;
	pixel_color.g /= 1.7;
	pixel_color.b /= 1.7;
	if (pixel_color.r > 1.0)
		pixel_color.r = 1.0;
	COLOR = pixel_color;
}
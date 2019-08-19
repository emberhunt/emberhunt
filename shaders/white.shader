shader_type canvas_item;
render_mode unshaded;

uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment()
{
	vec4 pixel_color = texture(TEXTURE, UV);
	pixel_color.r += strength;
	pixel_color.g += strength;
	pixel_color.b += strength;
	if (pixel_color.r > 1.0)
		pixel_color.r = 1.0;
	if (pixel_color.g > 1.0)
		pixel_color.g = 1.0;
	if (pixel_color.b > 1.0)
		pixel_color.b = 1.0;
	COLOR = pixel_color;
}
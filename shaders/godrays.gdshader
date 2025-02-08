shader_type canvas_item;
// copied from http://xnauk-randomchaosblogarchive.blogspot.com/2012/10/2d-crepuscular-god-rays.html

uniform sampler2D mask;

uniform vec2 lightScreenPosition;

uniform vec2 halfPixel;

uniform float Density = .5f;
uniform float Decay = .95f;
uniform float Weight = 1.0f;
uniform float Exposure = .15f;

uniform bool use_screen = false;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

const int NUM_SAMPLES = 64;

vec4 sample(sampler2D screen, sampler2D text, vec2 uv) {
	vec2 _uv = vec2(uv.x, 1.0-uv.y);
	if (use_screen) {
		return texture(screen, uv) * texture(mask, _uv).a;
	} else {
		return texture(text, uv) * texture(mask, _uv).a;
	}
}

void fragment()
{
	// Find light pixel position

	vec2 uv;
	if (use_screen) {
		uv = SCREEN_UV - halfPixel;
	} else {
		uv = UV - halfPixel;
	}

	vec2 DeltaTexCoord = (uv - lightScreenPosition);
	DeltaTexCoord *= (1.0f / float(NUM_SAMPLES) * Density);

	DeltaTexCoord = DeltaTexCoord ;

	vec4 _col = sample(SCREEN_TEXTURE, TEXTURE, uv);

	vec3 col = _col.rgb;
	float IlluminationDecay = 1.0;
	vec3 Sample;

	for( int i = 0; i < NUM_SAMPLES; ++i )
	{
		uv -= DeltaTexCoord;

		Sample = sample(SCREEN_TEXTURE, TEXTURE, uv).rgb;

		Sample *= IlluminationDecay * Weight;
		col += Sample;
		IlluminationDecay *= Decay;
	}

	COLOR = vec4(col * Exposure,_col.a);

}
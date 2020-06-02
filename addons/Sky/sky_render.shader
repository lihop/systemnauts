// This file contains two shaders released under different licenses.
// See the comments below for details.
shader_type canvas_item;


// Noise - gradient - 3D, from https://www.shadertoy.com/view/Xsl3Dl, copyright
// 2013 by Ingio Quilez, released under the MIT license.
vec3 hash(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 u = f * f * (3.0 - 2.0 * f);

  return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
                     dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
                     dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
             mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
                     dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
                     dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z );
}


// Stars (ltp), from https://www.shadertoy.com/view/wsKXDm by liutp,
// released under CC-BY-NC-SA 3.0.
vec2 rand2(vec2 p) {
	p = vec2(dot(p, vec2(12.9898, 78.233)), dot(p, vec2(26.65125, 83.054543)));
	return fract((sin(p)) * 43758.5453);
}

float rand(vec2 p) {
	return fract(sin(dot(p, vec2(54.0898, 18.233))) * 4337.5453);
}

float stars(in vec2 x, float num_cells, float size, float br) {
	vec2 n = x * num_cells;
	vec2 f = floor(n);
	
	float d = 1.0e10;
	for (int i = -1; i <= 1; ++i) {
		for (int j = -1; j <= 1; ++j) {
			vec2 g = f + vec2(float(i), float(j));
			g = n - g - rand2(mod(g, num_cells)) + rand(g);
			// Control size
			g *= 1. / (num_cells * size);
			d = min(d, dot(g, g));
		}
	}
	
	return br * (smoothstep(.95, 1., (1. - sqrt(d))));
}

uniform float stars_num = 32.;
uniform float stars_size = 0.025;
uniform float stars_bright = 2.0;
uniform vec3 stars_color = vec3(0., 1., 0.);

void fragment() {
	float theta = UV.y * 3.14159;
	float phi = UV.x * 3.14159 * 2.0;
	vec3 unit = vec3(0.0, 0.0, 0.0);
	
	unit.x = sin(phi) * sin(theta);
	unit.y = cos(theta) * -1.0;
	unit.z = cos(phi) * sin(theta);
	unit = normalize(unit);
	
	vec2 coord = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE);
	vec3 result = vec3(0.);
	result += stars(coord, stars_num, stars_size, stars_bright);
	
	COLOR.xyz = vec3(result);
	if (result.x > 0.) {
		COLOR.rgba = vec4(stars_color, result.x);
	}
}
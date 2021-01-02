#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform float rainStrength;

varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 color;

varying vec4 lmcoord;
varying vec2 texcoord;

const float wFlex = 2.8f; // Water flexing frequency
const float lFlex = 1.4f; // Leaves flexing frequency
const float pFlex = 1.8f; // Plants flexing frequency
const float hFlex = 1.2f; // Hardy plants flexing frequency

const float m = 0.05f; // Magnitude

const float pi = 3.14159f;

float wSin(float x, float frequency) {
	x = mod(x, 32.0f);
	return (32.0f - x) * x / 256.0f * sin(x * x * frequency / 48.0f);
}

void main() {

	float tick = frameTimeCounter;

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rgba;
	
	texcoord = gl_MultiTexCoord0.xy;
	
	vec4 coordPos = gl_Vertex;

	color = gl_Color.rgb;

	if (mc_Entity.x < 10107) {

		if (mc_Entity.x <= 10104 && mc_Entity.x >= 10100) {
			
			// Plants and crops
 			coordPos.xz += wSin(coordPos.y + coordPos.x + tick, pFlex + rainStrength) * m;
		
		} else if (mc_Entity.x == 10105 || mc_Entity.x == 10106) {
			
			// Leaves and vines
 			coordPos.xz += wSin(coordPos.y + coordPos.x + tick, lFlex + rainStrength) * m;
			coordPos.y += wSin(1.2f * coordPos.x + coordPos.z + tick, lFlex + rainStrength) * m * 0.5f;

		}

	} else {

		if (mc_Entity.x == 10300 || mc_Entity.x == 10107) {

			// Lily pads and water
			coordPos.y += 0.4f * wSin(coordPos.x + coordPos.z + tick, wFlex * 0.5f + rainStrength) * m;
			coordPos.y += 0.6f * wSin(coordPos.x - coordPos.z + tick, wFlex + rainStrength) * m;

		} else if (mc_Entity.x == 10108 || mc_Entity.x == 10109) {

			// Stems, saplings, and misc.
 			coordPos.xz += wSin(coordPos.y + coordPos.x + tick, hFlex + rainStrength) * m;

		} else if (mc_Entity.x == 10251 || mc_Entity.x == 10253) {

			// Soul Lantern and Lantern
			coordPos.x += (1.0f - fract(coordPos.y - 0.001f)) * wSin(tick + 1, hFlex * 0.73f) * m * 2.0f;
			coordPos.z += (1.0f - fract(coordPos.y - 0.001f)) * wSin(tick, hFlex) * m * 2.0f;
			coordPos.y += (0.982f - cos(fract(coordPos.z) - 0.5f)) + (0.982f - cos(fract(coordPos.x) - 0.5f)) * 1.3f;

		}

	}
	
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * coordPos);

	normal = normalize(gl_NormalMatrix * gl_Normal);

	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                          tangent.y, binormal.y, normal.y,
                          tangent.z, binormal.z, normal.z);
}

// NOTES //

// Unused samplers and *stuff* for some reason slow Optifine WAY down? Idk, just check if things are used or not
// Using optimized if-else trees are super valuable to bring the average # of comparisons down
// Took inspiration from BSL for lanterns, fract(x - 0.001) is gENIUS for finding the top of the block
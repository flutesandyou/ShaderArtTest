#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform sampler2D u_texture_0;
uniform vec2 u_resolution;

// Control parameters:

const float blurSize = 5.0;
const float distortionStrength = 0.002;
const float distortionFrequency = 1500.0;
const float noiseStrength = 0.3;
const int glitchLinesIterations = 5; // performance warning
const float glitchIntensity = 1.0;
const float aberration = 0.01;
const float brightness = 1.2;
const float contrast = 1.0;
const float saturation = 1.5;
const float ringingStrength = 0.5;  // Strength of ringing effect
const float ringingBlurAmount = 0.005;  // Blur amount for the ringing effect

// Random distribution function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Updated smoothLine function with asymmetric smoothing
float smoothLine(float edge0, float edge1, float x, float leftSmooth, float rightSmooth) {
    return smoothstep(edge0, edge0 + leftSmooth, x) - smoothstep(edge1 - rightSmooth, edge1, x);
}

// Sad Glitch lines effect function
vec3 GlitchLines(vec3 color, vec2 uv) {   
    for (int i = 0; i < glitchLinesIterations; i++) {
        float yPos = random(vec2(u_time * 0.1, float(i)));
        float xStart = random(vec2(u_time, float(i) + 20.0));
        float length = random(vec2(u_time * 0.1, float(i) + 20.0)) * 0.2; // Longer lines
        yPos = smoothstep(yPos + 0.1, 3.0, 0.8);
        float thickness = random(vec2(u_time * 0.0, float(i) + 20.0)) * 0.004 + 0.005;
        float leftSmooth = 0.02;
        float rightSmooth = 0.09;
        float line = smoothLine(xStart, xStart + length, uv.x, leftSmooth, rightSmooth) 
                     * smoothstep(thickness, 0.0, abs(uv.y - yPos));
        float fbrightness = random(vec2(u_time, float(i))) * 0.4 + 0.5;
        color = mix(color, vec3(fbrightness), line * glitchIntensity);
    }
    
    return color;
}

// Box blur function
vec4 boxBlur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.3333333333333333) * direction;
    color += texture2D(image, uv) * 0.29411764705882354;
    color += texture2D(image, uv + (off1 / resolution) * blurSize) * 0.35294117647058826;
    color += texture2D(image, uv - (off1 / resolution) * blurSize) * 0.35294117647058826;
    return color;
}

// Edge detection for ringing effect (Sobel operator)
vec3 edgeDetection(vec2 uv) {
    float xKernel[9];
    float yKernel[9];
    
    xKernel[0] = -1.0; xKernel[1] = 0.0; xKernel[2] = 1.0;
    xKernel[3] = -2.0; xKernel[4] = 0.0; xKernel[5] = 2.0;
    xKernel[6] = -1.0; xKernel[7] = 0.0; xKernel[8] = 1.0;
    
    yKernel[0] = -1.0; yKernel[1] = -2.0; yKernel[2] = -1.0;
    yKernel[3] =  0.0; yKernel[4] =  0.0; yKernel[5] =  0.0;
    yKernel[6] =  1.0; yKernel[7] =  2.0; yKernel[8] =  1.0;
    
    float offset = 1.0 / u_resolution.x;
    
    vec3 tex[9];
    tex[0] = texture2D(u_texture_0, uv + vec2(-offset, -offset)).rgb;
    tex[1] = texture2D(u_texture_0, uv + vec2( 0.0,   -offset)).rgb;
    tex[2] = texture2D(u_texture_0, uv + vec2( offset, -offset)).rgb;
    tex[3] = texture2D(u_texture_0, uv + vec2(-offset,  0.0  )).rgb;
    tex[4] = texture2D(u_texture_0, uv).rgb;
    tex[5] = texture2D(u_texture_0, uv + vec2( offset,  0.0  )).rgb;
    tex[6] = texture2D(u_texture_0, uv + vec2(-offset,  offset)).rgb;
    tex[7] = texture2D(u_texture_0, uv + vec2( 0.0,    offset)).rgb;
    tex[8] = texture2D(u_texture_0, uv + vec2( offset,  offset)).rgb;

    vec3 edgeX = vec3(0.0);
    vec3 edgeY = vec3(0.0);

    for(int i = 0; i < 9; i++) {
        edgeX += tex[i] * xKernel[i];
        edgeY += tex[i] * yKernel[i];
    }

    return sqrt(edgeX * edgeX + edgeY * edgeY); // Magnitude of gradient
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Apply horizontal and vertical box blur
    vec4 blurredH = boxBlur(u_texture_0, uv, u_resolution, vec2(1.0, 0.0));
    vec4 blurredHV = boxBlur(u_texture_0, uv, u_resolution, vec2(0.0, 1.0));
    vec3 blurredColor = mix(blurredH.rgb, blurredHV.rgb, 0.5);
    
    // Distortion effect
    float distortionOffset = sin(uv.y * distortionFrequency) * distortionStrength;
    vec2 distortedUV = vec2(uv.x + distortionOffset, uv.y);
    
    // Color noise effect
    vec2 timeOffsetUV = distortedUV + u_time;
    vec3 noise = vec3(
        random(timeOffsetUV),
        random(timeOffsetUV + 1.0),
        random(timeOffsetUV + 2.0)
    );
  
    // Aberration effect
    vec2 dir = uv - 0.5;
    vec3 r = boxBlur(u_texture_0, distortedUV - dir * aberration, u_resolution, vec2(1.0, 0.0)).rgb;
    vec3 g = blurredColor;
    vec3 b = boxBlur(u_texture_0, distortedUV + dir * aberration, u_resolution, vec2(0.0, 1.0)).rgb;
    vec3 color = vec3(r.r, g.g, b.b);

    // Apply Multiply blending for Noise
    color = color * (1.0 - noiseStrength) + color * noise * noiseStrength;
    
    // Apply glitch effect
    color = GlitchLines(color, uv);
    
    // Add the VHS Ringing Effect:
    vec3 edges = edgeDetection(uv);
    vec3 ringingEffect = color + edges * ringingStrength;
    vec3 ringingBlur = texture2D(u_texture_0, uv + vec2(ringingBlurAmount)).rgb;
    color = mix(ringingEffect, ringingBlur, 0.5);
    
    // Brightness adjustment
    color *= brightness;

    // Contrast adjustment
    color = (color - 0.5) * contrast + 0.5;

    // Saturation adjustment
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, saturation);

    gl_FragColor = vec4(color, 1.0);
}

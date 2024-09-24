#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform sampler2D u_texture_0;
uniform vec2 u_resolution;

// Improved random function for better distribution
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// Updated smoothLine function with asymmetric smoothing
float smoothLine(float edge0, float edge1, float x, float leftSmooth, float rightSmooth) {
    return smoothstep(edge0, edge0 + leftSmooth, x) - smoothstep(edge1 - rightSmooth, edge1, x);
}

vec3 GlitchLines(vec3 color, vec2 uv) {
    float glitchIntensity = 1.0;
    
    for (int i = 0; i < 5; i++) {
        // Random position and length for each line
        float yPos = random(vec2(u_time * 0.1, float(i)));
        float xStart = random(vec2(u_time, float(i) + 20.0));
        float length = random(vec2(u_time * 0.1, float(i) + 20.0)) * 0.2; // Longer lines
        
        // Concentrate lines towards the bottom
        yPos = smoothstep(yPos + 0.1, 3.0, 0.8);
        
        // Vary line thickness
        float thickness = random(vec2(u_time * 0.0, float(i) + 20.0)) * 0.004 + 0.005;
        
        // Control smoothness on each side
        float leftSmooth = 0.02;
        float rightSmooth = 0.09;
        
        // Create a smooth line with varied thickness and asymmetric smoothing
        float line = smoothLine(xStart, xStart + length, uv.x, leftSmooth, rightSmooth) 
                     * smoothstep(thickness, 0.0, abs(uv.y - yPos));
        
        // Vary line brightness
        float brightness = random(vec2(u_time, float(i))) * 0.4 + 0.5;
        
        // Apply the line to the color
        color = mix(color, vec3(brightness), line * glitchIntensity);
    }
    
    return color;
}
vec4 boxBlur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
    float blurSize = 3.0; // Adjust this value to change blur intensity
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.3333333333333333) * direction;
    color += texture2D(image, uv) * 0.29411764705882354;
    color += texture2D(image, uv + (off1 / resolution) * blurSize) * 0.35294117647058826;
    color += texture2D(image, uv - (off1 / resolution) * blurSize) * 0.35294117647058826;
    return color;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Apply horizontal box blur
    vec4 blurredH = boxBlur(u_texture_0, uv, u_resolution, vec2(1.0, 0.0));
    
    // Apply vertical box blur
    vec4 blurredHV = boxBlur(u_texture_0, uv, u_resolution, vec2(0.0, 1.0));
    
    // Combine horizontal and vertical blurs
    vec3 blurredColor = mix(blurredH.rgb, blurredHV.rgb, 0.5);
    
    // ---- DISTORTION EFFECT ----
    float distortionStrength = 0.002;
    float distortionFrequency = 1500.0;
    float distortionOffset = sin(uv.y * distortionFrequency) * distortionStrength;
    vec2 distortedUV = vec2(uv.x + distortionOffset, uv.y);
    
    // ---- COLOR NOISE EFFECT ----
    float noiseStrength = 0.3;
    vec2 timeOffsetUV = distortedUV + u_time;
    vec3 noise = vec3(
        random(timeOffsetUV),
        random(timeOffsetUV + 1.0),
        random(timeOffsetUV + 2.0)
    );
  
    // ---- ABERRATION EFFECT ----
    float aberration = 0.01;
    vec2 dir = uv - 0.5;

    // Sample the blurred texture with offset for each color channel
    vec3 r = boxBlur(u_texture_0, distortedUV - dir * aberration, u_resolution, vec2(1.0, 0.0)).rgb;
    vec3 g = blurredColor;
    vec3 b = boxBlur(u_texture_0, distortedUV + dir * aberration, u_resolution, vec2(0.0, 1.0)).rgb;
        
    // Combine the color channels (aberration)
    vec3 color = vec3(r.r, g.g, b.b);

    // Add noise Multiply blending
    color = color * (1.0 - noiseStrength) + color * noise * noiseStrength;
    
    // Apply glitch effect
    color = GlitchLines(color, uv);

    // Apply brightness, contrast, and saturation
    float brightness = 1.2;
    float contrast = 1.0;
    float saturation = 1.5;
    
    // Brightness adjustment
    color *= brightness;

    // Contrast adjustment
    color = (color - 0.5) * contrast + 0.5;

    // Saturation adjustment
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, saturation);

    gl_FragColor = vec4(color, 1.0);
}
#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform sampler2D u_texture; // Declare the texture sampler
uniform vec2 u_resolution;   // Resolution of the screen

// Simple pseudo-random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Chromatic aberration settings
    float aberration = 0.02;
    vec2 dir = uv - 0.5;
    
    // ---- START OF DISTORTION EFFECT ----
    float distortionStrength = 0.002;
    float distortionFrequency = 1500.0;
    float distortionOffset = sin(uv.y * distortionFrequency) * distortionStrength;
    vec2 distortedUV = vec2(uv.x + distortionOffset, uv.y);
    // ---- END OF DISTORTION EFFECT ----
    
    // ---- START OF COLOR NOISE EFFECT ----
    float noiseStrength = 0.1; // Adjust for more/less noise
    vec3 noise = vec3(
        random(distortedUV + u_time),
        random(distortedUV + u_time + 1.0),
        random(distortedUV + u_time + 2.0)
    );
    // ---- END OF COLOR NOISE EFFECT ----
    
    // Sample the texture with offset for each color channel
    vec4 r = texture2D(u_texture, distortedUV - dir * aberration);
    vec4 g = texture2D(u_texture, distortedUV);
    vec4 b = texture2D(u_texture, distortedUV + dir * aberration);
    
    // Combine the color channels and add noise
    vec3 color = vec3(r.r, g.g, b.b);
    color = mix(color, noise, noiseStrength);
    
    gl_FragColor = vec4(color, 1.0);
}

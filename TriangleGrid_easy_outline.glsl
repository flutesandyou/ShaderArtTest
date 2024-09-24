#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
const float gridSize = 10.0;
const float SQRT_2 = 1.4142135623730951;
const float lineThickness = 0.02;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;

    float aspectRatio = u_resolution.x / u_resolution.y;

    uv.x *= aspectRatio * sqrt(3.0);

    float angle = radians(135.0);
    mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 height = vec2(0.0, 1.0);
    uv = (uv - 0.5) * rotationMatrix + 0.5;

    vec2 gridUV = uv * gridSize;
    vec2 cell = floor(gridUV);
    vec2 localUV = fract(gridUV); // local coords

    float distToVerticalEdge = min(localUV.x, 1.0 - localUV.x);
    float distToHorizontalEdge = min(localUV.y, 1.0 - localUV.y);

    float distToDiagonal = abs(localUV.x + localUV.y - 1.0);
    float minDistToEdge = min(min(distToVerticalEdge, distToHorizontalEdge), distToDiagonal);

    float diagonal = localUV.x + localUV.y;

    vec3 yellowColor = vec3(0.9608, 0.9608, 0.0078);
    vec3 blueColor = vec3(0.0, 0.5, 1.0);
    float t = step(1.0, diagonal);
    vec3 triangleColor = mix(blueColor, yellowColor, t);

    float isEdge = step(minDistToEdge, lineThickness);
    vec3 color = mix(triangleColor, vec3(0.0), isEdge);

    gl_FragColor = vec4(color, 1.0);
}
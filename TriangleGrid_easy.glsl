
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution; // разрешение экрана
const float gridSize = 10.0;
const float SQRT_2 = 1.4142135623730951;

void main() {
    // Нормализованные координаты фрагмента
    vec2 uv = gl_FragCoord.xy / u_resolution;

    // Соотношение сторон экрана
    float aspectRatio = u_resolution.x / u_resolution.y;

    uv.x *= aspectRatio * sqrt(3.0);

    float angle = radians(135.0);
    mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 height = vec2(0.0, 1.0);
    uv = (uv - 0.5) * rotationMatrix + 0.5;

    // Преобразуем uv в систему координат сетки
    vec2 gridUV = uv * gridSize;
    vec2 cell = floor(gridUV);
    vec2 localUV = fract(gridUV); // локальные координаты внутри ячейки

    // Определение треугольников
    float diagonal = localUV.x + localUV.y;

    vec3 yellowColor = vec3(1.0, 1.0, 0.0);
    vec3 blueColor = vec3(0.0, 0.5, 1.0);
    float t = step(1.0, diagonal);
    vec3 triangleColor = mix(blueColor, yellowColor, t);

    gl_FragColor = vec4(triangleColor, 1.0);
}

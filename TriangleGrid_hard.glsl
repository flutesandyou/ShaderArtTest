#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution; // разрешение экрана
const float gridSize = 10.0;
    
void main() {
    // Нормализованные координаты фрагмента
    vec2 uv = gl_FragCoord.xy / u_resolution;

    // Соотношение сторон экрана
    float aspectRatio = u_resolution.x / u_resolution.y;

    // Корректируем uv, чтобы сохранить пропорции квадратов
    uv.x *= aspectRatio;

    vec2 gridUV = uv * gridSize;
    vec2 cell = floor(gridUV);
    vec2 localUV = fract(gridUV); // локальные координаты внутри ячейки

    // Определение треугольников
    float diagonal = localUV.x + localUV.y;

    vec3 yellowColor = vec3(0.0, 0.5, 1.0);
    vec3 blueColor = vec3(1.0, 1.0, 0.0);
    float t = step(1.0, diagonal);
    vec3 triangleColor = mix(yellowColor, blueColor, t);

    gl_FragColor = vec4(triangleColor, 1.0);
}


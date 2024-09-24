#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution; // разрешение экрана
const float SQRT_2 = 1.4142135623730951;

const float gridSize = 10.0;
const float lineThickness = 0.02; // толщина контура

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

    // Определение расстояний до границ
    float distToVerticalEdge = min(localUV.x, 1.0 - localUV.x);
    float distToHorizontalEdge = min(localUV.y, 1.0 - localUV.y);
    
    // Определение расстояния до диагонали

    float distToDiagonal = abs(localUV.x + localUV.y - 1.0) / SQRT_2;
    
    // Находим минимальное расстояние до любой границы (вертикальные, горизонтальные или диагональ)
    float minDistToEdge = min(min(distToVerticalEdge, distToHorizontalEdge), distToDiagonal);

    // Определение треугольников (желтый или синий)
    float diagonal = localUV.x + localUV.y;
    
    vec3 yellowColor = vec3(0.0, 0.5, 1.0);
    vec3 blueColor = vec3(1.0, 1.0, 0.0);
    float t = step(1.0, diagonal);
    vec3 triangleColor = mix(yellowColor, blueColor, t);

    // Черный контур
    float isEdge = step(minDistToEdge, lineThickness);
    vec3 color = mix(triangleColor, vec3(0.0), isEdge);

    gl_FragColor = vec4(color, 1.0);
}


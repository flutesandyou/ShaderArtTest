This is test assignment.

usage:
1. Open workspace in VS Code
ShaderArtTest.code-workspace

2. Use glsl-canvas VS Code estension
https://marketplace.visualstudio.com/items?itemName=circledev.glsl-canvas

3. Press Shift+P, type Show glslCanvas

4. Select different glsl files to see results.

notes:
I used consts for params instead of uniforms just for convenience
IO buffers are buggy and FBO's aren't supported in glsl-canvas vs code extension so I didn't implement off-screen passes to calc edge detection.

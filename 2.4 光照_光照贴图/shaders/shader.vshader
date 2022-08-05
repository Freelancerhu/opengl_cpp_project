#version 330 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTexture;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 viewPos;

out vec3 Normal;
out vec3 FragPos;
out vec3 Viewpos;
out vec2 TexCoords;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    FragPos = vec3(model * vec4(aPos, 1.0));  // 算出各个顶点在世界坐标的位置
    Normal = mat3(transpose(inverse(model))) * aNormal;  // 法线方向
    Viewpos = viewPos; // 观察者位置，用来计算镜面反射
    TexCoords = aTexture;  // 材质的坐标
}
#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

uniform sampler2D ourTexture0;
uniform sampler2D ourTexture1;
uniform float textureValue;

void main()
{
    FragColor = mix(texture(ourTexture0, TexCoord), texture(ourTexture1, TexCoord), textureValue);
}
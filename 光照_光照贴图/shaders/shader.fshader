#version 330 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    sampler2D emission;
    float shininess;
};

struct Light {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    vec3 lightPos;
};

in vec3 Normal;
in vec3 FragPos;
in vec3 Viewpos;
in vec2 TexCoords;

out vec4 FragColor;

uniform vec3 objectColor;
uniform Material material;
uniform Light light;

void main()
{
    // 环境光
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));

    // 法线算出的漫反射
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));

    // 镜面反射
    vec3 viewDir = normalize(Viewpos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 320);
    vec3 specular = light.specular * vec3(texture(material.specular, TexCoords)) * spec;

    // 自发光
    vec3 emission = vec3(texture(material.emission, TexCoords));

    FragColor = vec4((ambient + diffuse + specular) * objectColor, 1.0) + vec4(emission, 1.0f);
}

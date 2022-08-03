#version 330 core
struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
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

out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform Material material;
uniform Light light;

void main()
{
    // ������
    vec3 ambient = light.ambient * material.ambient * lightColor;

    // ���������������
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = (light.diffuse * diff * material.diffuse) * lightColor;

    // ���淴��
    vec3 viewDir = normalize(Viewpos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 320);
    vec3 specular = light.specular * material.specular * spec * lightColor;

    FragColor = vec4((ambient + diffuse + specular) * objectColor, 1.0);
}

#version 330 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light {
    vec3  position;
    vec3  direction;
    float cutOff;
    float outerCutOff;
    // vec3 lightPos;  // ���Դ

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;

out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 Viewpos;
uniform Material material;
uniform Light light;

void main()
{
    float distance = length(light.position - FragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    
    vec3 lightDir = normalize(light.position - FragPos);
    float theta     = dot(lightDir, normalize(-light.direction));
    float epsilon   = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);  
        // ִ�й��ռ���
    // ������
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
    ambient *= attenuation;

    // ���������������
    vec3 norm = normalize(Normal);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
    diffuse *= attenuation;
    diffuse *= intensity;

    // ���淴��
    vec3 viewDir = normalize(Viewpos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 320);
    vec3 specular = light.specular * vec3(texture(material.specular, TexCoords)) * spec;
    specular *= attenuation;
    specular *= intensity;

    // �Է���
    // vec3 emission = vec3(texture(material.emission, TexCoords));
    // FragColor = vec4((ambient + diffuse + specular) * objectColor, 1.0) + vec4(emission, 1.0f);

    FragColor = vec4((ambient + diffuse + specular) * objectColor, 1.0);

}

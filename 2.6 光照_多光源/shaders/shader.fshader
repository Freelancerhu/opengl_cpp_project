#version 330 core
out vec4 FragColor;

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

uniform Material material;

//uniform vec3 objectColor;
uniform vec3 Viewpos;
// uniform Light light;

struct DirLight {
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};  
uniform DirLight dirLight;
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);

struct PointLight {
    vec3 position;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};  
#define NR_POINT_LIGHTS 4
uniform PointLight pointLights[NR_POINT_LIGHTS];
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

struct FlashLight {
    sampler2D diffuseTexture;

    vec3  position;
    vec3  direction;
    float cutOff;
    float outerCutOff;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};  
uniform FlashLight flashLight;
vec3 CalcFlashLight(FlashLight light, vec3 normal, vec3 viewDir, vec3 FragPos);


void main()
{
    // ����
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(Viewpos - FragPos);

    // ����һ�������ɫֵ
    vec3 output;
    // �������Ĺ��׼ӵ������
    output += CalcDirLight(dirLight, norm, viewDir);

    // �����еĵ��ԴҲ����ͬ������
    for(int i = 0; i < NR_POINT_LIGHTS; ++i)
        output += CalcPointLight(pointLights[i], norm, FragPos, viewDir);

    // Ҳ���������Ĺ�Դ������۹⣩
    output += CalcFlashLight(flashLight, norm, viewDir, FragPos);

    FragColor = vec4(output, 1.0);
}

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction);
    // ��������ɫ
    float diff = max(dot(normal, lightDir), 0.0);
    // �������ɫ
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // �ϲ����
    vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords));
    vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    return (ambient + diffuse + specular);
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir) {
    float distance = length(light.position - FragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    vec3 lightDir = normalize(light.position - FragPos);
    // ��������ɫ
    float diff = max(dot(normal, lightDir), 0.0);
    // �������ɫ
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // �ϲ����
    vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords)) * attenuation;
    vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords)) * attenuation;
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords)) * attenuation;
    return (ambient + diffuse + specular);
}

vec3 CalcFlashLight(FlashLight light, vec3 normal, vec3 viewDir, vec3 FragPos) {
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
    vec3 norm = normalize(normal);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(light.diffuseTexture, TexCoords));
    diffuse *= attenuation;
    diffuse *= intensity;

    // ���淴��
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 320);
    vec3 specular = light.specular * vec3(texture(material.specular, TexCoords)) * spec;
    specular *= attenuation;
    specular *= intensity;

    return (ambient + diffuse + specular);
}

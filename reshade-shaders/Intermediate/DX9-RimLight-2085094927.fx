#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\RimLight.fx"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reshade.fxh"
#line 20
namespace ReShade
{
#line 31
static const float AspectRatio = 1920 * (1.0 / 1080);
static const float2 PixelSize = float2((1.0 / 1920), (1.0 / 1080));
static const float2 ScreenSize = float2(1920, 1080);
#line 37
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 40
sampler BackBuffer { Texture = BackBufferTex; };
sampler DepthBuffer { Texture = DepthBufferTex; };
#line 44
float GetLinearizedDepth(float2 texcoord)
{
#line 49
float depth = tex2Dlod(DepthBuffer, float4(texcoord, 0, 0)).x;
#line 58
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 61
return depth;
}
}
#line 66
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 73
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 78
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\RimLight.fx"
#line 21
uniform float3 Color <
ui_label = "Rim Light Color";
ui_tooltip = "Adjust rim light tint";
ui_type = "color";
> = float3(1, 1, 1);
#line 27
uniform bool Debug <
ui_label = "Display Normal Map Pass";
ui_tooltip = "Surface vector angle color map";
ui_category = "Debug Tools";
ui_category_closed = true;
> = false;
#line 34
uniform bool CustomFarPlane <
ui_label = "Custom Far Plane";
ui_tooltip = "Enable custom far plane display outside debug view";
ui_category = "Debug Tools";
> = true;
#line 40
uniform float FarPlane <
ui_label = "Depth Far Plane Preview";
ui_tooltip = "Adjust this option for proper normal map display\n"
"and change preprocessor definitions, so that\n"
"RESHADE_DEPTH_LINEARIZATION_FAR_PLANE = Your_Value";
ui_type = "slider";
ui_min = 0; ui_max = 1000; ui_step = 1;
ui_category = "Debug Tools";
> = 1000.0;
#line 56
float Overlay(float Layer)
{
const float MinLayer = min(Layer, 0.5);
const float MaxLayer = max(Layer, 0.5);
return 2 * (MinLayer * MinLayer + 2 * MaxLayer - MaxLayer * MaxLayer) - 1.5;
}
#line 64
float GetDepth(float2 TexCoord)
{
float depth;
if(Debug || CustomFarPlane)
{
#line 73
depth = tex2Dlod(ReShade::DepthBuffer, float4(TexCoord, 0, 0)).x;
#line 83
depth /= FarPlane - depth * (FarPlane - 1.0);
}
else
{
depth = ReShade::GetLinearizedDepth(TexCoord);
}
return depth;
}
#line 93
float3 NormalVector(float2 TexCoord)
{
const float3 offset = float3(ReShade::PixelSize.xy, 0.0);
const float2 posCenter = TexCoord.xy;
const float2 posNorth = posCenter - offset.zy;
const float2 posEast = posCenter + offset.xz;
#line 100
const float3 vertCenter = float3(posCenter - 0.5, 1) * GetDepth(posCenter);
const float3 vertNorth = float3(posNorth - 0.5, 1) * GetDepth(posNorth);
const float3 vertEast = float3(posEast - 0.5, 1) * GetDepth(posEast);
#line 104
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 112
void RimLightPS(in float4 position : SV_Position, in float2 TexCoord : TEXCOORD, out float3 color : SV_Target)
{
const float3 NormalPass = NormalVector(TexCoord);
#line 116
if(Debug) color = NormalPass;
else
{
color = cross(NormalPass, float3(0.5, 0.5, 1.0));
const float rim = max(max(color.x, color.y), color.z);
color = tex2D(ReShade::BackBuffer, TexCoord).rgb;
color += Color * Overlay(rim);
}
}
#line 131
technique RimLight < ui_label = "Rim Light"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = RimLightPS;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Tonemap.fx"
#line 7
uniform float Gamma <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Adjust midtones. 1.0 is neutral. This setting does exactly the same as the one in Lift Gamma Gain, only with less control.";
> = 1.0;
uniform float Exposure <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "Adjust exposure";
> = 0.0;
uniform float Saturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "Adjust saturation";
> = 0.0;
#line 23
uniform float Bleach <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Brightens the shadows and fades the colors";
> = 0.0;
#line 29
uniform float Defog <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "How much of the color tint to remove";
> = 0.0;
uniform float3 FogColor <
ui_type = "color";
ui_label = "Defog Color";
ui_tooltip = "Which color tint to remove";
> = float3(0.0, 0.0, 1.0);
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ReShade.fxh"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Tonemap.fx"
#line 43
float3 TonemapPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
color = saturate(color - Defog * FogColor * 2.55); 
color *= pow(2.0f, Exposure); 
color = pow(color, Gamma); 
#line 50
const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
float lum = dot(coefLuma, color);
#line 53
const float L = saturate(10.0 * (lum - 0.45));
const float3 A2 = Bleach * color;
#line 56
const float3 result1 = 2.0f * color * lum;
const float3 result2 = 1.0f - 2.0f * (1.0f - lum) * (1.0f - color);
#line 59
const float3 newColor = lerp(result1, result2, L);
const float3 mixRGB = A2 * newColor;
color += ((1.0f - A2) * mixRGB);
#line 63
const float3 middlegray = dot(color, (1.0 / 3.0));
const float3 diffcolor = color - middlegray;
#line 66
return (color + diffcolor * Saturation) / (1 + (diffcolor * Saturation)); 
}
#line 69
technique Tonemap
{
pass
{
VertexShader = PostProcessVS;
PixelShader = TonemapPass;
}
}

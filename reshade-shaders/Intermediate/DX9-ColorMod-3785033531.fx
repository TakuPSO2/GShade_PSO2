#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorMod.fx"
#line 7
uniform float ColormodChroma <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Saturation";
ui_tooltip = "Amount of saturation";
> = 0.780;
#line 14
uniform float ColormodGammaR <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Gamma for Red";
ui_tooltip = "Gamma for Red";
> = 1.0;
uniform float ColormodGammaG <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Gamma for Green";
ui_tooltip = "Gamma for Green";
> = 1.0;
uniform float ColormodGammaB <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Gamma for Blue";
ui_tooltip = "Gamma for Blue";
> = 1.0;
#line 33
uniform float ColormodContrastR <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Contrast for Red";
ui_tooltip = "Contrast for Red";
> = 0.50;
uniform float ColormodContrastG <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Contrast for Green";
ui_tooltip = "Contrast for Green";
> = 0.50;
uniform float ColormodContrastB <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Contrast for Blue";
ui_tooltip = "Contrast for Blue";
> = 0.50;
#line 52
uniform float ColormodBrightnessR <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Brightness for Red";
ui_tooltip = "Brightness for Red";
> = -0.08;
uniform float ColormodBrightnessG <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Brightness for Green";
ui_tooltip = "Brightness for Green";
> = -0.08;
uniform float ColormodBrightnessB <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_label = "Brightness for Blue";
ui_tooltip = "Brightness for Blue";
> = -0.08;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorMod.fx"
#line 78
float3 ColorModPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 82
color.xyz = (color.xyz - dot(color.xyz, 0.333)) * ColormodChroma + dot(color.xyz, 0.333);
color.xyz = saturate(color.xyz);
color.x = (pow(color.x, ColormodGammaR) - 0.5) * ColormodContrastR + 0.5 + ColormodBrightnessR;
color.y = (pow(color.y, ColormodGammaG) - 0.5) * ColormodContrastG + 0.5 + ColormodBrightnessB;
color.z = (pow(color.z, ColormodGammaB) - 0.5) * ColormodContrastB + 0.5 + ColormodBrightnessB;
return color.rgb;
}
#line 91
technique ColorMod
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColorModPass;
}
}

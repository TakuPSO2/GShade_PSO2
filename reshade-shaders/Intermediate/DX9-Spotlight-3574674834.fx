#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Spotlight.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Spotlight.fx"
#line 11
uniform float uXCenter <
ui_label = "X Position";
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "X coordinate of beam center. Axes start from upper left screen corner.";
> = 0;
#line 18
uniform float uYCenter <
ui_label = "Y Position";
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "Y coordinate of beam center. Axes start from upper left screen corner.";
> = 0;
#line 25
uniform float uBrightness <
ui_label = "Brightness";
ui_tooltip =
"Spotlight halo brightness.\n"
"\nDefault: 10.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 0.01;
> = 10.0;
#line 36
uniform float uSize <
ui_label = "Size";
ui_tooltip =
"Spotlight halo size in pixels.\n"
"\nDefault: 420.0";
ui_type = "slider";
ui_min = 10.0;
ui_max = 1000.0;
ui_step = 1.0;
> = 420.0;
#line 47
uniform float3 uColor <
ui_label = "Color";
ui_tooltip =
"Spotlight halo color.\n"
"\nDefault: R:255 G:230 B:200";
ui_type = "color";
> = float3(255, 230, 200) / 255.0;
#line 55
uniform float uDistance <
ui_label = "Distance";
ui_tooltip =
"The distance that the spotlight can illuminate.\n"
"Only works if the game has depth buffer access.\n"
"\nDefault: 0.1";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.1;
#line 67
uniform bool uBlendFix <
ui_label = "Toggle Blend Fix";
ui_tooltip = "Enable to use the original blending mode.";
> = 0;
#line 72
uniform bool uToggleTexture <
ui_label = "Toggle Texture";
ui_tooltip = "Enable or disable the spotlight texture.";
> = 1;
#line 77
uniform bool uToggleDepth <
ui_label = "Toggle Depth";
ui_tooltip = "Enable or disable depth.";
> = 1;
#line 82
sampler2D sColor {
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
MinFilter = POINT;
MagFilter = POINT;
};
#line 91
float4 PS_Spotlight(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
const float2 res = ReShade::ScreenSize;
const float2 uCenter = uv - float2(uXCenter, -uYCenter);
float2 coord = res * uCenter;
#line 96
float halo = distance(coord, res * 0.5);
float spotlight = uSize - min(halo, uSize);
spotlight /= uSize;
#line 102
if (uToggleTexture == 0)
{
float defects = sin(spotlight * 30.0) * 0.5 + 0.5;
defects = lerp(defects, 1.0, spotlight * 2.0);
#line 107
static const float contrast = 0.125;
#line 109
defects = 0.5 * (1.0 - contrast) + defects * contrast;
spotlight *= defects * 4.0;
}
else
{
spotlight *= 2.0;
}
#line 117
if (uToggleDepth == 1)
{
float depth = 1.0 - ReShade::GetLinearizedDepth(uv);
depth = pow(abs(depth), 1.0 / uDistance);
spotlight *= depth;
}
#line 124
float3 colored_spotlight = spotlight * uColor;
colored_spotlight *= colored_spotlight * colored_spotlight;
#line 127
float3 result = 1.0 + colored_spotlight * uBrightness;
#line 129
float3 color = tex2D(sColor, uv).rgb;
color *= result;
#line 132
if (!uBlendFix)
#line 134
color = max(color, (result - 1.0) * 0.001);
#line 136
return float4(color, 1.0);
}
#line 139
technique Spotlight {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Spotlight;
SRGBWriteEnable = true;
}
}

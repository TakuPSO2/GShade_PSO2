#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorInversion.fx"
#line 32
uniform int nInversionSelector <
ui_type = "combo";
ui_items = "All\0Red\0Green\0Blue\0Red & Green\0Red & Blue\0Green & Blue\0None\0";
ui_label = "The color(s) to invert.";
> = 0;
#line 38
uniform float nInversionRed <
ui_type = "slider";
ui_label = "Red";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 46
uniform float nInversionGreen <
ui_type = "slider";
ui_label = "Green";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 54
uniform float nInversionBlue <
ui_type = "slider";
ui_label = "Blue";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorInversion.fx"
#line 64
float4 SV_ColorInversion(float4 pos : SV_Position, float2 col : TEXCOORD) : SV_TARGET
{
float4 inversion = tex2D(ReShade::BackBuffer, col);
inversion.r = inversion.r * nInversionRed;
inversion.g = inversion.g * nInversionGreen;
inversion.b = inversion.b * nInversionBlue;
if (nInversionSelector == 0)
{
inversion.r = 1.0f - inversion.r;
inversion.g = 1.0f - inversion.g;
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 1)
{
inversion.r = 1.0f - inversion.r;
}
else if (nInversionSelector == 2)
{
inversion.g = 1.0f - inversion.g;
}
else if (nInversionSelector == 3)
{
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 4)
{
inversion.r = 1.0f - inversion.r;
inversion.g = 1.0f - inversion.g;
}
else if (nInversionSelector == 5)
{
inversion.r = 1.0f - inversion.r;
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 6)
{
inversion.g = 1.0f - inversion.g;
inversion.b = 1.0f - inversion.b;
}
else
{
return inversion;
}
return inversion;
}
#line 110
technique ColorInversion
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SV_ColorInversion;
}
}

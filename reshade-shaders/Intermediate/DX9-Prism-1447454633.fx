#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Prism.fx"
#line 24
uniform int Aberration <
ui_label = "Aberration scale in pixels";
ui_type = "slider";
ui_min = -48; ui_max = 48;
> = 6;
#line 30
uniform float Curve <
ui_label = "Aberration curve";
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0; ui_step = 0.01;
> = 1.0;
#line 36
uniform bool Automatic <
ui_label = "Automatic sample count";
ui_tooltip = "Amount of samples will be adjusted automatically";
ui_category = "Performance";
ui_category_closed = true;
> = true;
#line 43
uniform int SampleCount <
ui_label = "Samples";
ui_tooltip = "Amount of samples (only even numbers are accepted, odd numbers will be clamped)";
ui_type = "slider";
ui_min = 6; ui_max = 32;
ui_category = "Performance";
> = 8;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Prism.fx"
#line 59
float3 Spectrum(float Hue)
{
const float Hue4 = Hue * 4.0;
float3 HueColor = abs(Hue4 - float3(1.0, 2.0, 1.0));
HueColor = saturate(1.5 - HueColor);
HueColor.xz += saturate(Hue4 - 3.5);
HueColor.z = 1.0 - HueColor.z;
return HueColor;
}
#line 70
sampler SamplerColor
{
Texture = ReShade::BackBufferTex;
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 77
void ChromaticAberrationPS(float4 vois : SV_Position, float2 texcoord : TexCoord, out float3 BluredImage : SV_Target)
{
#line 80
const float Aspect = ReShade::AspectRatio;
#line 82
const float Pixel = ReShade::PixelSize.y;
#line 86
float Samples;
if (Automatic)
Samples = max(6.0, 2.0 * ceil(abs(Aberration) * 0.5) + 2.0);
else
Samples = floor(SampleCount * 0.5) * 2.0;
#line 92
Samples = min(Samples, 48 );
#line 94
const float Sample = 1.0 / Samples;
#line 97
float2 RadialCoord = texcoord - 0.5;
RadialCoord.x *= Aspect;
#line 101
const float Mask = pow(2.0 * length(RadialCoord) * rsqrt(Aspect * Aspect + 1.0), Curve);
#line 103
const float OffsetBase = Mask * Aberration * Pixel * 2.0;
#line 106
if(abs(OffsetBase) < Pixel) BluredImage = tex2D(SamplerColor, texcoord).rgb;
else
{
BluredImage = 0.0;
for (float P = 0.0; P < Samples; P++)
{
const float Progress = P / Samples;
const float Offset = OffsetBase * (Progress - 0.5) + 1.0;
#line 116
float2 Position = RadialCoord / Offset;
#line 118
Position.x /= Aspect;
#line 120
Position += 0.5;
#line 123
BluredImage += Spectrum(Progress) * tex2Dlod(SamplerColor, float4(Position, 0.0, 0.0)).rgb;
}
BluredImage *= 2.0 / Samples;
}
}
#line 134
technique ChromaticAberration < ui_label = "Chromatic Aberration"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ChromaticAberrationPS;
}
}

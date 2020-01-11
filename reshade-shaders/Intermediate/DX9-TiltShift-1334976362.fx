#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\TiltShift.fx"
#line 18
uniform bool Line <
ui_label = "Show Center Line";
> = false;
#line 22
uniform int Axis <
ui_label = "Angle";
ui_type = "slider";
ui_step = 1;
ui_min = -89; ui_max = 90;
> = 0;
#line 29
uniform float Offset <
ui_type = "slider";
ui_min = -1.41; ui_max = 1.41; ui_step = 0.01;
> = 0.05;
#line 34
uniform float BlurCurve <
ui_label = "Blur Curve";
ui_type = "slider";
ui_min = 1.0; ui_max = 5.0; ui_step = 0.01;
ui_label = "Blur Curve";
> = 1.0;
uniform float BlurMultiplier <
ui_label = "Blur Multiplier";
ui_type = "slider";
ui_min = 0.0; ui_max = 100.0; ui_step = 0.2;
> = 6.0;
#line 47
texture TiltShiftTarget < pooled = true; > { Width = 1920; Height = 1080; Format = RGBA8; };
sampler TiltShiftSampler { Texture = TiltShiftTarget; };
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\TiltShift.fx"
#line 57
void TiltShiftPass1PS(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD, out float4 Image : SV_Target)
{
const float Weight[11] =
{
0.082607,
0.080977,
0.076276,
0.069041,
0.060049,
0.050187,
0.040306,
0.031105,
0.023066,
0.016436,
0.011254
};
#line 74
Image.rgb = tex2D(ReShade::BackBuffer, UvCoord).rgb;
#line 76
float2 UvCoordAspect = UvCoord;
UvCoordAspect.y += ReShade::AspectRatio * 0.5 - 0.5;
UvCoordAspect.y /= ReShade::AspectRatio;
#line 80
UvCoordAspect = UvCoordAspect * 2.0 - 1.0;
#line 82
float Angle = radians(-Axis);
float2 TiltVector = float2(sin(Angle), cos(Angle));
#line 85
float BlurMask = abs(dot(TiltVector, UvCoordAspect) + Offset);
BlurMask = saturate(saturate(BlurMask));
#line 88
Image.a = BlurMask;
BlurMask = pow(Image.a, BlurCurve);
#line 91
if(BlurMask > 0)
{
float UvOffset = ReShade::PixelSize.x * BlurMask * BlurMultiplier;
Image.rgb *= Weight[0];
[unroll]
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Image.rgb += (
tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy + float2(SampleOffset, 0.0), 0.0, 0.0)).rgb
+ tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy - float2(SampleOffset, 0.0), 0.0, 0.0)).rgb
) * Weight[i];
}
}
}
#line 107
void TiltShiftPass2PS(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD, out float4 Image : SV_Target)
{
const float Weight[11] =
{
0.082607,
0.080977,
0.076276,
0.069041,
0.060049,
0.050187,
0.040306,
0.031105,
0.023066,
0.016436,
0.011254
};
#line 124
Image = tex2D(TiltShiftSampler, UvCoord);
#line 126
float BlurMask = pow(abs(Image.a), BlurCurve);
#line 128
if(BlurMask > 0)
{
float UvOffset = ReShade::PixelSize.y * BlurMask * BlurMultiplier;
Image.rgb *= Weight[0];
[unroll]
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Image.rgb += (
tex2Dlod(TiltShiftSampler, float4(UvCoord.xy + float2(0.0, SampleOffset), 0.0, 0.0)).rgb
+ tex2Dlod(TiltShiftSampler, float4(UvCoord.xy - float2(0.0, SampleOffset), 0.0, 0.0)).rgb
) * Weight[i];
}
}
#line 144
if (Line && Image.a < 0.01)
Image.rgb = float3(1.0, 0.0, 0.0);
}
#line 153
technique TiltShift < ui_label = "Tilt Shift"; >
{
pass AlphaAndHorizontalGaussianBlur
{
VertexShader = PostProcessVS;
PixelShader = TiltShiftPass1PS;
RenderTarget = TiltShiftTarget;
}
pass VerticalGaussianBlurAndRedLine
{
VertexShader = PostProcessVS;
PixelShader = TiltShiftPass2PS;
}
}

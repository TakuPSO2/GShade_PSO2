#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SimpleBloom.fx"
#line 16
uniform float BlurMultiplier <
ui_type = "slider";
ui_label = "Radius";
ui_min = 1; ui_max = 16; ui_step = 0.01;
> = 1.23;
#line 22
uniform float2 Blend <
ui_type = "slider";
ui_min = 0; ui_max = 1; ui_step = 0.001;
> = float2(0.0, 0.8);
#line 27
uniform bool Debug <
> = false;
#line 31
texture SimpleBloomTarget
{
#line 34
Width = 1920 * 0.25;
Height = 1080 * 0.25;
Format = RGBA8;
};
#line 47
sampler SimpleBloomSampler { Texture = SimpleBloomTarget; };
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SimpleBloom.fx"
#line 55
void BloomHorizontalPass(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD,
out float3 Target : SV_Target)
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
#line 73
Target.rgb = tex2D(ReShade::BackBuffer, UvCoord).rgb;
const float UvOffset = ReShade::PixelSize.x * BlurMultiplier;
Target.rgb *= Weight[0];
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Target.rgb +=
max(
Target.rgb,
max(
tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy + float2(SampleOffset, 0), 0, 0)).rgb
, tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy - float2(SampleOffset, 0), 0, 0)).rgb
)
) * Weight[i];
}
}
#line 90
void SimpleBloomPS(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD,
out float3 Image : SV_Target)
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
#line 108
float3 Target = tex2D(SimpleBloomSampler, UvCoord).rgb;
#line 110
const float UvOffset = ReShade::PixelSize.y * BlurMultiplier;
Target.rgb *= Weight[0];
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Target.rgb +=
max(
Target.rgb,
max(
tex2Dlod(SimpleBloomSampler, float4(UvCoord.xy + float2(0, SampleOffset), 0, 0)).rgb
, tex2Dlod(SimpleBloomSampler, float4(UvCoord.xy - float2(0, SampleOffset), 0, 0)).rgb
)
) * Weight[i];
}
#line 125
Image = tex2D(ReShade::BackBuffer, UvCoord).rgb;
#line 128
Target = max(Target - Image, Blend.x) - Blend.x;
Target /= 1 - min(0.999, Blend.x);
#line 132
Target *= Blend.y;
#line 134
Image = 1 - (1 - Image) * (1 - Target); 
#line 136
if (Debug)
Image = Target;
}
#line 144
technique SimpleBloom < ui_label = "Simple Bloom"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = BloomHorizontalPass;
RenderTarget = SimpleBloomTarget;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = SimpleBloomPS;
}
}

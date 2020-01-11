#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CAS.fx"
#line 38
uniform float Sharpness <
ui_type = "slider";
ui_label = "Sharpening strength";
ui_tooltip = "0 := no sharpening, to 1 := full sharpening.\nScaled by the sharpness knob while being transformed to a negative lobe (values from -1/5 to -1/8 for A=1)";
ui_min = 0.0; ui_max = 1.0;
> = 0.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CAS.fx"
#line 47
float3 CASPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 53
const float3 a = tex2Doffset(ReShade::BackBuffer, texcoord, int2(-1, -1)).rgb;
const float3 b = tex2Doffset(ReShade::BackBuffer, texcoord, int2(0, -1)).rgb;
const float3 c = tex2Doffset(ReShade::BackBuffer, texcoord, int2(1, -1)).rgb;
const float3 d = tex2Doffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb;
const float3 e = tex2Doffset(ReShade::BackBuffer, texcoord, int2(0, 0)).rgb;
const float3 f = tex2Doffset(ReShade::BackBuffer, texcoord, int2(1, 0)).rgb;
const float3 g = tex2Doffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb;
const float3 h = tex2Doffset(ReShade::BackBuffer, texcoord, int2(0, 1)).rgb;
const float3 i = tex2Doffset(ReShade::BackBuffer, texcoord, int2(1, 1)).rgb;
#line 68
float3 mnRGB = min(min(min(d, e), min(f, b)), h);
const float3 mnRGB2 = min(mnRGB, min(min(a, c), min(g, i)));
mnRGB += mnRGB2;
#line 72
float3 mxRGB = max(max(max(d, e), max(f, b)), h);
const float3 mxRGB2 = max(mxRGB, max(max(a, c), max(g, i)));
mxRGB += mxRGB2;
#line 77
const float3 rcpMRGB = rcp(mxRGB);
float3 ampRGB = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);
#line 81
ampRGB = rsqrt(ampRGB);
#line 83
const float peak = 8.0 - 3.0 * Sharpness;
const float3 wRGB = -rcp(ampRGB * peak);
#line 86
const float3 rcpWeightRGB = rcp(1.0 + 4.0 * wRGB);
#line 91
const float3 window = (b + d) + (f + h);
const float3 outColor = saturate((window * wRGB + e) * rcpWeightRGB);
#line 94
return outColor;
}
#line 97
technique ContrastAdaptiveSharpen
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CASPass;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\TriDither.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\TriDither.fx"
#line 9
uniform float Timer < source = "timer"; >;
#line 13
float rand21(float2 uv)
{
const float2 noise = frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453);
return (noise.x + noise.y) * 0.5;
}
float rand11(float x) { return frac(x * 0.024390243); }
float permute(float x) { return ((34.0 * x + 1.0) * x) % 289.0; }
#line 21
float3 triDither(float3 color, float2 uv, float timer)
{
static const float bitstep = 255.0;
static const float lsb = 1.0 / bitstep;
static const float lobit = 0.5 / bitstep;
static const float hibit = (bitstep - 0.5) / bitstep;
#line 28
const float3 m = float3(uv, rand21(uv + timer)) + 1.0;
float h = permute(permute(permute(m.x) + m.y) + m.z);
#line 31
float3 noise1, noise2;
noise1.x = rand11(h); h = permute(h);
noise2.x = rand11(h); h = permute(h);
noise1.y = rand11(h); h = permute(h);
noise2.y = rand11(h); h = permute(h);
noise1.z = rand11(h); h = permute(h);
noise2.z = rand11(h);
#line 39
const float3 lo = saturate((((color.xyz) - (0.0)) / ((lobit) - (0.0))));
const float3 hi = saturate((((color.xyz) - (1.0)) / ((hibit) - (1.0))));
const float3 uni = noise1 - 0.5;
const float3 tri = noise1 - noise2;
return lerp(uni, tri, min(lo, hi)) * lsb;
}
#line 47
float3 PS_TriDither(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 52
color.rgb += triDither(color.rgb, texcoord, Timer.x);
#line 55
return color;
}
#line 59
technique TriDither
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_TriDither;
}
}

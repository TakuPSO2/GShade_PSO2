#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\EGAFilter.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\EGAFilter.fx"
#line 15
sampler2D SourcePointSampler
{
Texture = ReShade::BackBufferTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 25
float3 nearest_rgbi (float3 original) {
#line 27
float3 rgbi_palette[16] = {
float3(0.0,     0.0,     0.0),
float3(0.0,     0.0,     0.66667),
float3(0.0,     0.66667, 0.0),
float3(0.0,     0.66667, 0.66667),
float3(0.66667, 0.0,     0.0),
float3(0.66667, 0.0,     0.66667),
float3(0.66667, 0.33333, 0.0),
float3(0.66667, 0.66667, 0.66667),
float3(0.33333, 0.33333, 0.33333),
float3(0.33333, 0.33333, 1.0),
float3(0.33333, 1.0,     0.33333),
float3(0.33333, 1.0,     1.0),
float3(1.0,     0.33333, 0.33333),
float3(1.0,     0.33333, 1.0),
float3(1.0,     1.0,     0.33333),
float3(1.0,     1.0,     1.0),
};
#line 46
float dst;
float min_dst = 2.0;
int idx = 0;
for (int i=0; i<16; i++) {
dst = distance(original, rgbi_palette[i]);
if (dst < min_dst) {
min_dst = dst;
idx = i;
}
}
return rgbi_palette[idx];
}
#line 59
float4 PS_EGA(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 fragcolor = tex2D(SourcePointSampler, texcoord).rgb;
return float4(nearest_rgbi(fragcolor*1.0), 1);
}
#line 65
technique EGAfilter
{
pass EGAfilterPass
{
VertexShader = PostProcessVS;
PixelShader = PS_EGA;
}
}

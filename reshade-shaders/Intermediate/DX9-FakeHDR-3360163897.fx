#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FakeHDR.fx"
#line 9
uniform float fHDRPower <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Power";
> = 1.30;
uniform float fradius1 <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Radius 1";
> = 0.793;
uniform float fradius2 <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Radius 2";
ui_tooltip = "Raising this seems to make the effect stronger and also brighter.";
> = 0.87;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FakeHDR.fx"
#line 28
float3 fHDRPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 32
float3 bloom_sum1 = tex2D(ReShade::BackBuffer, texcoord + float2(1.5, -1.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2(-1.5, -1.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2( 1.5,  1.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2(-1.5,  1.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2( 0.0, -2.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2( 0.0,  2.5) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2(-2.5,  0.0) * fradius1 * ReShade::PixelSize).rgb;
bloom_sum1 += tex2D(ReShade::BackBuffer, texcoord + float2( 2.5,  0.0) * fradius1 * ReShade::PixelSize).rgb;
#line 41
bloom_sum1 *= 0.005;
#line 43
float3 bloom_sum2 = tex2D(ReShade::BackBuffer, texcoord + float2(1.5, -1.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2(-1.5, -1.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2( 1.5,  1.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2(-1.5,  1.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2( 0.0, -2.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2( 0.0,  2.5) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2(-2.5,  0.0) * fradius2 * ReShade::PixelSize).rgb;
bloom_sum2 += tex2D(ReShade::BackBuffer, texcoord + float2( 2.5,  0.0) * fradius2 * ReShade::PixelSize).rgb;
#line 52
bloom_sum2 *= 0.010;
#line 54
const float dist = fradius2 - fradius1;
const float3 HDR = (color + (bloom_sum2 - bloom_sum1)) * dist;
const float3 blend = HDR + color;
#line 59
return saturate(pow(abs(blend), fHDRPower) + HDR);
}
#line 62
technique FakeHDR
{
pass
{
VertexShader = PostProcessVS;
PixelShader = fHDRPass;
}
}

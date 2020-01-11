#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Colourfulness.fx"
#line 28
uniform float colourfulness <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_tooltip = "Degree of colourfulness, 0 = neutral";
ui_step = 0.01;
> = 0.4;
#line 35
uniform float lim_luma <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_tooltip = "Lower values allows for more change near clipping";
ui_step = 0.01;
> = 0.7;
#line 42
uniform bool enable_dither <
ui_tooltip = "Enables dithering, avoids introducing banding in gradients";
ui_category = "Dither";
> = false;
#line 47
uniform bool col_noise <
ui_tooltip = "Coloured dither noise, lower subjective noise level";
ui_category = "Dither";
> = false;
#line 52
uniform float backbuffer_bits <
ui_min = 1.0; ui_max = 32.0;
ui_tooltip = "Backbuffer bith depth, most likely 8 or 10 bits";
ui_category = "Dither";
> = 8.0;
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reshade.fxh"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Colourfulness.fx"
#line 87
float3 Colourfulness(float4 vpos : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 90
float3 c0  = tex2D(ReShade::BackBuffer, tex).rgb;
const float luma = sqrt(dot(saturate(c0*abs(c0)), float3(0.2558, 0.6511, 0.0931)));
c0 = saturate(c0);
#line 99
const float3 diff_luma = c0 - luma;
float3 c_diff = diff_luma*(colourfulness + 1) - diff_luma;
#line 102
if (colourfulness > 0.0)
{
#line 105
const float3 rlc_diff = clamp((c_diff*1.2) + c0, -0.0001, 1.0001) - c0;
#line 108
const float poslim = (1.0002 - luma)/(abs(( max((diff_luma).r, max((diff_luma).g, (diff_luma).b)) )) + 0.0001);
const float neglim = (luma + 0.0002)/(abs(( min((diff_luma).r, min((diff_luma).g, (diff_luma).b)) )) + 0.0001);
#line 111
const float3 diffmax = diff_luma*min(min(poslim, neglim), 32) - diff_luma;
#line 114
c_diff = ( (c_diff*max((((abs(lim_luma)*sqrt(abs(diffmax))+abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2)),1e-6))*rcp(sqrt(max((((abs(lim_luma)*sqrt(abs(diffmax))+abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2)),1e-6)*max((((abs(lim_luma)*sqrt(abs(diffmax))+abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2)),1e-6) + c_diff*c_diff)) );
}
#line 117
if (enable_dither == true)
{
#line 120
const float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
#line 124
const float xy_magic = vpos.x*magic.x + vpos.y*magic.y;
#line 126
const float noise = (frac(magic.z*frac(xy_magic)) - 0.5)/(exp2(backbuffer_bits) - 1);
if (col_noise == true)
c_diff += float3(-noise, noise, -noise);
else
c_diff += noise;
}
#line 133
return saturate(c0 + c_diff);
}
#line 136
technique Colourfulness
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = Colourfulness;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\DepthHaze.fx"
#line 15
uniform float EffectStrength <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "The strength of the effect. Range from 0.0, which means no effect, till 1.0 which means pixels are 100% blurred based on depth.";
> = 0.9;
uniform float3 FogColor <
ui_type= "color";
ui_tooltip = "Color of the fog, in (red , green, blue)";
> = float3(0.8,0.8,0.8);
uniform float FogStart <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "Start of the fog. 0.0 is at the camera, 1.0 is at the horizon, 0.5 is halfway towards the horizon. Before this point no fog will appear.";
> = 0.2;
uniform float FogFactor <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "The amount of fog added to the scene. 0.0 is no fog, 1.0 is the strongest fog possible.";
> = 0.2;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\DepthHaze.fx"
#line 40
texture   Otis_FragmentBuffer1 	{ Width = 1920; Height = 1080; Format = RGBA8;};
texture   Otis_FragmentBuffer2 	< pooled = true; > { Width = 1920; Height = 1080; Format = RGBA8;};
#line 46
sampler2D Otis_SamplerFragmentBuffer2 { Texture = Otis_FragmentBuffer2; };
sampler2D Otis_SamplerFragmentBuffer1 {	Texture = Otis_FragmentBuffer1; };
#line 52
float CalculateWeight(float distanceFromSource, float sourceDepth, float neighborDepth)
{
return (1.0 - abs(sourceDepth - neighborDepth)) * (1/distanceFromSource) * neighborDepth;
}
#line 57
void PS_Otis_DEH_BlockBlurHorizontal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target0)
{
float4 color = tex2D(ReShade::BackBuffer, texcoord);
const float colorDepth = ReShade::GetLinearizedDepth(texcoord).r;
float n = 1.0f;
#line 63
[loop]
for(float i = 1; i < 5; ++i)
{
float2 sourceCoords = texcoord + float2(i * ReShade::PixelSize.x, 0.0);
float weight = CalculateWeight(i, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(ReShade::BackBuffer, sourceCoords) * weight);
n+=weight;
#line 71
sourceCoords = texcoord - float2(i * ReShade::PixelSize.x, 0.0);
weight = CalculateWeight(i, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(ReShade::BackBuffer, sourceCoords) * weight);
n+=weight;
}
outFragment = color/n;
}
#line 79
void PS_Otis_DEH_BlockBlurVertical(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target0)
{
float4 color = tex2D(Otis_SamplerFragmentBuffer1, texcoord);
const float colorDepth = ReShade::GetLinearizedDepth(texcoord).r;
float n=1.0f;
#line 85
[loop]
for(float j = 1; j < 5; ++j)
{
float2 sourceCoords = texcoord + float2(0.0, j * ReShade::PixelSize.y);
float weight = CalculateWeight(j, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(Otis_SamplerFragmentBuffer1, sourceCoords) * weight);
n+=weight;
#line 93
sourceCoords = texcoord - float2(0.0, j * ReShade::PixelSize.y);
weight = CalculateWeight(j, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(Otis_SamplerFragmentBuffer1, sourceCoords) * weight);
n+=weight;
}
outFragment = color/n;
}
#line 101
void PS_Otis_DEH_BlendBlurWithNormalBuffer(float4 vpos: SV_Position, float2 texcoord: TEXCOORD, out float4 fragment: SV_Target0)
{
const float depth = ReShade::GetLinearizedDepth(texcoord).r;
const float4 blendedFragment = lerp(tex2D(ReShade::BackBuffer, texcoord), tex2D(Otis_SamplerFragmentBuffer2, texcoord), clamp(depth  * EffectStrength, 0.0, 1.0));
float yFactor;
if (texcoord.y > 0.5)
yFactor = clamp(1-((texcoord.y-0.5)*2.0), 0, 1);
else
yFactor = clamp(texcoord.y * 2.0, 0, 1);
fragment = lerp(blendedFragment, float4(FogColor, blendedFragment.r), clamp((depth-FogStart) * yFactor * FogFactor, 0.0, 1.0));
}
#line 113
technique DepthHaze
{
#line 117
pass Otis_DEH_Pass0
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlockBlurHorizontal;
RenderTarget = Otis_FragmentBuffer1;
}
#line 124
pass Otis_DEH_Pass1
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlockBlurVertical;
RenderTarget = Otis_FragmentBuffer2;
}
#line 131
pass Otis_DEH_Pass2
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlendBlurWithNormalBuffer;
}
}

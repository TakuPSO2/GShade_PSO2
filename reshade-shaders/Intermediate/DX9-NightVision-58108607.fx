#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\NightVision.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\NightVision.fx"
#line 3
uniform float iGlobalTime < source = "timer"; >;
#line 5
float hash(in float n) { return frac(sin(n)*43758.5453123); }
#line 7
float mod(float x, float y)
{
return x - y * floor (x/y);
}
#line 12
float3 PS_Nightvision(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
const float2 p = uv;
#line 16
const float2 u = p * 2. - 1.;
const float2 n = u * float2(ReShade::ScreenSize.x / ReShade::ScreenSize.y, 1.0);
float3 c = tex2D(ReShade::BackBuffer, uv).xyz;
#line 21
c += sin(hash(iGlobalTime*0.001)) * 0.01;
c += hash((hash(n.x) + n.y) * iGlobalTime*0.001) * 0.5;
c *= smoothstep(length(n * n * n * float2(0.0, 0.0)), 1.0, 0.4);
c *= smoothstep(0.001, 3.5, iGlobalTime*0.001) * 1.5;
#line 26
return dot(c, float3(0.2126, 0.7152, 0.0722))
* float3(0.2, 1.5 - hash(iGlobalTime*0.001) * 0.1,0.4);
}
#line 30
technique Nightvision {
pass Nightvision {
VertexShader=PostProcessVS;
PixelShader=PS_Nightvision;
}
}

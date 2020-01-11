#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reinhard.fx"
#line 6
uniform float ReinhardWhitepoint <
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_tooltip = "how steep the color curve is at linear point";
> = 1.250;
uniform float ReinhardScale <
ui_type = "slider";
ui_min = 0.0; ui_max = 3.0;
ui_tooltip = "how steep the color curve is at linear point";
> = 0.50;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reinhard.fx"
#line 19
float3 ReinhardPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 22
const float3 x = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float W =  ReinhardWhitepoint;	
const float K =  ReinhardScale;        
#line 27
return (1 + K * x / (W * W)) * x / (x + K);
}
#line 30
technique Reinhard
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ReinhardPass;
}
}

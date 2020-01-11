#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SCurve.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SCurve.fx"
#line 4
uniform float fCurve <
ui_label = "Curve";
ui_type = "slider";
ui_min = 1.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.0;
#line 12
uniform float4 f4Offsets <
ui_label = "Offsets";
ui_tooltip = "{ Low Color, High Color, Both, Unused }";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
ui_step = 0.001;
> = float4(0.0, 0.0, 0.0, 0.0);
#line 21
float4 PS_SCurve(
const float4 pos : SV_POSITION,
const float2 uv : TEXCOORD
) : SV_TARGET {
float3 col = tex2D(ReShade::BackBuffer, uv).rgb;
const float lum = max(col.r, max(col.g, col.b));
#line 30
const float3 low = pow(abs(col), fCurve) + f4Offsets.x;
const float3 high = pow(abs(col), 1.0 / fCurve) + f4Offsets.y;
#line 33
col.r = lerp(low.r, high.r, col.r + f4Offsets.z);
col.g = lerp(low.g, high.g, col.g + f4Offsets.z);
col.b = lerp(low.b, high.b, col.b + f4Offsets.z);
#line 37
return float4(col, 1.0);
}
#line 40
technique SCurve {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SCurve;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FakeMotionBlur.fx"
#line 31
uniform float mbRecall <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Motion blur intensity";
> = 0.40;
uniform float mbSoftness <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Blur strength of consequential streaks";
> = 1.00;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FakeMotionBlur.fx"
#line 44
texture2D currTex { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D prevSingleTex { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D prevTex { Width = 1920; Height = 1080; Format = RGBA8; };
#line 48
sampler2D currColor { Texture = currTex; };
sampler2D prevSingleColor { Texture = prevSingleTex; };
sampler2D prevColor { Texture = prevTex; };
#line 52
void PS_Combine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
float4 curr = tex2D(currColor, texcoord);
float4 prevSingle = tex2D(prevSingleColor, texcoord);
float4 prev = tex2D(prevColor, texcoord);
#line 58
float3 diff3 = abs(prevSingle.rgb - curr.rgb) * 2.0f;
float diff = min(diff3.r + diff3.g + diff3.b, mbRecall);
#line 61
const float weight[11] = { 0.082607, 0.040484, 0.038138, 0.034521, 0.030025, 0.025094, 0.020253, 0.015553, 0.011533, 0.008218, 0.005627 };
prev *= weight[0];
#line 64
float pixelBlur = (mbSoftness * 13 * (diff)) * ((1.0 / 1920));
float pixelBlur2 = (mbSoftness * 11 * (diff)) * ((1.0 / 1080));
#line 67
[unroll]
for (int z = 1; z < 11; z++)
{
prev += tex2D(prevColor, texcoord + float2(z * pixelBlur, 0.0f)) * weight[z];
prev += tex2D(prevColor, texcoord - float2(z * pixelBlur, 0.0f)) * weight[z];
prev += tex2D(prevColor, texcoord + float2(0.0f, z * pixelBlur2)) * weight[z];
prev += tex2D(prevColor, texcoord - float2(0.0f, z * pixelBlur2)) * weight[z];
}
#line 76
color = lerp(curr, prev, diff+0.1);
}
#line 79
void PS_CopyFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
color = tex2D(ReShade::BackBuffer, texcoord);
}
void PS_CopyPreviousFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 prevSingle : SV_Target0, out float4 prev : SV_Target1)
{
prevSingle = tex2D(currColor, texcoord);
prev = tex2D(ReShade::BackBuffer, texcoord);
}
#line 89
technique MotionBlur
{
pass CopyFrame
{
VertexShader = PostProcessVS;
PixelShader = PS_CopyFrame;
RenderTarget = currTex;
}
#line 98
pass Combine
{
VertexShader = PostProcessVS;
PixelShader = PS_Combine;
}
#line 104
pass PrevColor
{
VertexShader = PostProcessVS;
PixelShader = PS_CopyPreviousFrame;
RenderTarget0 = prevSingleTex;
RenderTarget1 = prevTex;
}
}

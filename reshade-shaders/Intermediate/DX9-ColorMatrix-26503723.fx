#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorMatrix.fx"
#line 9
uniform float3 ColorMatrix_Red <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Red";
ui_tooltip = "How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.817, 0.183, 0.000);
uniform float3 ColorMatrix_Green <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Green";
ui_tooltip = "How much of a red, green and blue tint the new green value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.333, 0.667, 0.000);
uniform float3 ColorMatrix_Blue <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Blue";
ui_tooltip = "How much of a red, green and blue tint the new blue value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.000, 0.125, 0.875);
#line 28
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ColorMatrix.fx"
#line 35
float3 ColorMatrixPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 39
const float3x3 ColorMatrix = float3x3(ColorMatrix_Red, ColorMatrix_Green, ColorMatrix_Blue);
#line 41
return saturate(lerp(color, mul(ColorMatrix, color), Strength));
}
#line 44
technique ColorMatrix
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColorMatrixPass;
}
}

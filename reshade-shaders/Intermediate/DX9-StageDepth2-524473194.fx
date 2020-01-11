#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\StageDepth2.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\StageDepth2.fx"
#line 45
uniform float Stage_Two_Opacity <
ui_label = "Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.002;
> = 1.0;
#line 54
uniform float Stage_Two_depth <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Depth";
> = 0.97;
#line 61
texture Stage_Two_texture <source="Stage2.png" ;> { Width = 1920; Height = 1080; Format=RGBA8; };
#line 63
sampler Stage_Two_sampler { Texture = Stage_Two_texture; };
#line 65
void PS_StageTwoDepth(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float4 stagetwo = tex2D(Stage_Two_sampler, texcoord).rgba;
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 70
float depthtwo = 1 - ReShade::GetLinearizedDepth(texcoord).r;
#line 72
if( depthtwo < Stage_Two_depth )
{
color = lerp(color, stagetwo.rgb, stagetwo.a * Stage_Two_Opacity);
}
}
#line 78
technique StageDepth2
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_StageTwoDepth;
}
}

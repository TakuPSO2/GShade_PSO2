#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Layer3.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Layer3.fx"
#line 33
uniform float Layer_Three_Blend <
ui_label = "Opacity";
ui_tooltip = "The transparency of the layer.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 42
uniform float Layer_Three_Scale <
ui_type = "slider";
ui_label = "Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 49
uniform float Layer_Three_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 56
uniform float Layer_Three_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 63
texture Layer_Three_texture <source="Layer3.png" ;> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Layer_Three_sampler { Texture = Layer_Three_texture; };
#line 66
void PS_Layer_Three(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 Layer_Pos = float2(Layer_Three_PosX, Layer_Three_PosY);
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Three_Scale);
const float4 Layer  = tex2D(Layer_Three_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Three_Blend);
color.a = backbuffer.a;
}
#line 75
technique Layer3 {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Layer_Three;
}
}

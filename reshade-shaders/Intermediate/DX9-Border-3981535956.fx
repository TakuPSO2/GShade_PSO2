#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Border.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Border.fx"
#line 22
uniform float2 border_width <
ui_type = "slider";
ui_label = "Size";
ui_tooltip = "Measured in pixels. If this is set to zero then the ratio will be used instead.";
ui_min = 0.0; ui_max = (1920 * 0.5);
ui_step = 1.0;
> = float2(0.0, 1.0);
#line 30
uniform float border_ratio <
ui_type = "input";
ui_label = "Size Ratio";
ui_tooltip = "Set the desired ratio for the visible area.";
> = 2.35;
#line 36
uniform float4 border_color <
ui_type = "color";
ui_label = "Border Color";
> = float4(0.7, 0.0, 0.0, 1.0);
#line 41
float3 BorderPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 45
float2 border_width_variable = border_width;
if (border_width.x == -border_width.y) 
if (ReShade::AspectRatio < border_ratio)
border_width_variable = float2(0.0, (ReShade::ScreenSize.y - (ReShade::ScreenSize.x / border_ratio)) * 0.5);
else
border_width_variable = float2((ReShade::ScreenSize.x - (ReShade::ScreenSize.y * border_ratio)) * 0.5, 0.0);
#line 52
const float2 border = (ReShade::PixelSize * border_width_variable); 
#line 54
if (all(saturate((-texcoord * texcoord + texcoord) - (-border * border + border)))) 
return color;
else
return lerp(color, border_color.rgb, border_color.a);
}
#line 60
technique Border
{
pass
{
VertexShader = PostProcessVS;
PixelShader = BorderPass;
}
}

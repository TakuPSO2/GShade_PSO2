#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PSO2Copyright_Vertical.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PSO2Copyright_Vertical.fx"
#line 33
uniform int cLayer_v_Select <
ui_label = "Layer Selection";
ui_tooltip = "The image/texture you'd like to use.";
ui_type = "combo";
ui_items= "PSO2 logo\0PSO2 copyright\0GShade\0GShade_White\0Eurostyle Left\0Eurostyle Right\0Futura Center\0Futura Triangle White\0Futura Triangle Black\0Rockwell Nova White\0Rockwell Nova Black\0Swiss911 Condenced\0Swiss721 Square White\0Swiss721 Square Black\0";
> = 0;
#line 40
uniform float cLayer_Blend <
ui_label = "Opacity";
ui_tooltip = "The transparency of the copyright notice.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 49
uniform float cLayer_Scale <
ui_type = "slider";
ui_label = "Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.000;
#line 56
uniform float cLayer_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 63
uniform float cLayer_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 70
texture PSO2_logo_v_texture <source="PSO2_logo_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler PSO2_logo_v_sampler { Texture = PSO2_logo_v_texture; };
#line 73
texture PSO2_copyright_v_texture <source="copyright_PSO2_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler PSO2_copyright_v_sampler { Texture = PSO2_copyright_v_texture; };
#line 76
texture GShade_v_texture <source="copyright_by_gshade_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler GShade_v_sampler { Texture =GShade_v_texture; };
#line 79
texture GShade_White_v_texture <source="copyright_by_gshade_w_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler GShade_White_v_sampler { Texture =GShade_White_v_texture; };
#line 82
texture Eurostyle_left_v_texture <source="copyright_Eurostyle_left_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Eurostyle_left_v_sampler { Texture = Eurostyle_left_v_texture; };
#line 85
texture Eurostyle_right_v_texture <source="copyright_Eurostyle_right_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Eurostyle_right_v_sampler { Texture = Eurostyle_right_v_texture; };
#line 88
texture Futura_center_v_texture <source="copyright_futura_center_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Futura_center_v_sampler { Texture = Futura_center_v_texture; };
#line 91
texture Futura_Triangle_White_v_texture <source="copyright_futura_tri_w_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Futura_Triangle_White_v_sampler { Texture = Futura_Triangle_White_v_texture; };
#line 94
texture Futura_Triangle_Black_v_texture <source="copyright_futura_tri_b_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Futura_Triangle_Black_v_sampler { Texture = Futura_Triangle_Black_v_texture; };
#line 97
texture Rockwell_Nova_White_v_texture <source="copyright_Rockwell_nova_w_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Rockwell_Nova_White_v_sampler { Texture = Rockwell_Nova_White_v_texture; };
#line 100
texture Rockwell_Nova_Black_v_texture <source="copyright_Rockwell_nova_b_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Rockwell_Nova_Black_v_sampler { Texture = Rockwell_Nova_Black_v_texture; };
#line 103
texture Swiss911_Condenced_v_texture <source="copyright_Swiss911_UCm_BT_Cn_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Swiss911_Condenced_v_sampler { Texture = Swiss911_Condenced_v_texture; };
#line 106
texture Swis721_Square_White_v_texture <source="copyright_Swis721_square_w_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Swis721_Square_White_v_sampler { Texture = Swis721_Square_White_v_texture; };
#line 109
texture Swis721_Square_Black_v_texture <source="copyright_Swis721_square_b_v.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Swis721_Square_Black_v_sampler { Texture = Swis721_Square_Black_v_texture; };
#line 112
void PS_cLayer(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 cLayer_Pos = float2(cLayer_PosX, cLayer_PosY);
#line 116
if (cLayer_v_Select == 0)
{
const float2 scale = 1.0 / (float2(164.0, 684.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(PSO2_logo_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
if (cLayer_v_Select == 1)
{
const float2 scale = 1.0 / (float2(31.0, 435.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(PSO2_copyright_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 2)
{
const float2 scale = 1.0 / (float2(60.0, 810.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(GShade_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 3)
{
const float2 scale = 1.0 / (float2(60.0, 810.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(GShade_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 4)
{
const float2 scale = 1.0 / (float2(183.0, 800.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Eurostyle_left_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 5)
{
const float2 scale = 1.0 / (float2(183.0, 800.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Eurostyle_right_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 6)
{
const float2 scale = 1.0 / (float2(134.0, 535.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Futura_center_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 7)
{
const float2 scale = 1.0 / (float2(432.0, 319.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Futura_Triangle_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 8)
{
const float2 scale = 1.0 / (float2(432.0, 319.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Futura_Triangle_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 9)
{
const float2 scale = 1.0 / (float2(122.0, 471.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Rockwell_Nova_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 10)
{
const float2 scale = 1.0 / (float2(122.0, 471.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Rockwell_Nova_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 11)
{
const float2 scale = 1.0 / (float2(54.0, 540.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Swiss911_Condenced_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 12)
{
const float2 scale = 1.0 / (float2(285.0, 261.0 ) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Swis721_Square_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_v_Select == 13)
{
const float2 scale = 1.0 / (float2(285.0, 261.0 ) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Swis721_Square_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
color.a = backbuffer.a;
}
#line 203
technique PSO2Copyright_Vertical {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_cLayer;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\XIVCopyright.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\XIVCopyright.fx"
#line 29
uniform int cLayer_Select <
ui_label = "Layer Selection";
ui_tooltip = "The image/texture you'd like to use.";
ui_type = "combo";
ui_items= "Horizontal Vanilla\0Vertical Vanilla\0Nalukai Horizontal\0Yomi Black Horizontal\0Yomi White Horizontal\0";
> = 0;
#line 36
uniform float cLayer_Blend <
ui_label = "Opacity";
ui_tooltip = "The transparency of the copyright notice.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 45
uniform float cLayer_Scale <
ui_type = "slider";
ui_label = "Scale";
ui_min = 0.01; ui_max = 3.0;
ui_step = 0.001;
> = 1.001;
#line 52
uniform float cLayer_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = -4.0; ui_max = 4.0;
ui_step = 0.001;
> = 0.5;
#line 59
uniform float cLayer_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = -4.0; ui_max = 4.0;
ui_step = 0.001;
> = 0.5;
#line 66
texture Horiz_fourk_texture <source="Copyright4kH.png";> { Width = 1920; Height = 1920; Format=RGBA8; };
sampler Horiz_fourk_sampler { Texture = Horiz_fourk_texture; };
texture Verti_fourk_texture <source="Copyright4kV.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Verti_fourk_sampler { Texture = Verti_fourk_texture; };
#line 71
texture Horiz_fancy_fourk_texture <source="CopyrightF4kH.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Horiz_fancy_fourk_sampler { Texture = Horiz_fancy_fourk_texture; };
#line 74
texture Horiz_yomi_b_texture <source="CopyrightYBlH.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Horiz_yomi_b_sampler { Texture = Horiz_yomi_b_texture; };
#line 77
texture Horiz_yomi_w_texture <source="CopyrightYWhH.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Horiz_yomi_w_sampler { Texture = Horiz_yomi_w_texture; };
#line 80
void PS_cLayer(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 cLayer_Pos = float2(cLayer_PosX, cLayer_PosY);
#line 84
if (cLayer_Select == 0)
{
const float2 scale = 1.0 / (float2(411.0, 22.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Horiz_fourk_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_Select == 1)
{
const float2 scale = 1.0 / (float2(22.0, 412.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Verti_fourk_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_Select == 2)
{
const float2 scale = 1.0 / (float2(1162.0, 135.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Horiz_fancy_fourk_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else if (cLayer_Select == 3)
{
const float2 scale = 1.0 / (float2(1162.0, 135.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Horiz_yomi_b_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
else
{
const float2 scale = 1.0 / (float2(1162.0, 135.0) / ReShade::ScreenSize * cLayer_Scale);
const float4 cLayer  = tex2D(Horiz_yomi_w_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
}
color.a = backbuffer.a;
}
#line 117
technique XIVCopyright {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_cLayer;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MultiStageDepth.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MultiStageDepth.fx"
#line 50
uniform int Tex_Select <
ui_label = "Texture";
ui_tooltip = "The image to use.";
ui_type = "combo";
ui_items = "Fire1.png\0Fire2.png\0Snow1.png\0Snow2.png\0Shatter1.png\0Lightrays1.png\0VignetteSharp.png\0VignetteSoft.png\0Metal1.jpg\0Ice1.jpg\0";
> = 0;
#line 57
uniform float Stage_Opacity <
ui_label = "Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.002;
> = 1.0;
#line 66
uniform float Stage_depth <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Depth";
> = 0.97;
#line 73
texture Fire_one_texture <source="Fire1.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Fire_one_sampler { Texture = Fire_one_texture; };
#line 76
texture Fire_two_texture <source="Fire2.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Fire_two_sampler { Texture = Fire_two_texture; };
#line 79
texture Snow_one_texture <source="Snow1.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Snow_one_sampler { Texture = Snow_one_texture; };
#line 82
texture Snow_two_texture <source="Snow2.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Snow_two_sampler { Texture = Snow_two_texture; };
#line 85
texture Shatter_one_texture <source="Shatter1.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Shatter_one_sampler { Texture = Shatter_one_texture; };
#line 88
texture Lightrays_one_texture <source="Lightrays1.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Lightrays_one_sampler { Texture = Lightrays_one_texture; };
#line 91
texture Vignette_sharp_texture <source="VignetteSharp.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Vignette_sharp_sampler { Texture = Vignette_sharp_texture; };
#line 94
texture Vignette_soft_texture <source="VignetteSoft.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Vignette_soft_sampler { Texture = Vignette_soft_texture; };
#line 97
texture Metal_one_texture <source="Metal1.jpg";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Metal_one_sampler { Texture = Metal_one_texture; };
#line 100
texture Ice_one_texture <source="Ice1.jpg";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Ice_one_sampler { Texture = Ice_one_texture; };
#line 104
void PS_StageDepth(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float4 Fire_one_stage = tex2D(Fire_one_sampler, texcoord).rgba;
float4 Fire_two_stage = tex2D(Fire_two_sampler, texcoord).rgba;
float4 Snow_one_stage = tex2D(Snow_one_sampler, texcoord).rgba;
float4 Snow_two_stage = tex2D(Snow_two_sampler, texcoord).rgba;
float4 Shatter_one_stage = tex2D(Shatter_one_sampler, texcoord).rgba;
float4 Lightrays_one_stage = tex2D(Lightrays_one_sampler, texcoord).rgba;
float4 Vignette_sharp_stage = tex2D(Vignette_sharp_sampler, texcoord).rgba;
float4 Vignette_soft_stage = tex2D(Vignette_soft_sampler, texcoord).rgba;
float4 Metal_one_stage = tex2D(Metal_one_sampler, texcoord).rgba;
float4 Ice_one_stage = tex2D(Ice_one_sampler, texcoord).rgba;
#line 117
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 119
float depth = 1 - ReShade::GetLinearizedDepth(texcoord).r;
#line 121
if ((Tex_Select == 0) && (depth < Stage_depth))
{
color = lerp(color, Fire_one_stage.rgb, Fire_one_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 1) && (depth < Stage_depth))
{
color = lerp(color, Fire_two_stage.rgb, Fire_two_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 2) && (depth < Stage_depth))
{
color = lerp(color, Snow_one_stage.rgb, Snow_one_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 3) && (depth < Stage_depth))
{
color = lerp(color, Snow_two_stage.rgb, Snow_two_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 4) && (depth < Stage_depth))
{
color = lerp(color, Shatter_one_stage.rgb, Shatter_one_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 5) && (depth < Stage_depth))
{
color = lerp(color, Lightrays_one_stage.rgb, Lightrays_one_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 6) && (depth < Stage_depth))
{
color = lerp(color, Vignette_sharp_stage.rgb, Vignette_sharp_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 7) && (depth < Stage_depth))
{
color = lerp(color, Vignette_soft_stage.rgb, Vignette_soft_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 8) && (depth < Stage_depth))
{
color = lerp(color, Metal_one_stage.rgb, Metal_one_stage.a * Stage_Opacity);
}
else if ((Tex_Select == 9) && (depth < Stage_depth))
{
color = lerp(color, Ice_one_stage.rgb, Ice_one_stage.a * Stage_Opacity);
}
}
#line 163
technique MultiStageDepth
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_StageDepth;
}
}

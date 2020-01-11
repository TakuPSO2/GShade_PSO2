#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Silhouette.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Silhouette.fx"
#line 54
uniform bool SEnable_Foreground_Color <
ui_label = "Enable Foreground Color";
ui_tooltip = "Enable this to use a color instead of a texture for the foreground!";
> = false;
#line 59
uniform int3 SForeground_Color <
ui_label = "Foreground Color (If Enabled)";
ui_tooltip = "If you enabled foreground color, use this to select the color.";
ui_min = 0;
ui_max = 255;
> = int3(0, 0, 0);
#line 66
uniform float SForeground_Stage_Opacity <
ui_label = "Foreground Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 75
uniform int SForeground_Tex_Select <
ui_label = "Foreground Texture";
ui_tooltip = "The image to use in the foreground.";
ui_type = "combo";
ui_items = "Papyrus2.png\0Papyrus6.png\0Metal1.jpg\0Ice1.jpg\0Silhouette1.png\0Silhouette2.png\0";
> = 0;
#line 82
uniform bool SEnable_Background_Color <
ui_label = "Enable Background Color";
ui_tooltip = "Enable this to use a color instead of a texture for the background!";
> = false;
#line 87
uniform int3 SBackground_Color <
ui_label = "Background Color (If Enabled)";
ui_tooltip = "If you enabled background color, use this to select the color.";
ui_min = 0;
ui_max = 255;
> = int3(0, 0, 0);
#line 94
uniform float SBackground_Stage_Opacity <
ui_label = "Background Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.002;
> = 1.0;
#line 103
uniform float SBackground_Stage_depth <
ui_type = "slider";
ui_min = 0.001;
ui_max = 1.0;
ui_label = "Background Depth";
> = 0.500;
#line 110
uniform int SBackground_Tex_Select <
ui_label = "Background Texture";
ui_tooltip = "The image to use in the background.";
ui_type = "combo";
ui_items = "Papyrus2.png\0Papyrus6.png\0Metal1.jpg\0Ice1.jpg\0Silhouette1.png\0Silhouette2.png\0";
> = 1;
#line 117
texture sPaper_two_texture <source="Papyrus2.png" ;> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sPaper_two_sampler { Texture = sPaper_two_texture; };
#line 120
texture sPaper_six_texture <source="Papyrus6.png" ;> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sPaper_six_sampler { Texture = sPaper_six_texture; };
#line 123
texture sMetal_one_texture <source="Metal1.jpg";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sMetal_one_sampler { Texture = sMetal_one_texture; };
#line 126
texture sIce_one_texture <source="Ice1.jpg";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sIce_one_sampler { Texture = sIce_one_texture; };
#line 129
texture sSilhouette_one_texture <source="Silhouette1.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sSilhouette_one_sampler { Texture = sSilhouette_one_texture; };
#line 132
texture sSilhouette_two_texture <source="Silhouette2.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler sSilhouette_two_sampler { Texture = sSilhouette_two_texture; };
#line 135
void PS_SilhouetteForeground(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float4 Paper_two_stage = tex2D(sPaper_two_sampler, texcoord).rgba;
float4 Paper_six_stage = tex2D(sPaper_six_sampler, texcoord).rgba;
float4 Metal_one_stage = tex2D(sMetal_one_sampler, texcoord).rgba;
float4 Ice_one_stage = tex2D(sIce_one_sampler, texcoord).rgba;
float4 Silhouette_one_stage = tex2D(sSilhouette_one_sampler, texcoord).rgba;
float4 Silhouette_two_stage = tex2D(sSilhouette_two_sampler, texcoord).rgba;
#line 144
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 146
float depth = 1.0 - ReShade::GetLinearizedDepth(texcoord).r;
#line 148
if (SEnable_Foreground_Color == true)
{
color = lerp(color, SForeground_Color.rgb * 0.00392, SForeground_Stage_Opacity);
}
else if (SForeground_Tex_Select == 0)
{
color = lerp(color, Paper_two_stage.rgb, Paper_two_stage.a * SForeground_Stage_Opacity);
}
else if (SForeground_Tex_Select == 1)
{
color = lerp(color, Paper_six_stage.rgb, Paper_six_stage.a * SForeground_Stage_Opacity);
}
else if (SForeground_Tex_Select == 2)
{
color = lerp(color, Metal_one_stage.rgb, Metal_one_stage.a * SForeground_Stage_Opacity);
}
else if (SForeground_Tex_Select == 3)
{
color = lerp(color, Ice_one_stage.rgb, Ice_one_stage.a * SForeground_Stage_Opacity);
}
else if (SForeground_Tex_Select == 4)
{
color = lerp(color, Silhouette_one_stage.rgb, Silhouette_one_stage.a * SForeground_Stage_Opacity);
}
else
{
color = lerp(color, Silhouette_two_stage.rgb, Silhouette_two_stage.a * SForeground_Stage_Opacity);
}
}
#line 178
void PS_SilhouetteBackground(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float4 Paper_two_stage = tex2D(sPaper_two_sampler, texcoord).rgba;
float4 Paper_six_stage = tex2D(sPaper_six_sampler, texcoord).rgba;
float4 Metal_one_stage = tex2D(sMetal_one_sampler, texcoord).rgba;
float4 Ice_one_stage = tex2D(sIce_one_sampler, texcoord).rgba;
float4 Silhouette_one_stage = tex2D(sSilhouette_one_sampler, texcoord).rgba;
float4 Silhouette_two_stage = tex2D(sSilhouette_two_sampler, texcoord).rgba;
#line 187
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 189
float depth = 1 - ReShade::GetLinearizedDepth(texcoord).r;
#line 191
if ((SEnable_Background_Color == true) && (depth < SBackground_Stage_depth))
{
color = lerp(color, SBackground_Color.rgb * 0.00392, SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 0) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Paper_two_stage.rgb, Paper_two_stage.a * SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 1) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Paper_six_stage.rgb, Paper_six_stage.a * SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 2) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Metal_one_stage.rgb, Metal_one_stage.a * SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 3) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Ice_one_stage.rgb, Ice_one_stage.a * SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 4) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Silhouette_one_stage.rgb, Silhouette_one_stage.a * SBackground_Stage_Opacity);
}
else if ((SBackground_Tex_Select == 5) && (depth < SBackground_Stage_depth))
{
color = lerp(color, Silhouette_two_stage.rgb, Silhouette_two_stage.a * SBackground_Stage_Opacity);
}
}
#line 221
technique Silhouette
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_SilhouetteForeground;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_SilhouetteBackground;
}
}

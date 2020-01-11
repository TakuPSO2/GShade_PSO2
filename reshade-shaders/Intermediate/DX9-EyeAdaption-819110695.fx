#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\EyeAdaption.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\EyeAdaption.fx"
#line 16
uniform float fAdp_Delay <
ui_label = "Adaption Delay";
ui_tooltip = "How fast the image adapts to brightness changes.\n"
"0 = instantanous adaption\n"
"2 = very slow adaption";
ui_category = "General settings";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.6;
#line 27
uniform float fAdp_TriggerRadius <
ui_label = "Adaption TriggerRadius";
ui_tooltip = "Screen area, whose average brightness triggers adaption.\n"
"1 = only the center of the image is used\n"
"7 = the whole image is used";
ui_category = "General settings";
ui_type = "slider";
ui_min = 1.0;
ui_max = 7.0;
ui_step = 0.1;
> = 6.0;
#line 39
uniform float fAdp_Equilibrium <
ui_label = "Adaption Equilibrium";
ui_tooltip = "The value of image brightness for which there is no brightness adaption.\n"
"0 = late brightening, early darkening\n"
"1 = early brightening, late darkening";
ui_category = "General settings";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 50
uniform float fAdp_Strength <
ui_label = "Adaption Strength";
ui_tooltip = "Base strength of brightness adaption.\n";
ui_category = "General settings";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 59
uniform bool bAdp_IgnoreOccludedByUI <
ui_label = "Ignore Trigger Area if Occluded by UI (FFXIV)";
ui_category = "General settings";
> = 0;
#line 64
uniform float fAdp_IgnoreTreshold <
ui_label = "Ignore Alpha Treshold";
ui_tooltip = "How visible the UI must be to be ignored"
"0 = any UI, including window shadows prevents occlusion"
"1 = only 100% opaque windows prevent occlusion";
ui_category = "General settings";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.2;
#line 75
uniform float fAdp_BrightenHighlights <
ui_label = "Brighten Highlights";
ui_tooltip = "Brightening strength for highlights.";
ui_category = "Brightening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 84
uniform float fAdp_BrightenMidtones <
ui_label = "Brighten Midtones";
ui_tooltip = "Brightening strength for midtones.";
ui_category = "Brightening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.2;
#line 93
uniform float fAdp_BrightenShadows <
ui_label = "Brighten Shadows";
ui_tooltip = "Brightening strength for shadows.\n"
"Set this to 0 to preserve pure black.";
ui_category = "Brightening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 103
uniform float fAdp_DarkenHighlights <
ui_label = "Darken Highlights";
ui_tooltip = "Darkening strength for highlights.\n"
"Set this to 0 to preserve pure white.";
ui_category = "Darkening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 113
uniform float fAdp_DarkenMidtones <
ui_label = "Darken Midtones";
ui_tooltip = "Darkening strength for midtones.";
ui_category = "Darkening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.2;
#line 122
uniform float fAdp_DarkenShadows <
ui_label = "Darken Shadows";
ui_tooltip = "Darkening strength for shadows.";
ui_category = "Darkening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 133
uniform float Frametime < source = "frametime";>;
#line 136
texture2D TexLuma { Width = 256; Height = 256; Format = R8; MipLevels = 7; };
texture2D TexAvgLuma { Format = R16F; };
texture2D TexAvgLumaLast { Format = R16F; };
#line 140
sampler SamplerLuma { Texture = TexLuma; };
sampler SamplerAvgLuma { Texture = TexAvgLuma; };
sampler SamplerAvgLumaLast { Texture = TexAvgLumaLast; };
#line 145
float PS_Luma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float4 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0, 0));
return dot(color.xyz, float3(0.212656, 0.715158, 0.072186));
}
#line 151
float PS_AvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float avgLumaCurrFrame = tex2Dlod(SamplerLuma, float4(0.5.xx, 0, fAdp_TriggerRadius)).x;
const float avgLumaLastFrame = tex2Dlod(SamplerAvgLumaLast, float4(0.0.xx, 0, 0)).x;
const float uiVisibility = tex2D(ReShade::BackBuffer, float2(0.5, 0.5)).a;
if(bAdp_IgnoreOccludedByUI && uiVisibility > fAdp_IgnoreTreshold)
{
return avgLumaLastFrame;
}
const float delay = sign(fAdp_Delay) * saturate(0.815 + fAdp_Delay / 10.0 - Frametime / 1000.0);
return lerp(avgLumaCurrFrame, avgLumaLastFrame, delay);
}
#line 164
float AdaptionDelta(float luma, float strengthMidtones, float strengthShadows, float strengthHighlights)
{
const float midtones = (4.0 * strengthMidtones - strengthHighlights - strengthShadows) * luma * (1.0 - luma);
const float shadows = strengthShadows * (1.0 - luma);
const float highlights = strengthHighlights * luma;
return midtones + shadows + highlights;
}
#line 172
float4 PS_Adaption(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0, 0));
const float avgLuma = tex2Dlod(SamplerAvgLuma, float4(0.0.xx, 0, 0)).x;
#line 177
color.xyz = pow(abs(color.xyz), 1.0/2.2);
float luma = dot(color.xyz, float3(0.212656, 0.715158, 0.072186));
const float3 chroma = color.xyz - luma;
#line 181
const float avgLumaAdjusted = lerp (avgLuma, 1.4 * avgLuma / (0.4 + avgLuma), fAdp_Equilibrium);
float delta = 0;
#line 184
const float curve = fAdp_Strength * 10.0 * pow(abs(avgLumaAdjusted - 0.5), 4.0);
if (avgLumaAdjusted < 0.5) {
delta = AdaptionDelta(luma, fAdp_BrightenMidtones, fAdp_BrightenShadows, fAdp_BrightenHighlights);
} else {
delta = -AdaptionDelta(luma, fAdp_DarkenMidtones, fAdp_DarkenShadows, fAdp_DarkenHighlights);
}
delta *= curve;
#line 192
luma += delta;
color.xyz = saturate(luma + chroma);
color.xyz = pow(abs(color.xyz), 2.2);
#line 196
return color;
}
#line 199
float PS_StoreAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2Dlod(SamplerAvgLuma, float4(0.0.xx, 0, 0)).x;
}
#line 205
technique EyeAdaption {
#line 207
pass Luma
{
VertexShader = PostProcessVS;
PixelShader = PS_Luma;
RenderTarget = TexLuma;
}
#line 214
pass AvgLuma
{
VertexShader = PostProcessVS;
PixelShader = PS_AvgLuma;
RenderTarget = TexAvgLuma;
}
#line 221
pass Adaption
{
VertexShader = PostProcessVS;
PixelShader = PS_Adaption;
}
#line 227
pass StoreAvgLuma
{
VertexShader = PostProcessVS;
PixelShader = PS_StoreAvgLuma;
RenderTarget = TexAvgLumaLast;
}
}

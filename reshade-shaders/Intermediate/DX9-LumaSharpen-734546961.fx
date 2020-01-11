#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\LumaSharpen.fx"
#line 14
uniform float sharp_strength <
ui_type = "slider";
ui_min = 0.1; ui_max = 3.0;
ui_label = "Shapening strength";
ui_tooltip = "Strength of the sharpening";
#line 20
> = 0.65;
uniform float sharp_clamp <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.005;
ui_label = "Sharpening limit";
ui_tooltip = "Limits maximum amount of sharpening a pixel receives\nThis helps avoid \"haloing\" artifacts which would otherwise occur when you raised the strength too much.";
> = 0.035;
uniform int pattern <
ui_type = "combo";
ui_items =	"Fast" "\0"
"Normal" "\0"
"Wider"	"\0"
"Pyramid shaped" "\0";
ui_label = "Sample pattern";
ui_tooltip = "Choose a sample pattern.\n"
"Fast is faster but slightly lower quality.\n"
"Normal is normal.\n"
"Wider is less sensitive to noise but also to fine details.\n"
"Pyramid has a slightly more aggresive look.";
> = 1;
uniform float offset_bias <
ui_type = "slider";
ui_min = 0.0; ui_max = 6.0;
ui_label = "Offset bias";
ui_tooltip = "Offset bias adjusts the radius of the sampling pattern. I designed the pattern for an offset bias of 1.0, but feel free to experiment.";
> = 1.0;
uniform bool show_sharpen <
ui_label = "Show sharpening pattern";
ui_tooltip = "Visualize the strength of the sharpen\nThis is useful for seeing what areas the sharpning affects the most";
> = false;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\LumaSharpen.fx"
#line 64
float3 LumaSharpenPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 67
const float3 ori = tex2D(ReShade::BackBuffer, tex).rgb; 
#line 70
float3 sharp_strength_luma = (float3(0.2126, 0.7152, 0.0722)       * sharp_strength); 
#line 75
float3 blur_ori;
#line 82
if (pattern == 0)
{
#line 89
blur_ori  = tex2D(ReShade::BackBuffer, tex + (ReShade::PixelSize / 3.0) * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + (-ReShade::PixelSize / 3.0) * offset_bias).rgb; 
#line 95
blur_ori /= 2;  
#line 97
sharp_strength_luma *= 1.5; 
}
#line 101
if (pattern == 1)
{
#line 108
blur_ori  = tex2D(ReShade::BackBuffer, tex + float2(ReShade::PixelSize.x, -ReShade::PixelSize.y) * 0.5 * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - ReShade::PixelSize * 0.5 * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + ReShade::PixelSize * 0.5 * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - float2(ReShade::PixelSize.x, -ReShade::PixelSize.y) * 0.5 * offset_bias).rgb; 
#line 113
blur_ori *= 0.25;  
}
#line 117
if (pattern == 2)
{
#line 126
blur_ori  = tex2D(ReShade::BackBuffer, tex + ReShade::PixelSize * float2(0.4, -1.2) * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex - ReShade::PixelSize * float2(1.2, 0.4) * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + ReShade::PixelSize * float2(1.2, 0.4) * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - ReShade::PixelSize * float2(0.4, -1.2) * offset_bias).rgb; 
#line 131
blur_ori *= 0.25;  
#line 133
sharp_strength_luma *= 0.51;
}
#line 137
if (pattern == 3)
{
#line 144
blur_ori  = tex2D(ReShade::BackBuffer, tex + float2(0.5 * ReShade::PixelSize.x, -ReShade::PixelSize.y * offset_bias)).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(offset_bias * -ReShade::PixelSize.x, 0.5 * -ReShade::PixelSize.y)).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(offset_bias * ReShade::PixelSize.x, 0.5 * ReShade::PixelSize.y)).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(0.5 * -ReShade::PixelSize.x, ReShade::PixelSize.y * offset_bias)).rgb; 
#line 151
blur_ori /= 4.0;  
#line 153
sharp_strength_luma *= 0.666; 
}
#line 161
const float3 sharp = ori - blur_ori;  
#line 172
const float4 sharp_strength_luma_clamp = float4(sharp_strength_luma * (0.5 / sharp_clamp),0.5); 
#line 175
float sharp_luma = saturate(dot(float4(sharp,1.0), sharp_strength_luma_clamp)); 
sharp_luma = (sharp_clamp * 2.0) * sharp_luma - sharp_clamp; 
#line 180
float3 outputcolor = ori + sharp_luma;    
#line 186
if (show_sharpen)
{
#line 189
outputcolor = saturate(0.5 + (sharp_luma * 4.0)).rrr;
}
#line 192
return saturate(outputcolor);
}
#line 195
technique LumaSharpen
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LumaSharpenPass;
}
}

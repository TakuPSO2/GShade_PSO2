#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CEOG.fx"
#line 9
uniform float ceog_ctr <
ui_type = "slider";
ui_min = -100.0; ui_max = 100.0;
ui_step = 0.01;
ui_tooltip = "Contrast";
ui_label = "Contrast";
> = 0.0;
uniform float ceog_e <
ui_type = "slider";
ui_min = -20.0; ui_max = 20.0;
ui_step = 0.01;
ui_tooltip = "Exposure";
ui_label = "Exposure";
> = 0.0;
uniform float ceog_o <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.005;
ui_tooltip = "Offset";
ui_label = "Offset";
> = 0.00;
uniform float ceog_g <
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_step = 0.01;
ui_tooltip = "Gamma";
ui_label = "Gamma";
> = 1.0;
uniform float Saturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "Adjust saturation";
> = 0.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CEOG.fx"
#line 45
float3 CEOGPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 49
const float mn=min(color.r, min(color.g, color.b));
const float mx=max(color.r, max(color.g, color.b));
#line 52
if(mn >= 0.00  && mx <= 1.00 )
{
float ctr=ceog_ctr;
const float3 color_tmp=color.rgb;
#line 57
ctr=(ctr < 0.0) ? max(ctr/100.0, -100.0) : min(ctr, 100.0);
color.rgb=(color.rgb-0.5)*max(ctr+1.0, 0.0)+0.5;
#line 60
color.rgb=pow(saturate(color.rgb*pow(2, ceog_e)+ceog_o), 1/ceog_g);
#line 62
const float3 diffcolor = color - dot(color, (1.0 / 3.0));
color = (color + diffcolor * Saturation) / (1 + (diffcolor * Saturation)); 
#line 65
if(0.00  > 0 && 1.00  < 1)
{
const float dlt=(1.00 -0.00 )*0.25;
if(mn <= (0.00 +dlt)) color.rgb=lerp(color_tmp, color.rgb, (mn-0.00 )/dlt);
else if(mx >= (1.00 -dlt)) color.rgb=lerp(color_tmp, color.rgb, (1.00 -mx)/dlt);
}
}
#line 73
return color;
}
#line 77
technique CEOG
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CEOGPass;
}
}

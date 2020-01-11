#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CrossProcess.fx"
#line 6
uniform float CrossContrast <
ui_type = "slider";
ui_min = 0.50; ui_max = 2.0;
ui_tooltip = "Contrast";
> = 1.0;
uniform float CrossSaturation <
ui_type = "slider";
ui_min = 0.50; ui_max = 2.00;
ui_tooltip = "Saturation";
> = 1.0;
uniform float CrossBrightness <
ui_type = "slider";
ui_min = -1.000; ui_max = 1.000;
ui_tooltip = "Brightness";
> = 0.0;
uniform float CrossAmount <
ui_type = "slider";
ui_min = 0.05; ui_max = 1.50;
ui_tooltip = "Cross Amount";
> = 0.50;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\CrossProcess.fx"
#line 30
float3 CrossPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float2 CrossMatrix [3] = {
float2 (1.03, 0.04),
float2 (1.09, 0.01),
float2 (0.78, 0.13),
};
#line 39
float3 image1 = color.rgb;
float3 image2 = color.rgb;
const float gray = dot(float3(0.5,0.5,0.5), image1);
image1 = lerp (gray, image1,CrossSaturation);
image1 = lerp (0.35, image1,CrossContrast);
image1 +=CrossBrightness;
image2.r = image1.r * CrossMatrix[0].x + CrossMatrix[0].y;
image2.g = image1.g * CrossMatrix[1].x + CrossMatrix[1].y;
image2.b = image1.b * CrossMatrix[2].x + CrossMatrix[2].y;
#line 49
return lerp(image1, image2, CrossAmount);
}
#line 53
technique Cross
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CrossPass;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SunsetFilter.fx"
#line 11
uniform float3 ColorA <
ui_label = "Colour (A)";
ui_type = "color";
ui_category = "Colors";
> = float3(1.0, 0.0, 0.0);
#line 17
uniform float3 ColorB <
ui_label = "Colour (B)";
ui_type = "color";
ui_category = "Colors";
> = float3(0.0, 0.0, 0.0);
#line 23
uniform bool Flip <
ui_label = "Color flip";
ui_category = "Colors";
> = false;
#line 28
uniform int Axis <
ui_label = "Angle";
ui_type = "slider";
ui_step = 1;
ui_min = -180; ui_max = 180;
ui_category = "Controls";
> = -7;
#line 36
uniform float Scale <
ui_label = "Gradient sharpness";
ui_type = "slider";
ui_min = 0.5; ui_max = 1.0; ui_step = 0.005;
ui_category = "Controls";
> = 1.0;
#line 43
uniform float Offset <
ui_label = "Position";
ui_type = "slider";
ui_step = 0.002;
ui_min = 0.0; ui_max = 0.5;
ui_category = "Controls";
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\SunsetFilter.fx"
#line 54
float Overlay(float Layer)
{
const float Min = min(Layer, 0.5);
const float Max = max(Layer, 0.5);
return 2 * (Min * Min + 2 * Max - Max * Max) - 1.5;
}
#line 62
float3 Screen(float3 LayerA, float3 LayerB)
{ return 1.0 - (1.0 - LayerA) * (1.0 - LayerB); }
#line 65
void SunsetFilterPS(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD, out float3 Image : SV_Target)
{
#line 68
Image.rgb = tex2D(ReShade::BackBuffer, UvCoord).rgb;
#line 70
float2 UvCoordAspect = UvCoord;
UvCoordAspect.y += ReShade::AspectRatio * 0.5 - 0.5;
UvCoordAspect.y /= ReShade::AspectRatio;
#line 74
UvCoordAspect = UvCoordAspect * 2 - 1;
UvCoordAspect *= Scale;
#line 78
const float Angle = radians(-Axis);
const float2 TiltVector = float2(sin(Angle), cos(Angle));
#line 82
float BlendMask = dot(TiltVector, UvCoordAspect) + Offset;
BlendMask = Overlay(BlendMask * 0.5 + 0.5); 
#line 86
if (Flip)
Image = Screen(Image.rgb, lerp(ColorA.rgb, ColorB.rgb, 1 - BlendMask));
else
Image = Screen(Image.rgb, lerp(ColorA.rgb, ColorB.rgb, BlendMask));
}
#line 92
technique SunsetFilter
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SunsetFilterPS;
}
}

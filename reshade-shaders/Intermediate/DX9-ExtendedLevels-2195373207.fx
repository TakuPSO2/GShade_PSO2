#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ExtendedLevels.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ExtendedLevels.fx"
#line 58
static const float PI = 3.141592653589793238462643383279f;
#line 64
uniform bool EnableLevels <
ui_tooltip = "Enable or Disable Levels for TV <> PC or custome color range";
> = true;
#line 68
uniform float3 InputBlackPoint <
ui_type = "color";
ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = float3(16/255.0f, 18/255.0f, 20/255.0f);
#line 73
uniform float3 InputWhitePoint <
ui_type = "color";
ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = float3(233/255.0f, 222/255.0f, 211/255.0f);
#line 78
uniform float3 InputGamma <
ui_type = "slider";
ui_min = 0.001f; ui_max = 10.00f; step = 0.001f;
ui_label = "RGB Gamma";
ui_tooltip = "Adjust midtones for Red, Green and Blue.";
> = float3(1.00f,1.00f,1.00f);
#line 85
uniform float3 OutputBlackPoint <
ui_type = "color";
ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = float3(0/255.0f, 0/255.0f, 0/255.0f);
#line 90
uniform float3 OutputWhitePoint <
ui_type = "color";
ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = float3(255/255.0f, 255/255.0f, 255/255.0f);
#line 111
uniform float3 ColorRangeShift <
ui_type = "color";
ui_tooltip = "Some games like Watch Dogs 2 has color range 16-235 downshifted to 0-219, so this option was added to upshift color range before expanding it. RGB value entered here will be just added to default color value. Negative values impossible at the moment in game, but can be added, in shader if downshifting needed. 0 disables shifting.";
> = float3(0/255.0f, 0/255.0f, 0/255.0f);
#line 116
uniform int ColorRangeShiftSwitch <
ui_type = "slider";
ui_min = -1; ui_max = 1;
ui_tooltip = "Workaround for lack of negative color values in Reshade UI: -1 to downshift, 1 to upshift, 0 to disable";
> = 0;
#line 140
uniform bool ACEScurve <
ui_tooltip = "Enable or Disable ACES for improved contrast and luminance";
> = false;
#line 144
uniform int3 ACESLuminancePercentage <
ui_type = "slider";
ui_min = 75; ui_max = 175; step = 1;
ui_tooltip = "Percentage of ACES Luminance. Can be used to avoid some color clipping.";
> = int3(100,100,100);
#line 151
uniform bool HighlightClipping <
ui_tooltip = "Colors between the two points will stretched, which increases contrast, but details above and below the points are lost (this is called clipping).\n0 Highlight the pixels that clip. Red = Some details are lost in the highlights, Yellow = All details are lost in the highlights, Blue = Some details are lost in the shadows, Cyan = All details are lost in the shadows.";
> = false;
#line 159
float3 ACESFilmRec2020( float3 x )
{
x = x * ACESLuminancePercentage * 0.005f; 
return ( x * ( 15.8f * x + 2.12f ) ) / ( x * ( 1.2f * x + 5.92f ) + 1.9f );
}
#line 197
float3 InputLevels(float3 color, float3 inputwhitepoint, float3 inputblackpoint)
{
return color = (color - inputblackpoint)/(inputwhitepoint - inputblackpoint);
#line 201
}
#line 204
float3  Outputlevels(float3 color, float3 outputwhitepoint, float3 outputblackpoint)
{
return color * (outputwhitepoint - outputblackpoint) + outputblackpoint;
}
#line 210
float  InputLevel(float color, float inputwhitepoint, float inputblackpoint)
{
return (color - inputblackpoint)/(inputwhitepoint - inputblackpoint);
}
#line 216
float  Outputlevel(float color, float outputwhitepoint, float outputblackpoint)
{
return color * (outputwhitepoint - outputblackpoint) + outputblackpoint;
}
#line 224
float3 LevelsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 InputColor = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 OutputColor = InputColor;
#line 278
if (EnableLevels == true)
{
OutputColor = pow(abs(((InputColor + (ColorRangeShift * ColorRangeShiftSwitch)) - InputBlackPoint)/(InputWhitePoint - InputBlackPoint)), InputGamma) * (OutputWhitePoint - OutputBlackPoint) + OutputBlackPoint;
} else {
OutputColor = InputColor;
}
#line 285
if (ACEScurve == true)
{
OutputColor = ACESFilmRec2020(OutputColor);
}
#line 290
if (HighlightClipping == true)
{
float3 ClippedColor;
#line 295
if (any(OutputColor > saturate(OutputColor)))
ClippedColor = float3(1.0, 1.0, 0.0);
else
ClippedColor = OutputColor;
#line 301
if (any(OutputColor > saturate(OutputColor)))
ClippedColor = float3(1.0, 0.0, 0.0);
else
ClippedColor = OutputColor;
#line 307
if (any(OutputColor < saturate(OutputColor)))
ClippedColor = float3(0.0, 1.0, 1.0);
else
ClippedColor = OutputColor;
#line 313
if (any(OutputColor < saturate(OutputColor)))
ClippedColor = float3(0.0, 0.0, 1.0);
else
ClippedColor = OutputColor;
#line 318
OutputColor = ClippedColor;
}
#line 321
return OutputColor;
}
#line 324
technique ExtendedLevels
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LevelsPass;
}
}

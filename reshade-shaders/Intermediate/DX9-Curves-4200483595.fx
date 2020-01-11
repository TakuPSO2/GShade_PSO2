#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Curves.fx"
#line 9
uniform int Mode <
ui_type = "combo";
ui_items = "Luma\0Chroma\0Both Luma and Chroma\0";
ui_tooltip = "Choose what to apply contrast to.";
> = 0;
uniform int Formula <
ui_type = "combo";
ui_items = "Sine\0Abs split\0Smoothstep\0Exp formula\0Simplified Catmull-Rom (0,0,1,1)\0Perlins Smootherstep\0Abs add\0Techicolor Cinestyle\0Parabola\0Half-circles\0Polynomial split\0";
ui_tooltip = "The contrast s-curve you want to use. Note that Technicolor Cinestyle is practically identical to Sine, but runs slower. In fact I think the difference might only be due to rounding errors. I prefer 2 myself, but 3 is a nice alternative with a little more effect (but harsher on the highlight and shadows) and it's the fastest formula.";
> = 4;
#line 20
uniform float Contrast <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "The amount of contrast you want.";
> = 0.65;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Curves.fx"
#line 28
float4 CurvesPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
const float3 lumCoeff = float3(0.2126, 0.7152, 0.0722);  
float Contrast_blend = Contrast;
const float PI = 3.1415927;
#line 41
const float luma = dot(lumCoeff, colorInput.rgb);
#line 43
const float3 chroma = colorInput.rgb - luma;
#line 47
float3 x;
if (Mode == 0)
x = luma; 
else if (Mode == 1)
x = chroma, 
x = x * 0.5 + 0.5; 
else
x = colorInput.rgb; 
#line 61
if (Formula == 0)
{
x = sin(PI * 0.5 * x); 
x *= x;
#line 68
}
#line 71
if (Formula == 1)
{
x = x - 0.5;
x = (x / (0.5 + abs(x))) + 0.5;
#line 77
}
#line 80
if (Formula == 2)
{
#line 83
x = x*x*(3.0 - 2.0*x); 
#line 85
}
#line 88
if (Formula == 3)
{
x = (1.0524 * exp(6.0 * x) - 1.05248) / (exp(6.0 * x) + 20.0855); 
}
#line 94
if (Formula == 4)
{
#line 98
x = x * (x * (1.5 - x) + 0.5); 
#line 100
Contrast_blend = Contrast * 2.0; 
}
#line 104
if (Formula == 5)
{
x = x*x*x*(x*(x*6.0 - 15.0) + 10.0); 
}
#line 110
if (Formula == 6)
{
#line 113
x = x - 0.5;
x = x / ((abs(x)*1.25) + 0.375) + 0.5;
#line 116
}
#line 119
if (Formula == 7)
{
x = (x * (x * (x * (x * (x * (x * (1.6 * x - 7.2) + 10.8) - 4.2) - 3.6) + 2.7) - 1.8) + 2.7) * x * x; 
}
#line 125
if (Formula == 8)
{
x = -0.5 * (x*2.0 - 1.0) * (abs(x*2.0 - 1.0) - 2.0) + 0.5; 
}
#line 131
if (Formula == 9)
{
const float3 xstep = step(x, 0.5); 
const float3 xstep_shift = (xstep - 0.5);
const float3 shifted_x = x + xstep_shift;
#line 137
x = abs(xstep - sqrt(-shifted_x * shifted_x + shifted_x)) - xstep_shift;
#line 154
Contrast_blend = Contrast * 0.5; 
}
#line 158
if (Formula == 10)
{
float3 a = float3(0.0, 0.0, 0.0);
float3 b = float3(0.0, 0.0, 0.0);
#line 163
a = x * x * 2.0;
b = (2.0 * -x + 4.0) * x - 1.0;
if (x.r < 0.5 || x.g < 0.5 || x.b < 0.5)
x = a;
else
x = b;
}
#line 175
if (Mode == 0) 
{
x = lerp(luma, x, Contrast_blend); 
colorInput.rgb = x + chroma; 
}
else if (Mode == 1) 
{
x = x * 2.0 - 1.0; 
const float3 color = luma + x; 
colorInput.rgb = lerp(colorInput.rgb, color, Contrast_blend); 
}
else 
{
const float3 color = x;  
colorInput.rgb = lerp(colorInput.rgb, color, Contrast_blend); 
}
#line 192
return colorInput;
}
#line 195
technique Curves
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CurvesPass;
}
}

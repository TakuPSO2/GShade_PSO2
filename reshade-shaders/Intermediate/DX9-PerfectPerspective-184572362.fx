#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PerfectPerspective.fx"
#line 20
uniform int Projection <
ui_tooltip = "Stereographic projection (shape) preserves angles and proportions,\n"
"best for navigation through tight space.\n\n"
"Equisolid projection (distance) preserves size relations,\n"
"best for navigation in open areas.\n\n"
"Equidistant (speed) maintains angular speed of motion,\n"
"best for chasing fast targets.";
ui_label = "Type of projection";
ui_type = "radio";
ui_items = "Stereographic projection (shape)\0Equisolid projection (distance)\0Equidistant projection (speed)\0";
ui_category = "Distortion Correction";
> = 0;
#line 33
uniform int FOV <
ui_label = "Corrected Field of View";
ui_tooltip = "This setting should match your in-game Field of View";
ui_type = "slider";
ui_step = 0.2;
ui_min = 0; ui_max = 170;
ui_category = "Distortion Correction";
> = 90;
#line 42
uniform float Vertical <
ui_label = "Vertical Curviness Amount";
ui_tooltip = "0.0 - cylindrical projection\n"
"1.0 - spherical projection";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_category = "Distortion Correction";
> = 0.5;
#line 51
uniform float VerticalScale <
ui_type = "slider";
ui_label = "Vertical Proportions Scale";
ui_tooltip = "Adjust proportions for cylindrical Panini projection";
ui_min = 0.8; ui_max = 1.0;
ui_category = "Distortion Correction";
> = 0.95;
#line 59
uniform int Type <
ui_label = "Type of FOV (Field of View)";
ui_tooltip = "...in stereographic mode\n\n"
"If image bulges in movement (too high FOV),\n"
"change it to 'Diagonal'.\n"
"When proportions are distorted at the periphery\n"
"(too low FOV), choose 'Vertical'.";
ui_type = "combo";
ui_items = "Horizontal FOV\0Diagonal FOV\0Vertical FOV\0";
ui_category = "Distortion Correction";
> = 0;
#line 71
uniform float Zooming <
ui_label = "Borders Scale";
ui_tooltip = "Adjust image scale and cropped area";
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0; ui_step = 0.001;
ui_category = "Borders Settings";
> = 1.0;
#line 79
uniform float4 BorderColor <
ui_label = "Color of Borders";
ui_tooltip = "Use Alpha to change transparency";
ui_type = "color";
ui_category = "Borders Settings";
> = float4(0.027, 0.027, 0.027, 0.0);
#line 86
uniform bool MirrorBorders <
ui_label = "Mirrored Borders";
ui_tooltip = "Choose original or mirrored image at the borders";
ui_category = "Borders Settings";
> = true;
#line 92
uniform bool DebugPreview <
ui_label = "Display Resolution Scale Map";
ui_tooltip = "Color map of the Resolution Scale:\n\n"
" Red   - undersampling\n"
" Green - supersampling\n"
" Blue  - neutral sampling";
ui_category = "Debug Tools";
> = false;
#line 101
uniform int2 ResScale <
ui_label = "Super Resolution Scale";
ui_tooltip = "Simulates application running beyond\n"
"native screen resolution (using VSR or DSR)\n\n"
" First value  - screen resolution\n"
" Second value - virtual super resolution";
ui_type = "slider";
ui_min = 16; ui_max = 16384; ui_step = 0.2;
ui_category = "Debug Tools";
> = int2(1920, 1920);
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PerfectPerspective.fx"
#line 120
sampler SamplerColor
{
Texture = ReShade::BackBufferTex;
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 128
float Grayscale(float3 Color)
{ return max(max(Color.r,Color.g),Color.b); }
#line 136
float Stereographic(float2 Coordinates)
{
if(FOV==0.0) return 1.0; 
#line 140
const float SqrTanFOVq = pow(tan(radians(FOV * 0.25)),2.0);
const float R2 = dot(Coordinates, Coordinates);
return (1.0 - SqrTanFOVq) / (1.0 - SqrTanFOVq * R2);
}
#line 145
float Equisolid(float2 Coordinates)
{
if(FOV==0.0) return 1.0; 
const float rFOV = radians(FOV);
const float R = length(Coordinates);
return tan(asin(sin(rFOV*0.25)*R)*2.0)/(tan(rFOV*0.5)*R);
}
#line 153
float Equidistant(float2 Coordinates)
{
if(FOV==0.0) return 1.0; 
const float rFOVh = radians(FOV*0.5);
const float R = length(Coordinates);
return tan(R*rFOVh)/(tan(rFOVh)*R);
}
#line 163
float3 PerfectPerspectivePS(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 166
const float AspectR = 1.0 / ReShade::AspectRatio;
#line 168
const float2 ScrPixelSize = ReShade::PixelSize;
#line 171
float FovType; switch(Type)
{
case 0:{ FovType = 1.0; break; } 
case 1:{ FovType = sqrt(AspectR * AspectR + 1.0); break; } 
case 2:{ FovType = AspectR; break; } 
}
#line 179
float2 SphCoord = texcoord * 2.0 - 1.0;
#line 181
SphCoord.y *= AspectR;
#line 184
SphCoord *= clamp(Zooming, 0.5, 2.0) / FovType; 
#line 187
switch(Projection)
{
case 0:{ SphCoord *= Stereographic(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } 
case 1:{ SphCoord *= Equisolid(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } 
case 2:{ SphCoord *= Equidistant(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } 
}
#line 195
SphCoord.y /= AspectR;
#line 198
if(VerticalScale != 1.0) SphCoord.y /= lerp(VerticalScale, 1.0, Vertical);
#line 201
const float2 PixelSize = fwidth(SphCoord);
#line 204
const float2 AtBorders = smoothstep( 1.0 - PixelSize, 1.0 + PixelSize, abs(SphCoord) );
#line 207
SphCoord = SphCoord * 0.5 + 0.5;
#line 210
float3 Display = tex2D(SamplerColor, SphCoord).rgb;
#line 213
if (MirrorBorders)
Display = lerp(
Display,
lerp(
Display,
BorderColor.rgb,
BorderColor.a
),
max(AtBorders.x, AtBorders.y)
);
else
Display = lerp(
Display,
lerp(
tex2D(SamplerColor, texcoord).rgb,
BorderColor.rgb,
BorderColor.a
),
max(AtBorders.x, AtBorders.y)
);
#line 235
if(DebugPreview)
{
#line 238
float4 RadialCoord = float4(texcoord, SphCoord) * 2.0 - 1.0;
#line 240
RadialCoord.yw *= AspectR;
#line 243
static const float3 UnderSmpl = float3(1.0, 0.0, 0.2); 
static const float3 SuperSmpl = float3(0.0, 1.0, 0.5); 
static const float3 NeutralSmpl = float3(0.0, 0.5, 1.0); 
#line 248
float PixelScaleMap = fwidth( length(RadialCoord.xy) );
#line 250
PixelScaleMap *= ResScale.x / (fwidth( length(RadialCoord.zw) ) * ResScale.y);
PixelScaleMap -= 1.0;
#line 254
float3 ResMap = lerp(
SuperSmpl,
UnderSmpl,
step(0.0, PixelScaleMap)
);
#line 261
PixelScaleMap = 1.0 - abs(PixelScaleMap);
PixelScaleMap = saturate(PixelScaleMap * 4.0 - 3.0); 
#line 265
ResMap = lerp(ResMap, NeutralSmpl, PixelScaleMap);
#line 268
Display = normalize(ResMap) * (0.8 * Grayscale(Display) + 0.2);
}
#line 271
return Display;
}
#line 279
technique PerfectPerspective < ui_label = "Perfect Perspective"; ui_tooltip = "Correct fisheye distortion"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PerfectPerspectivePS;
}
}

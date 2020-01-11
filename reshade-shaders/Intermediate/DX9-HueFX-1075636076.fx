#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\HueFX.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\HueFX.fx"
#line 9
uniform float hueMid <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Hue Mid";
ui_tooltip = "Hue (rotation around the color wheel) of the color which you want to keep";
> = 0.6;
uniform float hueRange <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Hue Range";
ui_tooltip = "Range of different hue's around the hueMid that will also kept";
> = 0.1;
uniform float satLimit <
ui_type = "slider";
ui_min = 0.1; ui_max = 4.0;
ui_label = "Saturation Limit";
ui_tooltip = "Saturation control, better keep it higher than 0 for strong colors in contrast to the gray stuff around";
> = 2.9;
uniform float fxcolorMix <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Color Mix";
ui_tooltip = "Interpolation between the original and the effect, 0 means full original image, 1 means full grey-color image";
> = 2.9;
uniform bool fxuseColorSat <
ui_label = "Use Color Saturation";
ui_tooltip = "This will use original color saturation as an added limiter to the strength of the effect.";
> = 0;
#line 41
float smootherstep(float edge0, float edge1, float x)
{
x = clamp((x - edge0)/(edge1 - edge0), 0.0, 1.0);
return x*x*x*(x*(x*6 - 15) + 10);
}
#line 47
float3 Hue(in float3 RGB)
{
#line 50
const float Epsilon = 1e-10;
float4 P;
if (RGB.g < RGB.b)
P = float4(RGB.bg, -1.0, 2.0/3.0);
else
P = float4(RGB.gb, 0.0, -1.0/3.0);
#line 57
float4 Q;
if (RGB.r < P.x)
Q = float4(P.xyw, RGB.r);
else
Q = float4(RGB.r, P.yzx);
#line 63
const float C = Q.x - min(Q.w, Q.y);
const float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
return float3(H, C, Q.x);
}
#line 68
float3 HUEFXPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 72
float3 fxcolor = saturate( color.xyz );
const float greyVal = dot( fxcolor.xyz, float3(0.212656, 0.715158, 0.072186).xyz );
const float3 HueSat = Hue( fxcolor.xyz );
const float colorHue = HueSat.x;
const float colorInt = HueSat.z - HueSat.y * 0.5;
float colorSat = HueSat.y / ( 1.0 - abs( colorInt * 2.0 - 1.0 ) * 1e-10 );
#line 80
if ( fxuseColorSat == 0 )   colorSat = 1.0f;
#line 82
const float hueMin_1 = hueMid - hueRange;
const float hueMax_1 = hueMid + hueRange;
float hueMin_2 = 0.0f;
float hueMax_2 = 0.0f;
#line 88
if ( hueMin_1 < 0.0 )
{
hueMin_2 = 1.0f + hueMin_1;
hueMax_2 = 1.0f + hueMid;
#line 93
if ( colorHue >= hueMin_1 && colorHue <= hueMid )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
else if ( colorHue >= hueMid && colorHue <= hueMax_1 )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
else if ( colorHue >= hueMin_2 && colorHue <= hueMax_2 )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_2, hueMax_2, colorHue ) * ( colorSat * satLimit ));
else
fxcolor.xyz = greyVal.xxx;
}
#line 103
else if ( hueMax_1 > 1.0 )
{
hueMin_2 = 0.0f - ( 1.0f - hueMid );
hueMax_2 = hueMax_1 - 1.0f;
#line 108
if ( colorHue >= hueMin_1 && colorHue <= hueMid )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
else if ( colorHue >= hueMid && colorHue <= hueMax_1 )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
else if ( colorHue >= hueMin_2 && colorHue <= hueMax_2 )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMin_2, hueMax_2, colorHue )) * ( colorSat * satLimit ));
else
fxcolor.xyz = greyVal.xxx;
}
#line 118
else
{
if ( colorHue >= hueMin_1 && colorHue <= hueMid )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
else if ( colorHue > hueMid && colorHue <= hueMax_1 )
fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
else
fxcolor.xyz = greyVal.xxx;
}
#line 129
return lerp( color.xyz, fxcolor.xyz, fxcolorMix );
}
#line 132
technique HueFX
{
pass
{
VertexShader = PostProcessVS;
PixelShader = HUEFXPass;
}
}

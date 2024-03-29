#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\HSLShift.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\HSLShift.fx"
#line 11
uniform float3 HUERed <
ui_type = "color";
ui_label="Red";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Red Default Value:\n"
"255 : R:  191, G:   64, B:   64\n"
"0.00: R:0.750, G:0.250, B:0.250";
> = float3(0.75, 0.25, 0.25);
#line 25
uniform float3 HUEOrange <
ui_type = "color";
ui_label = "Orange";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Orange Default Value:\n"
"255 : R:  191, G:  128, B:   64\n"
"0.00: R:0.750, G:0.500, B:0.250";
> = float3(0.75, 0.50, 0.25);
#line 39
uniform float3 HUEYellow <
ui_type = "color";
ui_label = "Yellow";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Yellow Default Value:\n"
"255 : R:  191, G:  191, B:   64\n"
"0.00: R:0.750, G:0.750, B:0.250";
> = float3(0.75, 0.75, 0.25);
#line 53
uniform float3 HUEGreen <
ui_type = "color";
ui_label = "Green";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Green Default Value:\n"
"255 : R:   64, G:  191, B:   64\n"
"0.00: R:0.250, G:0.750, B:0.250";
> = float3(0.25, 0.75, 0.25);
#line 67
uniform float3 HUECyan <
ui_type = "color";
ui_label = "Cyan";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Cyan Default Value:\n"
"255 : R:   64, G:  191, B:  191\n"
"0.00: R:0.250, G:0.750, B:0.750";
> = float3(0.25, 0.75, 0.75);
#line 81
uniform float3 HUEBlue <
ui_type = "color";
ui_label="Blue";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Blue Default Value:\n"
"255 : R:   64, G:   64, B:  191\n"
"0.00: R:0.250, G:0.250, B:0.750";
> = float3(0.25, 0.25, 0.75);
#line 95
uniform float3 HUEPurple <
ui_type = "color";
ui_label="Purple";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Purple Default Value:\n"
"255 : R:  128, G:   64, B:  191\n"
"0.00: R:0.500, G:0.250, B:0.750";
> = float3(0.50, 0.25, 0.75);
#line 109
uniform float3 HUEMagenta <
ui_type = "color";
ui_label="Magenta";
ui_tooltip =
"Be careful. Do not to push too far!\n"
"You can only shift as far as the next\n"
"or previous hue's current value.\n\n"
"Editing is easiest using the widget\n"
"Click the colored box to open it.\n\n"
"RGB Magenta Default Value:\n"
"255 : R:  191, G:   64, B:  191\n"
"0.00: R:0.750, G:0.250, B:0.750";
> = float3(0.75, 0.25, 0.75);
#line 126
static const float HSL_Threshold_Base  = 0.05;
static const float HSL_Threshold_Curve = 1.0;
#line 129
float3 RGB_to_HSL(float3 color)
{
float3 HSL   = 0.0f;
const float  M     = max(color.r, max(color.g, color.b));
const float  C     = M - min(color.r, min(color.g, color.b));
HSL.z = M - 0.5 * C;
#line 136
if (C != 0.0f)
{
float3 Delta  = (color.brg - color.rgb) / C + float3(2.0f, 4.0f, 6.0f);
Delta *= step(M, color.gbr); 
HSL.x = frac(max(Delta.r, max(Delta.g, Delta.b)) / 6.0);
if (HSL.z == 1)
HSL.y = 0.0;
else
HSL.y = C / (1 - abs( 2 * HSL.z - 1));
}
#line 147
return HSL;
}
#line 150
float3 Hue_to_RGB( float h)
{
return saturate(float3( abs(h * 6.0f - 3.0f) - 1.0f,
2.0f - abs(h * 6.0f - 2.0f),
2.0f - abs(h * 6.0f - 4.0f)));
}
#line 157
float3 HSL_to_RGB( float3 HSL )
{
return (Hue_to_RGB(HSL.x) - 0.5) * (1.0 - abs(2.0 * HSL.z - 1)) * HSL.y + HSL.z;
}
#line 162
float LoC( float L0, float L1, float angle)
{
return sqrt(L0*L0+L1*L1-2.0*L0*L1*cos(angle));
}
#line 167
float3 HSLShift(float3 color)
{
const float3 hsl = RGB_to_HSL(color);
static const float4 node[9]=
{
float4(HUERed, 0.0),
float4(HUEOrange, 30.0),
float4(HUEYellow, 60.0),
float4(HUEGreen, 120.0),
float4(HUECyan, 180.0),
float4(HUEBlue, 240.0),
float4(HUEPurple, 270.0),
float4(HUEMagenta, 300.0),
float4(HUERed, 360.0),
};
#line 183
int base;
for(int i=0; i<8; i++) if(node[i].a < hsl.r*360.0 )base = i;
#line 186
float w = saturate((hsl.r*360.0-node[base].a)/(node[base+1].a-node[base].a));
#line 188
const float3 H0 = RGB_to_HSL(node[base].rgb);
float3 H1 = RGB_to_HSL(node[base+1].rgb);
#line 191
if (H1.x < H0.x)
H1.x += 1.0;
else
H1.x += 0.0;
#line 196
float3 shift = frac(lerp( H0, H1 , w));
w = max( hsl.g, 0.0)*max( 1.0-hsl.b, 0.0);
shift.b = (shift.b - 0.5)*(pow(w, HSL_Threshold_Curve)*(1.0-HSL_Threshold_Base)+HSL_Threshold_Base)*2.0;
#line 200
return HSL_to_RGB(saturate(float3(shift.r, hsl.g*(shift.g*2.0), hsl.b*(1.0+shift.b))));
}
#line 205
float4	PS_HSLShift(float4 position : SV_Position, float2 txcoord : TexCoord) : SV_Target
{
return float4(HSLShift(tex2D(ReShade::BackBuffer, txcoord).rgb), 1.0);
}
#line 213
technique HSLShift
{
pass HSLPass
{
VertexShader = PostProcessVS;
PixelShader = PS_HSLShift;
}
}

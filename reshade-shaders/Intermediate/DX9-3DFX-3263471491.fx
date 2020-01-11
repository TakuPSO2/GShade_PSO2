#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\3DFX.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\3DFX.fx"
#line 7
uniform float DITHERAMOUNT <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Dither Amount [3DFX]";
> = 0.5;
#line 14
uniform int DITHERBIAS <
ui_type = "slider";
ui_min = -16;
ui_max = 16;
ui_label = "Dither Bias [3DFX]";
> = -1;
#line 21
uniform float LEIFX_LINES <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_label = "Lines Intensity [3DFX]";
> = 1.0;
#line 28
uniform float LEIFX_PIXELWIDTH <
ui_type = "slider";
ui_min = 0.0;
ui_max = 100.0;
ui_label = "Pixel Width [3DFX]";
> = 1.5;
#line 35
uniform float GAMMA_LEVEL <
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_label = "Gamma Level [3DFX]";
> = 1.0;
#line 50
float mod2(float x, float y)
{
return x - y * floor (x/y);
}
#line 55
float fmod(float a, float b)
{
const float c = frac(abs(a/b))*abs(b);
if (a < 0)
return -c;
else
return c;
}
#line 64
float4 PS_3DFX(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
#line 68
float2 res;
res.x = ReShade::ScreenSize.x;
res.y = ReShade::ScreenSize.y;
#line 72
float2 ditheu = texcoord.xy * res.xy;
#line 74
ditheu.x = texcoord.x * res.x;
ditheu.y = texcoord.y * res.y;
#line 80
const int ditx = int(fmod(ditheu.x, 4.0));
const int dity = int(fmod(ditheu.y, 4.0));
const int ditdex = ditx * 4 + dity; 
float3 color;
float3 colord;
color.r = colorInput.r * 255;
color.g = colorInput.g * 255;
color.b = colorInput.b * 255;
int yeh = 0;
int ohyes = 0;
#line 91
const float erroredtable[16] = {
16,4,13,1,
8,12,5,9,
14,2,15,3,
6,10,7,11
};
#line 103
if (yeh++==ditdex) ohyes = erroredtable[0];
else if (yeh++==ditdex) ohyes = erroredtable[1];
else if (yeh++==ditdex) ohyes = erroredtable[2];
else if (yeh++==ditdex) ohyes = erroredtable[3];
else if (yeh++==ditdex) ohyes = erroredtable[4];
else if (yeh++==ditdex) ohyes = erroredtable[5];
else if (yeh++==ditdex) ohyes = erroredtable[6];
else if (yeh++==ditdex) ohyes = erroredtable[7];
else if (yeh++==ditdex) ohyes = erroredtable[8];
else if (yeh++==ditdex) ohyes = erroredtable[9];
else if (yeh++==ditdex) ohyes = erroredtable[10];
else if (yeh++==ditdex) ohyes = erroredtable[11];
else if (yeh++==ditdex) ohyes = erroredtable[12];
else if (yeh++==ditdex) ohyes = erroredtable[13];
else if (yeh++==ditdex) ohyes = erroredtable[14];
else if (yeh++==ditdex) ohyes = erroredtable[15];
#line 121
ohyes = 17 - (ohyes - 1); 
ohyes *= DITHERAMOUNT;
ohyes += DITHERBIAS;
#line 125
colord.r = color.r + ohyes;
colord.g = color.g + (ohyes / 2);
colord.b = color.b + ohyes;
colorInput.rgb = colord.rgb * 0.003921568627451; 
#line 134
const float why = 1;
float3 reduceme = 1;
const float radooct = 32;	
#line 138
reduceme.r = pow(colorInput.r, why);
reduceme.r *= radooct;
reduceme.r = float(floor(reduceme.r));
reduceme.r /= radooct;
reduceme.r = pow(reduceme.r, why);
#line 144
reduceme.g = pow(colorInput.g, why);
reduceme.g *= radooct * 2;
reduceme.g = float(floor(reduceme.g));
reduceme.g /= radooct * 2;
reduceme.g = pow(reduceme.g, why);
#line 150
reduceme.b = pow(colorInput.b, why);
reduceme.b *= radooct;
reduceme.b = float(floor(reduceme.b));
reduceme.b /= radooct;
reduceme.b = pow(reduceme.b, why);
#line 156
colorInput.rgb = reduceme.rgb;
#line 159
{
float leifx_linegamma = (LEIFX_LINES / 10);
const float horzline1 = 	(fmod(ditheu.y, 2.0));
if (horzline1 < 1)	leifx_linegamma = 0;
#line 164
colorInput.r += leifx_linegamma;
colorInput.g += leifx_linegamma;
colorInput.b += leifx_linegamma;
}
#line 169
return colorInput;
}
#line 172
float4 PS_3DFX1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
float2 pixel;
#line 177
pixel.x = 1 / ReShade::ScreenSize.x;
pixel.y = 1 / ReShade::ScreenSize.y;
#line 180
const float3 pixel1 = tex2D(ReShade::BackBuffer, texcoord + float2((pixel.x), 0)).rgb;
const float3 pixel2 = tex2D(ReShade::BackBuffer, texcoord + float2(-pixel.x, 0)).rgb;
float3 pixelblend;
#line 185
{
float3 pixeldiff;
float3 pixelmake;
float3 pixeldiffleft;
#line 190
pixelmake.rgb = 0;
pixeldiff.rgb = pixel2.rgb- colorInput.rgb;
#line 193
pixeldiffleft.rgb = pixel1.rgb - colorInput.rgb;
#line 195
if (pixeldiff.r > 0.04	) 		pixeldiff.r = 0.04	;
if (pixeldiff.g > (0.04	/2)) 		pixeldiff.g = (0.04	/2);
if (pixeldiff.b > 0.04	) 		pixeldiff.b = 0.04	;
#line 199
if (pixeldiff.r < -0.04	) 		pixeldiff.r = -0.04	;
if (pixeldiff.g < -(0.04	/2)) 		pixeldiff.g = -(0.04	/2);
if (pixeldiff.b < -0.04	) 		pixeldiff.b = -0.04	;
#line 203
if (pixeldiffleft.r > 0.04	) 		pixeldiffleft.r = 0.04	;
if (pixeldiffleft.g > (0.04	/2)) 	pixeldiffleft.g = (0.04	/2);
if (pixeldiffleft.b > 0.04	) 		pixeldiffleft.b = 0.04	;
#line 207
if (pixeldiffleft.r < -0.04	) 	pixeldiffleft.r = -0.04	;
if (pixeldiffleft.g < -(0.04	/2)) 	pixeldiffleft.g = -(0.04	/2);
if (pixeldiffleft.b < -0.04	) 	pixeldiffleft.b = -0.04	;
#line 211
pixelmake.rgb = (pixeldiff.rgb / 4) + (pixeldiffleft.rgb / 16);
colorInput.rgb = (colorInput.rgb + pixelmake.rgb);
}
#line 215
return colorInput;
}
#line 218
float4 PS_3DFX2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
#line 222
float2 res;
res.x = ReShade::ScreenSize.x;
res.y = ReShade::ScreenSize.y;
#line 230
colorInput.r = pow(abs(colorInput.r), 1.0 / GAMMA_LEVEL);
colorInput.g = pow(abs(colorInput.g), 1.0 / GAMMA_LEVEL);
colorInput.b = pow(abs(colorInput.b), 1.0 / GAMMA_LEVEL);
#line 234
return colorInput;
}
#line 237
technique LeiFx_Tech
{
pass LeiFx
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX;
}
pass LeiFx1
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx2
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx3
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx4
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx5
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX2;
}
}

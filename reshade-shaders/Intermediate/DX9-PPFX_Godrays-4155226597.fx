#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PPFX_Godrays.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PPFX_Godrays.fx"
#line 18
uniform int pGodraysSampleAmount <
ui_label = "Sample Amount";
ui_tooltip = "Effectively the ray's resolution. Low values may look coarse but yield a higher framerate.";
ui_type = "slider";
ui_min = 8;
ui_max = 250;
ui_step = 1;
> = 64;
#line 27
uniform float2 pGodraysSource <
ui_label = "Light Source";
ui_tooltip = "The vanishing point of the godrays in screen-space. 0.500,0.500 is the middle of your screen.";
ui_type = "slider";
ui_min = -0.5;
ui_max = 1.5;
ui_step = 0.001;
> = float2(0.5, 0.4);
#line 36
uniform float pGodraysExposure <
ui_label = "Exposure";
ui_tooltip = "Contribution exposure of each single light patch to the final ray. 0.100 should generally be enough.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
ui_step = 0.01;
> = 0.1;
#line 45
uniform float pGodraysFreq <
ui_label = "Frequency";
ui_tooltip = "Higher values result in a higher density of the single rays. '1.000' leads to rays that'll always cover the whole screen. Balance between falloff, samples and this value.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 1.2;
#line 54
uniform float pGodraysThreshold <
ui_label = "Threshold";
ui_tooltip = "Pixels darker than this value won't cast rays.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.65;
#line 63
uniform float pGodraysFalloff <
ui_label = "Falloff";
ui_tooltip = "Lets the rays' brightness fade/falloff with their distance from the light source specified in 'Light Source'.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.0;
ui_step = 0.001;
> = 1.06;
#line 77
texture texColorGRA { Width = 1920; Height = 1080; Format = RGBA16F; };
texture texColorGRB < pooled = true; > { Width = 1920; Height = 1080; Format = RGBA16F; };
texture texGameDepth : DEPTH;
#line 87
sampler SamplerColorGRA
{
Texture = texColorGRA;
AddressU = BORDER;
AddressV = BORDER;
MinFilter = LINEAR;
MagFilter = LINEAR;
};
#line 96
sampler SamplerColorGRB
{
Texture = texColorGRB;
AddressU = BORDER;
AddressV = BORDER;
MinFilter = LINEAR;
MagFilter = LINEAR;
};
#line 105
sampler2D SamplerDepth
{
Texture = texGameDepth;
};
#line 114
static const float3 lumaCoeff = float3(0.2126f,0.7152f,0.0722f);
#line 122
struct VS_OUTPUT_POST
{
float4 vpos : SV_Position;
float2 txcoord : TEXCOORD0;
};
#line 128
struct VS_INPUT_POST
{
uint id : SV_VertexID;
};
#line 137
float linearDepth(float2 txCoords)
{
return (2.0*0.3)/(50.0+0.3-tex2D(SamplerDepth,txCoords).x*(50.0-0.3));
}
#line 147
float4 FX_Godrays( float4 pxInput, float2 txCoords )
{
const float2	stepSize = (txCoords-pGodraysSource) / (pGodraysSampleAmount*pGodraysFreq);
float3	rayMask = 0.0;
float	rayWeight = 1.0;
float	finalWhitePoint = pxInput.w;
#line 154
[loop]
for (int i=1;i<(int)pGodraysSampleAmount;i++)
{
rayMask += saturate(saturate(tex2Dlod(SamplerColorGRB, float4(txCoords-stepSize*(float)i, 0.0, 0.0)).xyz) - pGodraysThreshold) * rayWeight * pGodraysExposure;
finalWhitePoint += rayWeight * pGodraysExposure;
rayWeight /= pGodraysFalloff;
}
#line 162
rayMask.xyz = dot(rayMask.xyz,lumaCoeff.xyz) / (finalWhitePoint-pGodraysThreshold);
return float4(pxInput.xyz+rayMask.xyz,finalWhitePoint);
}
#line 170
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
VS_OUTPUT_POST OUT;
#line 174
if (IN.id == 2)
OUT.txcoord.x = 2.0;
else
OUT.txcoord.x = 0.0;
#line 179
if (IN.id == 1)
OUT.txcoord.y = 2.0;
else
OUT.txcoord.y = 0.0;
#line 184
OUT.vpos = float4(OUT.txcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return OUT;
}
#line 195
float4 PS_LightFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
const float4 res = tex2D(ReShade::BackBuffer,pxCoord);
#line 200
return FX_Godrays(res,pxCoord.xy);
}
#line 203
float4 PS_ColorFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
const float4 res = tex2D(SamplerColorGRA,pxCoord);
#line 208
return float4(res.xyz,1.0);
}
#line 211
float4 PS_ImageFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
const float4 res = tex2D(SamplerColorGRB,pxCoord);
#line 216
return float4(res.xyz,1.0);
}
#line 223
technique PPFX_Godrays < ui_label = "PPFX Godrays"; ui_tooltip = "Godrays | Lets bright areas cast rays on the screen."; >
{
pass lightFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_LightFX;
RenderTarget0 = texColorGRA;
}
#line 232
pass colorFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_ColorFX;
RenderTarget0 = texColorGRB;
}
#line 239
pass imageFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_ImageFX;
}
}

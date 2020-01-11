#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\dh_anime.fx"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reshade.fxh"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\dh_anime.fx"
#line 8
namespace DHAnime {
#line 12
uniform int iBlackLineThickness <
ui_category = "Black lines";
ui_label = "Thickness";
ui_type = "slider";
ui_min = 0;
ui_max = 16;
ui_step = 1;
> = 3;
uniform float fBlackLineThreshold <
ui_category = "Black lines";
ui_label = "Threshold";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.995;
#line 29
uniform float iSurfaceBlur <
ui_category = "Colors";
ui_label = "Surface blur";
ui_type = "slider";
ui_min = 0;
ui_max = 16;
ui_step = 1;
> = 3;
#line 38
uniform float fSaturation <
ui_category = "Colors";
ui_label = "Saturation multiplier";
ui_type = "slider";
ui_min = 0.0;
ui_max = 5.0;
ui_step = 0.01;
> = 2.5;
#line 47
uniform float iShadingSteps <
ui_category = "Colors";
ui_label = "Shading steps";
ui_type = "slider";
ui_min = 1;
ui_max = 255;
ui_step = 1;
> = 16;
#line 58
texture normalTex { Width = 1920; Height = 1080; };
sampler normalSampler { Texture = normalTex; };
#line 61
texture blurTex { Width = 1920; Height = 1080; };
sampler blurSampler { Texture = blurTex; };
#line 68
float3 normal(float2 texcoord)
{
const float3 offset = float3(ReShade::PixelSize.xy, 0.0);
const float2 posCenter = texcoord.xy;
const float2 posNorth  = posCenter - offset.zy;
const float2 posEast   = posCenter + offset.xz;
#line 75
const float3 vertCenter = float3(posCenter - 0.5, 1) * ReShade::GetLinearizedDepth(posCenter)*1000.0;
#line 77
return normalize(cross(vertCenter - float3(posNorth - 0.5,  1) * ReShade::GetLinearizedDepth(posNorth)*1000.0, vertCenter - float3(posEast - 0.5,   1) * ReShade::GetLinearizedDepth(posEast)*1000.0));
}
#line 81
void saveNormal(in float3 normal, out float4 outNormal)
{
outNormal = float4(normal*0.5+0.5,1.0);
}
#line 86
float3 loadNormal(in float2 coords) {
return (tex2Dlod(normalSampler,float4(coords,0,0)).xyz-0.5)*2.0;
}
#line 92
float RGBCVtoHUE(in float3 RGB, in float C, in float V) {
float3 Delta = (V - RGB) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
Delta.brg = step(V, RGB) * Delta.brg;
return frac(max(Delta.r, max(Delta.g, Delta.b)) / 6);
}
#line 100
float3 RGBtoHSL(in float3 RGB) {
float3 HSL = 0;
const float U = -min(RGB.r, min(RGB.g, RGB.b));
const float V = max(RGB.r, max(RGB.g, RGB.b));
HSL.z = ((V - U) * 0.5);
const float C = V + U;
if (C != 0)
{
HSL.x = RGBCVtoHUE(RGB, C, V);
HSL.y = C / (1 - abs(2 * HSL.z - 1));
}
return HSL;
}
#line 114
float3 HUEtoRGB(in float H)
{
return saturate(float3(abs(H * 6 - 3) - 1, 2 - abs(H * 6 - 2), 2 - abs(H * 6 - 4)));
}
#line 119
float3 HSLtoRGB(in float3 HSL)
{
return (HUEtoRGB(HSL.x) - 0.5) * ((1 - abs(2 * HSL.z - 1)) * HSL.y) + HSL.z;
}
#line 127
void PS_Input(float4 vpos : SV_Position, in float2 coords : TEXCOORD, out float4 outNormal : SV_Target, out float4 outBlur : SV_Target1)
{
saveNormal(normal(coords),outNormal);
#line 131
if(iSurfaceBlur>0) {
float4 sum;
int count;
#line 135
int2 delta;
for(delta.x=-iSurfaceBlur;delta.x<=iSurfaceBlur;delta.x++) {
for(delta.y=-iSurfaceBlur;delta.y<=iSurfaceBlur;delta.y++) {
int d = dot(delta,delta);
if(d<=iSurfaceBlur*iSurfaceBlur) {
const float2 searchCoords = coords+ReShade::PixelSize*delta;
const float searchDepth = ReShade::GetLinearizedDepth(searchCoords)*1000.0;
const float dRatio = ReShade::GetLinearizedDepth(coords)*1000.0/searchDepth;
#line 144
if(dRatio>=0.95 && dRatio<=1.05) {
sum += tex2Dlod(ReShade::BackBuffer,float4(searchCoords,0.0,0.0));
count++;
}
}
}
}
outBlur = sum/count;
} else {
outBlur = tex2Dlod(ReShade::BackBuffer,float4(coords,0.0,0.0));
}
}
#line 157
void PS_Manga(float4 vpos : SV_Position, in float2 coords : TEXCOORD, out float4 outPixel : SV_Target)
{
#line 160
if(iBlackLineThickness>0) {
int2 delta;
for(delta.x=-iBlackLineThickness;delta.x<=iBlackLineThickness;delta.x++) {
for(delta.y=-iBlackLineThickness;delta.y<=iBlackLineThickness;delta.y++) {
if(dot(delta,delta)<=iBlackLineThickness*iBlackLineThickness) {
const float2 searchCoords = coords+ReShade::PixelSize*delta;
const float searchDepth = ReShade::GetLinearizedDepth(searchCoords)*1000.0;
const float3 searchNormal = loadNormal(searchCoords);
#line 169
if(ReShade::GetLinearizedDepth(coords)*1000.0/searchDepth<=fBlackLineThreshold && (abs(loadNormal(coords).x-searchNormal.x)>0.1 || abs(loadNormal(coords).y-searchNormal.y)>0.1 || abs(loadNormal(coords).z-searchNormal.z)>0.1)) {
outPixel = float4(0.0,0.0,0.0,1.0);
return;
}
}
}
}
}
#line 178
float3 color = tex2Dlod(blurSampler,float4(coords,0.0,0.0)).rgb;
float3 hsl = RGBtoHSL(color);
#line 182
float stepSize = 1.0/iShadingSteps;
hsl.z = round(hsl.z/stepSize)/iShadingSteps;
#line 186
hsl.y = clamp(hsl.y*fSaturation,0,1);
#line 188
color = HSLtoRGB(hsl);
#line 190
outPixel = float4(color,1.0);
}
#line 195
technique DH_Anime <
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Input;
RenderTarget = normalTex;
RenderTarget1 = blurTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Manga;
}
}
#line 212
}

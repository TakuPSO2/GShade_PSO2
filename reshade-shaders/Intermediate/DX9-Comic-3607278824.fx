#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Comic.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Comic.fx"
#line 101
uniform int iUIColorEdgesType <
ui_type = "combo";
ui_category = "Edges: Color";
ui_label = "Type";
ui_items = "Disabled\0Value Difference\0Single Pass Convolution\0Two Pass Convolution";
> = 1;
#line 108
uniform float fUIColorEdgesDetails <
ui_type = "slider";
ui_category = "Edges: Color";
ui_label = "Details";
ui_tooltip = "Only for Convolution";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 117
uniform float2 fUIColorEdgesStrength <
ui_type = "slider";
ui_category = "Edges: Color";
ui_label = "Power, Slope";
ui_min = 0.1; ui_max = 10.0;
ui_step = 0.01;
> = float2(1.0, 1.0);
#line 125
uniform float3 fUIColorEdgesDistanceFading<
ui_type = "slider";
ui_category = "Edges: Color";
ui_label = "Distance Strength";
ui_tooltip = "x: Fade In\ny: Fade Out\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.0, 1.0, 0.8);
#line 134
uniform bool bUIColorEdgesDebugLayer <
ui_label = "Add to Debug Layer";
ui_category = "Edges: Color";
> = true;
#line 140
uniform int iUIChromaEdgesType <
ui_type = "combo";
ui_category = "Edges: Chroma";
ui_label = "Type";
ui_items = "Disabled\0Value Difference\0Single Pass Convolution\0Two Pass Convolution";
> = 3;
#line 147
uniform float fUIChromaEdgesDetails <
ui_type = "slider";
ui_category = "Edges: Chroma";
ui_label = "Details";
ui_tooltip = "Only for Convolution";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 0.0;
#line 156
uniform float2 fUIChromaEdgesStrength <
ui_type = "slider";
ui_category = "Edges: Chroma";
ui_label = "Power, Slope";
ui_min = 0.01; ui_max = 10.0;
ui_step = 0.01;
> = float2(1.0, 0.5);
#line 164
uniform float3 fUIChromaEdgesDistanceFading<
ui_type = "slider";
ui_category = "Edges: Chroma";
ui_label = "Distance Strength";
ui_tooltip = "x: Fade In\ny: Fade Out\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.0, 0.5, 0.8);
#line 173
uniform bool bUIChromaEdgesDebugLayer <
ui_label = "Add to Debug Layer";
ui_category = "Edges: Chroma";
> = true;
#line 179
uniform int iUIOutlinesEnable <
ui_type = "combo";
ui_category = "Outlines 1";
ui_label = "Type";
ui_items = "Disabled\0Type 1\0Type 2\0";
> = 1;
#line 186
uniform float fUIOutlinesThreshold <
ui_type = "slider";
ui_category = "Outlines 1";
ui_label = "Threshold";
ui_min = 0.0; ui_max = 1000.0;
ui_step = 0.01;
> = 1.0;
#line 194
uniform float2 fUIOutlinesStrength <
ui_type = "slider";
ui_category = "Outlines 1";
ui_label = "Power, Slope";
ui_min = 0.01; ui_max = 10.0;
ui_step = 0.01;
> = float2(1.0, 1.0);
#line 202
uniform float3 fUIOutlinesDistanceFading<
ui_type = "slider";
ui_category = "Outlines 1";
ui_label = "Distance Strength";
ui_tooltip = "x: Fade In\ny: Fade Out\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.0, 1.0, 0.8);
#line 211
uniform bool bUIOutlinesDebugLayer <
ui_label = "Add to Debug Layer";
ui_category = "Outlines 1";
> = true;
#line 217
uniform int iUIMeshEdgesEnable <
ui_type = "combo";
ui_category = "Outlines 2 (Mesh Edges)";
ui_label = "Type";
ui_items = "Disabled\0Enabled\0";
> = 1;
#line 224
uniform float2 fUIMeshEdgesStrength <
ui_type = "slider";
ui_category = "Outlines 2 (Mesh Edges)";
ui_label = "Power, Slope";
ui_min = 0.01; ui_max = 10.0;
ui_step = 0.01;
> = float2(3.0, 3.0);
#line 234
uniform float iUIMeshEdgesIterations <
ui_type = "slider";
ui_category = "Outlines 2 (Mesh Edges)";
ui_label = "Line Width";
ui_min = 1.0; ui_max = 3;
ui_step = 0.01;
> = 1.0;
#line 242
uniform float3 fUIMeshEdgesDistanceFading<
ui_type = "slider";
ui_category = "Outlines 2 (Mesh Edges)";
ui_label = "Distance Strength";
ui_tooltip = "x: Fade In\ny: Fade Out\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(-1.0, 0.1, 0.8);
#line 251
uniform bool bUIMeshEdgesDebugLayer <
ui_label = "Add to Debug Layer";
ui_category = "Outlines 2 (Mesh Edges)";
> = true;
#line 257
uniform float3 fUIEdgesLumaWeight <
ui_type = "slider";
ui_category = "Luma/Saturation Weight";
ui_label = "Luma";
ui_tooltip = "x: Min\ny: Max\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.0, 1.0, 0.8);
#line 266
uniform float3 fUIEdgesSaturationWeight <
ui_type = "slider";
ui_category = "Luma/Saturation Weight";
ui_label = "Saturation";
ui_tooltip = "x: Min\ny: Max\nz: Slope";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.0, 1.0, 0.8);
#line 276
uniform bool bUIEnableDebugLayer <
ui_label = "Enable Debug Layer";
ui_category = "Debug";
> = false;
#line 281
uniform int iUIShowFadingOverlay <
ui_type = "combo";
ui_category = "Debug";
ui_label = "Weight Overlay";
ui_items = "None\0Luma Edges\0Chroma Edges\0Outlines\0Mesh Edges\0Luma\0Saturation\0";
> = 0;
#line 288
uniform float3 fUIOverlayColor<
ui_type = "color";
ui_category = "Debug";
ui_label = "Overlay Color";
> = float3(1.0, 0.0, 0.0);
#line 295
uniform float3 fUIColor <
ui_type = "color";
ui_category = "Effect";
ui_label = "Color";
> = float3(0.0, 0.0, 0.0);
#line 301
uniform float fUIStrength <
ui_type = "slider";
ui_category = "Effect";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 311
namespace Comic {
#line 315
float Convolution(float4 values1, float4 values2, int type, float detail) {
static const float4 Sobel_X1       = float4(  0.0, -1.0, -2.0, -1.0);
static const float4 Sobel_X2       = float4(  0.0,  1.0,  2.0,  1.0);
static const float4 Sobel_Y1       = float4(  2.0,  1.0,  0.0, -1.0);
static const float4 Sobel_Y2       = float4( -2.0, -1.0,  0.0,  1.0);
static const float4 Sobel_X_M1     = float4(  0.0,  1.0,  2.0,  1.0);
static const float4 Sobel_X_M2     = float4(  0.0, -1.0, -2.0, -1.0);
static const float4 Sobel_Y_M1     = float4( -2.0, -1.0,  0.0,  1.0);
static const float4 Sobel_Y_M2     = float4(  2.0,  1.0,  0.0, -1.0);
static const float4 Scharr_X1      = float4(  0.0, -3.0,-10.0, -3.0);
static const float4 Scharr_X2      = float4(  0.0,  3.0, 10.0,  3.0);
static const float4 Scharr_Y1      = float4( 10.0,  3.0,  0.0, -3.0);
static const float4 Scharr_Y2      = float4(-10.0, -3.0,  0.0,  3.0);
static const float4 Scharr_X_M1    = float4(  0.0,  3.0, 10.0,  3.0);
static const float4 Scharr_X_M2    = float4(  0.0, -3.0,-10.0, -3.0);
static const float4 Scharr_Y_M1    = float4(-10.0, -3.0,  0.0,  3.0);
static const float4 Scharr_Y_M2    = float4(-10.0,  3.0,  0.0, -3.0);
#line 333
float retVal;
#line 343
const float4 cX1 = values1 * lerp(Sobel_X1, Scharr_X1, detail);
const float4 cX2 = values2 * lerp(Sobel_X2, Scharr_X2, detail);
const float  cX  = cX1.x + cX1.y + cX1.z + cX1.w + cX2.x + cX2.y + cX2.z + cX2.w;
const float4 cY1 = values1 * lerp(Sobel_Y1, Scharr_Y1, detail);
const float4 cY2 = values2 * lerp(Sobel_Y2, Scharr_Y2, detail);
const float  cY  = cY1.x + cY1.y + cY1.z + cY1.w + cY2.x + cY2.y + cY2.z + cY2.w;
retVal = max(cX, cY);
if(type == 3)
{
#line 357
const float4 cX1 = values1 * lerp(Sobel_X_M1, Scharr_X_M1, detail);
const float4 cX2 = values2 * lerp(Sobel_X_M2, Scharr_X_M2, detail);
const float  cX  = cX1.x + cX1.y + cX1.z + cX1.w + cX2.x + cX2.y + cX2.z + cX2.w;
const float4 cY1 = values1 * lerp(Sobel_Y_M1, Scharr_Y_M1, detail);
const float4 cY2 = values2 * lerp(Sobel_Y_M2, Scharr_Y_M2, detail);
const float  cY  = cY1.x + cY1.y + cY1.z + cY1.w + cY2.x + cY2.y + cY2.z + cY2.w;
retVal = max(retVal, max(cX, cY));
}
return retVal;
}
#line 368
float MeshEdges(float depthC, float4 depth1, float4 depth2) {
#line 374
float depthCenter = depthC;
float4 depthCardinal = float4(depth1.x, depth2.x, depth1.z, depth2.z);
float4 depthInterCardinal = float4(depth1.y, depth2.y, depth1.w, depth2.w);
#line 378
const float2 mind = float2(min(depthCardinal.x, min(depthCardinal.y, min(depthCardinal.z, depthCardinal.w))), min(depthInterCardinal.x, min(depthInterCardinal.y, min(depthInterCardinal.z, depthInterCardinal.w))));
const float2 maxd = float2(max(depthCardinal.x, max(depthCardinal.y, max(depthCardinal.z, depthCardinal.w))), max(depthInterCardinal.x, max(depthInterCardinal.y, max(depthInterCardinal.z, depthInterCardinal.w))));
const float span = max(maxd.x, maxd.y) - min(mind.x, mind.y) + 0.00001;
#line 383
depthCenter /= span;
depthCardinal /= span;
depthInterCardinal /= span;
#line 387
const float4 diffsCardinal = abs(depthCardinal - depthCenter);
const float4 diffsInterCardinal = abs(depthInterCardinal - depthCenter);
#line 390
const float2 meshEdge = float2(
max(abs(diffsCardinal.x - diffsCardinal.y), abs(diffsCardinal.z - diffsCardinal.w)),
max(abs(diffsInterCardinal.x - diffsInterCardinal.y), abs(diffsInterCardinal.z - diffsInterCardinal.w))
);
#line 1
return max(float2(
max(abs(diffsCardinal.x-diffsCardinal.y),abs(diffsCardinal.z-diffsCardinal.w)),
max(abs(diffsInterCardinal.x-diffsInterCardinal.y),abs(diffsInterCardinal.z-diffsInterCardinal.w)))
.x, float2(
max(abs(diffsCardinal.x-diffsCardinal.y),abs(diffsCardinal.z-diffsCardinal.w)),
max(abs(diffsInterCardinal.x-diffsInterCardinal.y),abs(diffsInterCardinal.z-diffsInterCardinal.w)))
#line 398
.y);
}
#line 401
float4 EdgeDetection(sampler s, int2 vpos, float2 texcoord,
const int luma_type, float luma_detail,
const int chroma_type, float chroma_detail,
const int outlines_enable, int mesh_edges_enable) {
float4 retVal;
#line 413
const float3 colorC = tex2Dfetch(s, int4(vpos, 0, 0)).rgb;
const float3 color1[4] = {
tex2Dfetch(s, int4(vpos + int2( 0, -1), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2( 1, -1), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2( 1,  0), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2( 1,  1), 0, 0)).rgb,
};
const float3 color2[4] = {
tex2Dfetch(s, int4(vpos + int2( 0,  1), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2(-1,  1), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2(-1,  0), 0, 0)).rgb,
tex2Dfetch(s, int4(vpos + int2(-1, -1), 0, 0)).rgb 
};
#line 427
const float lumaC = dot(colorC, float3(0.2126, 0.7151, 0.0721));
const float4 luma1 = float4(
dot(color1[0], float3(0.2126, 0.7151, 0.0721)),
dot(color1[1], float3(0.2126, 0.7151, 0.0721)),
dot(color1[2], float3(0.2126, 0.7151, 0.0721)),
dot(color1[3], float3(0.2126, 0.7151, 0.0721))
);
const float4 luma2 = float4(
dot(color2[0], float3(0.2126, 0.7151, 0.0721)),
dot(color2[1], float3(0.2126, 0.7151, 0.0721)),
dot(color2[2], float3(0.2126, 0.7151, 0.0721)),
dot(color2[3], float3(0.2126, 0.7151, 0.0721))
);
#line 441
const float chromaVC = dot(colorC - lumaC.xxx, float3(0.2126, 0.7151, 0.0721));
const float4 chromaV1 = float4(
max((color1[0]-luma1.xxx).x, max((color1[0]-luma1.xxx).y, (color1[0]-luma1.xxx).z)),
max((color1[1]-luma1.yyy).x, max((color1[1]-luma1.yyy).y, (color1[1]-luma1.yyy).z)),
max((color1[2]-luma1.zzz).x, max((color1[2]-luma1.zzz).y, (color1[2]-luma1.zzz).z)),
max((color1[3]-luma1.www).x, max((color1[3]-luma1.www).y, (color1[3]-luma1.www).z))
);
const float4 chromaV2 = float4(
max((color2[0]-luma2.xxx).x, max((color2[0]-luma2.xxx).y, (color2[0]-luma2.xxx).z)),
max((color2[1]-luma2.yyy).x, max((color2[1]-luma2.yyy).y, (color2[1]-luma2.yyy).z)),
max((color2[2]-luma2.zzz).x, max((color2[2]-luma2.zzz).y, (color2[2]-luma2.zzz).z)),
max((color2[3]-luma2.www).x, max((color2[3]-luma2.www).y, (color2[3]-luma2.www).z))
);
#line 455
const float2 pix = ReShade::PixelSize;
const float depthC = ReShade::GetLinearizedDepth(texcoord);
float4 depth1[3];
float4 depth2[3];
#line 460
const int iterations = clamp(iUIMeshEdgesIterations, 1, 3);
[unroll]
for(int i = 0; i < iterations; i++)
{
depth1[i] = float4(
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2(   0.0, -pix.y)),
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2( pix.x, -pix.y)),
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2( pix.x,    0.0)),
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2( pix.x,  pix.y))
);
depth2[i]  = float4(
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2(   0.0,  pix.y)),
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2(-pix.x,  pix.y)),
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2(-pix.x,    0.0)), 
ReShade::GetLinearizedDepth(texcoord + (i + 1.0) * float2(-pix.x, -pix.y)) 
);
}
#line 478
if(luma_type == 1)
{
#line 486
const float4 diffsLuma = abs(luma1 - luma2);
retVal.x = (diffsLuma.x + diffsLuma.y + diffsLuma.z + diffsLuma.w) * (1.0 - lumaC);
}
else if(luma_type > 1)
{
retVal.x = Comic::Convolution(luma1, luma2, luma_type, luma_detail);
}
#line 495
if(chroma_type == 1)
{
const float4 diffsChromaLuma = abs(chromaV1 - chromaV2);
retVal.y = (diffsChromaLuma.x + diffsChromaLuma.y + diffsChromaLuma.z + diffsChromaLuma.w) * (1.0 - chromaVC);
}
else if(chroma_type > 1)
{
retVal.y = Comic::Convolution(chromaV1, chromaV2, chroma_type, chroma_detail);
}
#line 505
if(outlines_enable == 1)
{
#line 512
const float3 vertCenter = float3(texcoord, depthC);
const float3 vertNorth = float3(texcoord + float2(0.0, -pix.y), depth1[0].x);
const float3 vertEast = float3(texcoord + float2(pix.x, 0.0), depth1[0].z);
retVal.z = (1.0 - saturate(normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5)).z;
}
else if(outlines_enable == 2)
{
const float maxDiff = max(max((depth1[0]).x, max((depth1[0]).y, max((depth1[0]).z, (depth1[0]).w))), max((depth2[0]).x, max((depth2[0]).y, max((depth2[0]).z, (depth2[0]).w)))) - min(min((depth1[0]).x, min((depth1[0]).y, min((depth1[0]).z, (depth1[0]).w))), min((depth2[0]).x, min((depth2[0]).y, min((depth2[0]).z, (depth2[0]).w))));
if (maxDiff < fUIOutlinesThreshold / 1000.0)
retVal.z = 0.0;
else
retVal.z = 1.0;
}
#line 526
if(mesh_edges_enable)
{
[unroll]
for(int i = 0; i < iUIMeshEdgesIterations; i++)
{
retVal.w = max(retVal.w, MeshEdges(depthC, depth1[i], depth2[i]));
}
}
#line 535
return saturate(retVal);
}
#line 538
float StrengthCurve(float3 fade, float depth) {
return smoothstep(0.0, 1.0 - fade.z, depth + (0.2 - 1.2 * fade.x)) * smoothstep(0.0, 1.0 - fade.z, 1.0 - depth + (1.2 * fade.y - 1.0));
}
#line 545
float3 Sketch_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float currentDepth = ReShade::GetLinearizedDepth(texcoord);
float4 edges = EdgeDetection(ReShade::BackBuffer,
vpos.xy,
texcoord,
iUIColorEdgesType,
fUIColorEdgesDetails,
iUIChromaEdgesType,
fUIChromaEdgesDetails,
iUIOutlinesEnable,
iUIMeshEdgesEnable);
#line 558
edges = float4(
pow(edges.x, fUIColorEdgesStrength.x) * fUIColorEdgesStrength.y,
pow(edges.y, fUIChromaEdgesStrength.x) * fUIChromaEdgesStrength.y,
pow(edges.z, fUIOutlinesStrength.x) * fUIOutlinesStrength.y,
pow(edges.w, fUIMeshEdgesStrength.x) * fUIMeshEdgesStrength.y
);
#line 565
const float2 fadeAll =  float2(
StrengthCurve(fUIEdgesLumaWeight, dot(color, float3(0.2126, 0.7151, 0.0721))),
StrengthCurve(fUIEdgesSaturationWeight, max(color.x, max(color.y, color.z)) - min(color.x, min(color.y, color.z)))
);
#line 570
const float4 fadeDist = float4(
StrengthCurve(fUIColorEdgesDistanceFading, currentDepth),
StrengthCurve(fUIChromaEdgesDistanceFading, currentDepth),
StrengthCurve(fUIOutlinesDistanceFading, currentDepth),
StrengthCurve(fUIMeshEdgesDistanceFading, currentDepth)
);
#line 577
edges *= fadeDist * min(fadeAll.x, fadeAll.y);
#line 582
float3 edgeDebugLayer = 0.0.rrr;
if(bUIEnableDebugLayer) {
const int4 enabled = int4(bUIColorEdgesDebugLayer,bUIChromaEdgesDebugLayer,bUIOutlinesDebugLayer,bUIMeshEdgesDebugLayer);
edgeDebugLayer = max((edges*enabled).x, max((edges*enabled).y, max((edges*enabled).z, (edges*enabled).w)));
#line 587
if(iUIShowFadingOverlay != 0) {
if(iUIShowFadingOverlay == 1)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeDist.x);
else if(iUIShowFadingOverlay == 2)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeDist.y);
else if(iUIShowFadingOverlay == 3)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeDist.z);
else if(iUIShowFadingOverlay == 4)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeDist.w);
else if(iUIShowFadingOverlay == 5)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeAll.x);
else if(iUIShowFadingOverlay == 6)
edgeDebugLayer = lerp(fUIOverlayColor, edgeDebugLayer.rrr, fadeAll.y);
}
return edgeDebugLayer;
}
return saturate(lerp(color, fUIColor, max(edges.x, max(edges.y, max(edges.z, edges.w))) * fUIStrength));
}
}
#line 607
technique Comic
{
pass {
VertexShader = PostProcessVS;
PixelShader = Comic::Sketch_PS;
}
}

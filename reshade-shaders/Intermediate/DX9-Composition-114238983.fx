#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Composition.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Composition.fx"
#line 12
uniform float4 UIGridColor <
ui_type = "color";
ui_label = "Grid Color";
> = float4(0.0, 0.0, 0.0, 1.0);
#line 17
uniform float UIGridLineWidth <
ui_type = "slider";
ui_label = "Grid Line Width";
ui_min = 0.0; ui_max = 5.0;
ui_steps = 0.01;
> = 1.0;
#line 24
struct sctpoint {
float3 color;
float2 coord;
float2 offset;
};
#line 30
sctpoint NewPoint(float3 color, float2 offset, float2 coord) {
sctpoint p;
p.color = color;
p.offset = offset;
p.coord = coord;
return p;
}
#line 38
float3 DrawPoint(float3 texcolor, sctpoint p, float2 texcoord) {
float2 pixelsize = ReShade::PixelSize * p.offset;
#line 41
if(p.coord.x == -1 || p.coord.y == -1)
return texcolor;
#line 44
if(texcoord.x <= p.coord.x + pixelsize.x &&
texcoord.x >= p.coord.x - pixelsize.x &&
texcoord.y <= p.coord.y + pixelsize.y &&
texcoord.y >= p.coord.y - pixelsize.y)
return p.color;
return texcolor;
}
#line 53
float3 DrawCenterLines(float3 background, float3 gridColor, float lineWidth, float2 texcoord) {
float3 result;
#line 56
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(0.5, texcoord.y));
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 0.5));
#line 59
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineH1, texcoord);
#line 62
return result;
}
#line 65
float3 DrawThirds(float3 background, float3 gridColor, float lineWidth, float2 texcoord) {
float3 result;
#line 68
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 3.0, texcoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 3.0, texcoord.y));
#line 71
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 1.0 / 3.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 2.0 / 3.0));
#line 74
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
#line 79
return result;
}
#line 82
float3 DrawFifths(float3 background, float3 gridColor, float lineWidth, float2 texcoord) {
float3 result;
#line 85
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 5.0, texcoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 5.0, texcoord.y));
sctpoint lineV3 = NewPoint(gridColor, lineWidth, float2(3.0 / 5.0, texcoord.y));
sctpoint lineV4 = NewPoint(gridColor, lineWidth, float2(4.0 / 5.0, texcoord.y));
#line 90
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 1.0 / 5.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 2.0 / 5.0));
sctpoint lineH3 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 3.0 / 5.0));
sctpoint lineH4 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 4.0 / 5.0));
#line 95
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineV3, texcoord);
result = DrawPoint(result, lineV4, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
result = DrawPoint(result, lineH3, texcoord);
result = DrawPoint(result, lineH4, texcoord);
#line 104
return result;
}
#line 107
float3 DrawGoldenRatio(float3 background, float3 gridColor, float lineWidth, float2 texcoord) {
float3 result;
#line 110
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 1.6180339887, texcoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(1.0 - 1.0 / 1.6180339887, texcoord.y));
#line 113
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 1.0 / 1.6180339887));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texcoord.x, 1.0 - 1.0 / 1.6180339887));
#line 116
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
#line 121
return result;
}
#line 124
float3 DrawDiagonals(float3 background, float3 gridColor, float lineWidth, float2 texcoord) {
float3 result;
float slope = (float)1920 / (float)1080;
#line 128
sctpoint line1 = NewPoint(gridColor, lineWidth,    float2(texcoord.x, texcoord.x * slope));
sctpoint line2 = NewPoint(gridColor, lineWidth,  float2(texcoord.x, 1.0 - texcoord.x * slope));
sctpoint line3 = NewPoint(gridColor, lineWidth,   float2(texcoord.x, (1.0 - texcoord.x) * slope));
sctpoint line4 = NewPoint(gridColor, lineWidth,  float2(texcoord.x, texcoord.x * slope + 1.0 - slope));
#line 133
result = DrawPoint(background, line1, texcoord);
result = DrawPoint(result, line2, texcoord);
result = DrawPoint(result, line3, texcoord);
result = DrawPoint(result, line4, texcoord);
#line 138
return result;
}
#line 141
float3 CenterLines_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 result = DrawCenterLines(background, UIGridColor.rgb, UIGridLineWidth, texcoord);
return lerp(background, result, UIGridColor.w);
}
float3 Thirds_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 result = DrawThirds(background, UIGridColor.rgb, UIGridLineWidth, texcoord);
return lerp(background, result, UIGridColor.w);
}
float3 Fifths_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 result = DrawFifths(background, UIGridColor.rgb, UIGridLineWidth, texcoord);
return lerp(background, result, UIGridColor.w);
}
float3 GoldenRatio_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 result = DrawGoldenRatio(background, UIGridColor.rgb, UIGridLineWidth, texcoord);
return lerp(background, result, UIGridColor.w);
}
float3 Diagonals_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 result = DrawDiagonals(background, UIGridColor.rgb, UIGridLineWidth, texcoord);
return lerp(background, result, UIGridColor.w);
}
#line 168
technique CompositionCenterLines
{
pass {
VertexShader = PostProcessVS;
PixelShader = CenterLines_PS;
}
}
technique CompositionThirds
{
pass {
VertexShader = PostProcessVS;
PixelShader = Thirds_PS;
}
}
technique CompositionFifths
{
pass {
VertexShader = PostProcessVS;
PixelShader = Fifths_PS;
}
}
technique CompositionGoldenRatio
{
pass {
VertexShader = PostProcessVS;
PixelShader = GoldenRatio_PS;
}
}
technique CompositionDiagonals
{
pass {
VertexShader = PostProcessVS;
PixelShader = Diagonals_PS;
}
}

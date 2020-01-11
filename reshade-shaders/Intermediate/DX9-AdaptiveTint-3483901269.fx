#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveTint.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveTint.fx"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Stats.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ReShade.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Stats.fxh"
#line 12
namespace Stats {
texture2D shared_texStats { Width = 1920; Height = 1080; Format = RGBA8; MipLevels =  7.0; };
sampler2D shared_SamplerStats { Texture = shared_texStats; };
float3 OriginalBackBuffer(float2 texcoord) { return tex2D(shared_SamplerStats, texcoord).rgb; }
#line 17
texture2D shared_texStatsAvgColor { Format = RGBA8; };
sampler2D shared_SamplerStatsAvgColor { Texture = shared_texStatsAvgColor; };
float3 AverageColor() { return tex2Dfetch(shared_SamplerStatsAvgColor, int4(0, 0, 0, 0)).rgb; }
#line 21
texture2D shared_texStatsAvgLuma { Format = R16F; };
sampler2D shared_SamplerStatsAvgLuma { Texture = shared_texStatsAvgLuma; };
float AverageLuma() { return tex2Dfetch(shared_SamplerStatsAvgLuma, int4(0, 0, 0, 0)).r; }
#line 25
texture2D shared_texStatsAvgColorTemp { Format = R16F; };
sampler2D shared_SamplerStatsAvgColorTemp { Texture = shared_texStatsAvgColorTemp; };
float AverageColorTemp() { return tex2Dfetch(shared_SamplerStatsAvgColorTemp, int4(0, 0, 0, 0)).r; }
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveTint.fx"
#line 28
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Tools.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ReShade.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Tools.fxh"
#line 84
struct sctpoint {
float3 color;
float2 coord;
};
#line 90
float3 ConvReturn(float3 X, float3 Y, int MulDotXYAddMax) {
float3 ret = float3(1.0, 0.0, 1.0);
#line 93
if(MulDotXYAddMax == 0)
ret = X * Y;
else if(MulDotXYAddMax == 1)
ret = dot(X,Y);
else if(MulDotXYAddMax == 2)
ret = X;
else if(MulDotXYAddMax == 3)
ret = Y;
else if(MulDotXYAddMax == 4)
ret = X + Y;
else if(MulDotXYAddMax == 5)
ret = max(X, Y);
return ret;
}
#line 109
namespace Tools {
#line 111
namespace Types {
#line 113
sctpoint Point(float3 color, float2 coord) {
sctpoint p;
p.color = color;
p.coord = coord;
return p;
}
#line 120
}
#line 122
namespace Color {
#line 124
float3 RGBtoYIQ(float3 color) {
static const float3x3 YIQ = float3x3( 	0.299, 0.587, 0.144,
0.596, -0.274, -0.322,
0.211, -0.523, 0.312  );
return mul(YIQ, color);
}
#line 131
float3 YIQtoRGB(float3 yiq) {
static const float3x3 RGB = float3x3( 	1.0, 0.956, 0.621,
1.0, -0.272, -0.647,
1.0, -1.106, 1.703  );
return saturate(mul(RGB, yiq));
}
#line 138
float4 RGBtoCMYK(float3 color) {
float3 CMY;
float K;
K = 1.0 - max(color.r, max(color.g, color.b));
CMY = (1.0 - color - K) / (1.0 - K);
return float4(CMY, K);
}
#line 146
float3 CMYKtoRGB(float4 cmyk) {
return (1.0.xxx - cmyk.xyz) * (1.0 - cmyk.w);
}
#line 152
float3 RGBtoHSV(float3 c) {
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#line 155
float4 p;
if (c.g < c.b)
p = float4(c.bg, K.wz);
else
p = float4(c.gb, K.xy);
#line 161
float4 q;
if (c.r < p.x)
q = float4(p.xyw, c.r);
else
q = float4(c.r, p.yzx);
#line 167
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 172
float3 HSVtoRGB(float3 c) {
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}
#line 178
float GetSaturation(float3 color) {
float maxVal = max(color.r, max(color.g, color.b));
float minVal = min(color.r, min(color.g, color.b));
return maxVal - minVal;
}
#line 186
float3 LayerMerge(float3 mask, float3 image, int mode) {
float3 E = float3(1.0, 0.0, 1.0);
#line 189
if(mode == 0)
E = mask;
else if(mode == 1)
E = image * mask;
else if(mode == 2)
E = image / (mask + 0.00001);
else if(mode == 3 || mode == 8) {
E = 1.0 - (1.0 - image) * (1.0 - mask);
if(mode == 8)
E = image * ((1.0 - image) * mask + E);
}
else if(mode == 4)
if (max(image.r, max(image.g, image.b)) < 0.5)
E = lerp(2*image*mask, 1.0 - 2.0 * (1.0 - image) * (1.0 - mask), 0.0);
else
E = lerp(2*image*mask, 1.0 - 2.0 * (1.0 - image) * (1.0 - mask), 1.0);
else if(mode == 5)
E =  image / (1.00001 - mask);
else if(mode == 6)
E = 1.0 - (1.0 - image) / (mask + 0.00001);
else if(mode == 7)
if (max(image.r, max(image.g, image.b)) > 0.5)
E = lerp(
2*image*mask,
1.0 - 2.0 * (1.0 - image) * (1.0 - mask),
0.0
);
else
E = lerp(
2*image*mask,
1.0 - 2.0 * (1.0 - image) * (1.0 - mask),
1.0
);
else if(mode == 9)
E = image - mask + 0.5;
else if(mode == 10)
E = image + mask - 0.5;
else if(mode == 11)
E = abs(image - mask);
else if(mode == 12)
E = image + mask;
else if(mode == 13)
E = image - mask;
else if(mode == 14)
E = min(image, mask);
else if(mode == 15)
E = max(image, mask);
else if(mode == 16)
if (max(mask.r, max(mask.g, mask.b)) <= 0.5)
E = lerp(
max(1.0 - ((1.0 - image) / ((2.0 * mask) + 1e-9)), 0.0),
min(image / (2 * (1.0 - mask) + 1e-9), 1.0),
0.0
);
else
E = lerp(
max(1.0 - ((1.0 - image) / ((2.0 * mask) + 1e-9)), 0.0),
min(image / (2 * (1.0 - mask) + 1e-9), 1.0),
1.0
);
#line 250
return saturate(E);
}
#line 253
}
#line 255
namespace Convolution {
#line 257
float3 ThreeByThree(sampler s, int2 vpos, float kernel[9], float divisor) {
float3 acc;
#line 260
[unroll]
for(int m = 0; m < 3; m++) {
[unroll]
for(int n = 0; n < 3; n++) {
acc += kernel[n + (m*3)] * tex2Dfetch(s, int4( (vpos.x - 1 + n), (vpos.y - 1 + m), 0, 0)).rgb;
}
}
#line 268
return acc / divisor;
}
#line 271
float3 ConvReturn(float3 X, float3 Y, int MulDotXYAddMax) {
float3 ret = float3(1.0, 0.0, 1.0);
#line 274
if(MulDotXYAddMax == 0)
ret = X * Y;
else if(MulDotXYAddMax == 1)
ret = dot(X,Y);
else if(MulDotXYAddMax == 2)
ret = X;
else if(MulDotXYAddMax == 3)
ret = Y;
else if(MulDotXYAddMax == 4)
ret = X + Y;
else if(MulDotXYAddMax == 5)
ret = max(X, Y);
return saturate(ret);
}
#line 289
float3 Edges(sampler s, int2 vpos, int kernel, int type) {
static const float Prewitt_X[9] = { -1.0,  0.0, 1.0,
-1.0,  0.0, 1.0,
-1.0,  0.0, 1.0	 };
#line 294
static const float Prewitt_Y[9] = { 1.0,  1.0,  1.0,
0.0,  0.0,  0.0,
-1.0, -1.0, -1.0  };
#line 298
static const float Prewitt_X_M[9] = { 1.0,  0.0, -1.0,
1.0,  0.0, -1.0,
1.0,  0.0, -1.0	 };
#line 302
static const float Prewitt_Y_M[9] = { -1.0,  -1.0,  -1.0,
0.0,  0.0,  0.0,
1.0, 1.0, 1.0  };
#line 306
static const float Sobel_X[9] = { 	1.0,  0.0, -1.0,
2.0,  0.0, -2.0,
1.0,  0.0, -1.0	 };
#line 310
static const float Sobel_Y[9] = { 	1.0,  2.0,  1.0,
0.0,  0.0,  0.0,
-1.0, -2.0, -1.0	 };
#line 314
static const float Sobel_X_M[9] = { 	-1.0,  0.0, 1.0,
-2.0,  0.0, 2.0,
-1.0,  0.0, 1.0	 };
#line 318
static const float Sobel_Y_M[9] = {   -1.0, -2.0, -1.0,
0.0,  0.0,  0.0,
1.0,  2.0,  1.0	 };
#line 322
static const float Scharr_X[9] = { 	 3.0,  0.0,  -3.0,
10.0,  0.0, -10.0,
3.0,  0.0,  -3.0  };
#line 326
static const float Scharr_Y[9] = { 	3.0,  10.0,   3.0,
0.0,   0.0,   0.0,
-3.0, -10.0,  -3.0  };
#line 330
static const float Scharr_X_M[9] = { 	 -3.0,  0.0,  3.0,
-10.0,  0.0, 10.0,
-3.0,  0.0,  3.0  };
#line 334
static const float Scharr_Y_M[9] = { 	-3.0,  -10.0,   -3.0,
0.0,   0.0,   0.0,
3.0, 10.0,  3.0  };
#line 338
float3 retValX, retValXM;
float3 retValY, retValYM;
#line 341
if(kernel == 0) {
retValX = Convolution::ThreeByThree(s, vpos, Prewitt_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Prewitt_Y, 1.0);
}
if(kernel == 1) {
retValX = Convolution::ThreeByThree(s, vpos, Prewitt_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Prewitt_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Prewitt_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Prewitt_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
if(kernel == 2) {
retValX = Convolution::ThreeByThree(s, vpos, Sobel_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Sobel_Y, 1.0);
}
if(kernel == 3) {
retValX = Convolution::ThreeByThree(s, vpos, Sobel_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Sobel_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Sobel_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Sobel_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
if(kernel == 4) {
retValX = Convolution::ThreeByThree(s, vpos, Scharr_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Scharr_Y, 1.0);
}
if(kernel == 5) {
retValX = Convolution::ThreeByThree(s, vpos, Scharr_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Scharr_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Scharr_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Scharr_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
#line 378
return Convolution::ConvReturn(retValX, retValY, type);
}
#line 381
float3 SimpleBlur(sampler s, int2 vpos, int size) {
float3 acc;
#line 384
size = clamp(size, 3, 14);
[unroll]
for(int m = 0; m < size; m++) {
[unroll]
for(int n = 0; n < size; n++) {
acc += tex2Dfetch(s, int4( (vpos.x - size / 3 + n), (vpos.y - size / 3 + m), 0, 0)).rgb;
}
}
#line 393
return acc / (size * size);
}
}
#line 397
namespace Draw {
#line 399
float aastep(float threshold, float value)
{
float afwidth = length(float2(ddx(value), ddy(value)));
return smoothstep(threshold - afwidth, threshold + afwidth, value);
}
#line 405
float3 Point2(float3 texcolor, float3 pointcolor, float2 pointcoord, float2 texcoord, float power) {
return lerp(texcolor, pointcolor, saturate(exp(-power * length(texcoord - pointcoord))));
}
#line 409
float3 PointEXP(float3 texcolor, sctpoint p, float2 texcoord, float power) {
return lerp(texcolor, p.color, saturate(exp(-power * length(texcoord - p.coord))));
}
#line 413
float3 PointAASTEP(float3 texcolor, sctpoint p, float2 texcoord, float power) {
return lerp(p.color, texcolor, aastep(power, length(texcoord - p.coord)));
}
#line 417
float3 OverlaySampler(float3 image, sampler overlay, float scale, float2 texcoord, int2 offset, float opacity) {
float3 retVal;
float3 col = image;
float fac = 0.0;
#line 422
float2 coord_pix = float2(1920, 1080) * texcoord;
float2 overlay_size = (float2)tex2Dsize(overlay, 0) * scale;
float2 border_min = (float2)offset;
float2 border_max = border_min + overlay_size + 1;
#line 427
if( coord_pix.x <= border_max.x &&
coord_pix.y <= border_max.y &&
coord_pix.x >= border_min.x &&
coord_pix.y >= border_min.y   ) {
fac = opacity;
float2 coord_overlay = (coord_pix - border_min) / overlay_size;
col = tex2D(overlay, coord_overlay).rgb;
}
#line 436
return lerp(image, col, fac);
}
#line 439
}
#line 441
namespace Functions {
#line 443
float Map(float value, float2 span_old, float2 span_new) {
float span_old_diff;
if (abs(span_old.y - span_old.x) < 1e-6)
span_old_diff = 1e-6;
else
span_old_diff = span_old.y - span_old.x;
return lerp(span_new.x, span_new.y, (clamp(value, span_old.x, span_old.y)-span_old.x)/(span_old_diff));
}
#line 452
float Level(float value, float black, float white) {
value = clamp(value, black, white);
return Map(value, float2(black, white), float2(0.0, 1.0));
}
#line 457
float Posterize(float x, int numLevels, float continuity, float slope, int type) {
float stepheight = 1.0 / numLevels;
float stepnum = floor(x * numLevels);
float frc = frac(x * numLevels);
float step1 = floor(frc) * stepheight;
float step2;
#line 464
if(type == 1)
step2 = smoothstep(0.0, 1.0, frc) * stepheight;
else if(type == 2)
step2 = (1.0 / (1.0 + exp(-slope*(frc - 0.5)))) * stepheight;
else
step2 = frc * stepheight;
#line 471
return lerp(step1, step2, continuity) + stepheight * stepnum;
}
#line 474
float DiffEdges(sampler s, float2 texcoord)
{
float valC = dot(tex2D(s, texcoord).rgb, float3(0.2126, 0.7151, 0.0721));
float valN = dot(tex2D(s, texcoord + float2(0.0, -ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valNE = dot(tex2D(s, texcoord + float2(ReShade::PixelSize.x, -ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valE = dot(tex2D(s, texcoord + float2(ReShade::PixelSize.x, 0.0)).rgb, float3(0.2126, 0.7151, 0.0721));
float valSE = dot(tex2D(s, texcoord + float2(ReShade::PixelSize.x, ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valS = dot(tex2D(s, texcoord + float2(0.0, ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valSW = dot(tex2D(s, texcoord + float2(-ReShade::PixelSize.x, ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valW = dot(tex2D(s, texcoord + float2(-ReShade::PixelSize.x, 0.0)).rgb, float3(0.2126, 0.7151, 0.0721));
float valNW = dot(tex2D(s, texcoord + float2(-ReShade::PixelSize.x, -ReShade::PixelSize.y)).rgb, float3(0.2126, 0.7151, 0.0721));
#line 486
float diffNS = abs(valN - valS);
float diffWE = abs(valW - valE);
float diffNWSE = abs(valNW - valSE);
float diffSWNE = abs(valSW - valNE);
return saturate((diffNS + diffWE + diffNWSE + diffSWNE) * (1.0 - valC));
}
#line 493
float GetDepthBufferOutlines(float2 texcoord, int fading)
{
float depthC =  ReShade::GetLinearizedDepth(texcoord);
float depthN =  ReShade::GetLinearizedDepth(texcoord + float2(0.0, -ReShade::PixelSize.y));
float depthNE = ReShade::GetLinearizedDepth(texcoord + float2(ReShade::PixelSize.x, -ReShade::PixelSize.y));
float depthE =  ReShade::GetLinearizedDepth(texcoord + float2(ReShade::PixelSize.x, 0.0));
float depthSE = ReShade::GetLinearizedDepth(texcoord + float2(ReShade::PixelSize.x, ReShade::PixelSize.y));
float depthS =  ReShade::GetLinearizedDepth(texcoord + float2(0.0, ReShade::PixelSize.y));
float depthSW = ReShade::GetLinearizedDepth(texcoord + float2(-ReShade::PixelSize.x, ReShade::PixelSize.y));
float depthW =  ReShade::GetLinearizedDepth(texcoord + float2(-ReShade::PixelSize.x, 0.0));
float depthNW = ReShade::GetLinearizedDepth(texcoord + float2(-ReShade::PixelSize.x, -ReShade::PixelSize.y));
float diffNS = abs(depthN - depthS);
float diffWE = abs(depthW - depthE);
float diffNWSE = abs(depthNW - depthSE);
float diffSWNE = abs(depthSW - depthNE);
float outline = (diffNS + diffWE + diffNWSE + diffSWNE);
#line 510
if(fading == 1)
outline *= (1.0 - depthC);
else if(fading == 2)
outline *= depthC;
#line 515
return outline;
}
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveTint.fx"
#line 518
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Canvas.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ReShade.fxh"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Canvas.fxh"
#line 20
namespace Canvas {
float3 OverlaySampler(float3 image, sampler overlay, float2 texcoord, int2 offset, float opacity) {
float3 retVal;
float3 col = image;
float fac = 0.0;
#line 26
float2 screencoord = float2(1920, 1080) * texcoord;
float2 overlay_size = (float2)tex2Dsize(overlay, 0);
offset.x = clamp(offset.x, 0, 1920 - overlay_size.x);
offset.y = clamp(offset.y, 0, 1080 - overlay_size.y);
float2 border_min = (float2)offset;
float2 border_max = border_min + overlay_size;
#line 33
if( screencoord.x <= border_max.x &&
screencoord.y <= border_max.y &&
screencoord.x >= border_min.x &&
screencoord.y >= border_min.y   ) {
fac = opacity;
float2 coord_overlay = (screencoord - border_min) / overlay_size;
col = tex2D(overlay, coord_overlay).rgb;
}
#line 42
return lerp(image, col, fac);
}
#line 46
float aastep(float threshold, float value)
{
float afwidth = length(float2(ddx(value), ddy(value)));
return smoothstep(threshold - afwidth, threshold + afwidth, value);
}
float3 DrawCurve(float3 texcolor, float3 pointcolor, float2 pointcoord, float2 texcoord, float threshold) {
return lerp(pointcolor, texcolor, aastep(threshold, length(texcoord - pointcoord)));
}
float3 DrawBox(float3 texcolor, float3 color, int2 pos, int2 size, float2 texcoord, sampler s) {
int2 texSize = tex2Dsize(s, 0);
int2 pixelcoord = texcoord * texSize;
#line 58
size.y = clamp(size.y, 0, texSize.y);
size.x = clamp(size.x, 0, texSize.x);
pos.x = clamp(pos.x, 0, texSize.x - size.x);
pos.y = clamp(pos.y, 0, texSize.y - size.y);
#line 63
if( pixelcoord.x >= pos.x &&
pixelcoord.x <= pos.x + size.x &&
pixelcoord.y <= pos.y + size.y &&
pixelcoord.y >= pos.y ) {
texcolor = color;
}
return texcolor;
}
float3 DrawScale(float3 texcolor, float3 color_begin, float3 color_end, int2 pos, int2 size, float value, float3 color_marker, float2 texcoord, sampler s, float threshold) {
int2 texSize = tex2Dsize(s, 0);
#line 75
size.x = clamp(size.x, 0, texSize.x);
size.y = clamp(size.y, 0, texSize.y);
pos.x = clamp(pos.x, 0, texSize.x - size.x);
pos.y = clamp(pos.y, 0, texSize.y - size.y);
#line 80
float2 scalePosFloat = (float2)pos / (float2)size;
int2 pixelcoord = texcoord * texSize;
float2 sizeFactor = (float2)size / (float2)texSize;
#line 84
if( pixelcoord.x >= pos.x &&
pixelcoord.x <= pos.x + size.x &&
pixelcoord.y <= pos.y + size.y &&
pixelcoord.y >= pos.y ) {
if(size.y >= size.x) {
#line 90
texcolor = lerp(color_begin, color_end, texcoord.y / sizeFactor.y - scalePosFloat.y);
texcolor = DrawCurve(texcolor, color_marker, float2(texcoord.x, (value + scalePosFloat.y) * sizeFactor.y), texcoord, threshold);
}
else {
#line 95
texcolor = lerp(color_begin, color_end, texcoord.x / sizeFactor.x - scalePosFloat.x);
texcolor = DrawCurve(texcolor, color_marker, float2((value + scalePosFloat.x) * sizeFactor.x, texcoord.y), texcoord, threshold);
}
}
return texcolor;
}
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveTint.fx"
#line 22
uniform int iUIInfo<
ui_type = "combo";
ui_label = "Info";
ui_items = "Info\0";
ui_tooltip = "Enable Technique 'CalculateStats_MoveToTop'";
> = 0;
#line 29
uniform int iUIWhiteLevelFormula <
ui_type = "combo";
ui_category = "Curves";
ui_label = "White Level Curve (red)";
ui_tooltip = "Enable Technique 'AdaptiveTintDebug'\n#define UI_ADAPTIVE_TINT_DEBUG_WINDOW_WIDTH=xyz\nDefault width is 300";
ui_items = "Linear: x * (value - y) + z\0Square: x * (value - y)^2 + z\0Cube: x * (value - y)^3 + z\0";
> = 1;
#line 37
uniform float3 f3UICurveWhiteParam <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Curve Parameters";
ui_tooltip = "Enable Technique 'AdaptiveTintDebug'\n#define UI_ADAPTIVE_TINT_DEBUG_WINDOW_WIDTH=xyz\nDefault width is 300";
ui_min = -10.0; ui_max = 10.0;
ui_step = 0.01;
> = float3(-0.5, 1.0, 1.0);
#line 46
uniform int iUIBlackLevelFormula <
ui_type = "combo";
ui_category = "Curves";
ui_label = "Black Level Curve (cyan)";
ui_tooltip = "Enable Technique 'AdaptiveTintDebug'\n#define UI_ADAPTIVE_TINT_DEBUG_WINDOW_WIDTH=xyz\nDefault width is 300";
ui_items = "Linear: x * (value - y) + z\0Square: x * (value - y)^2 + z\0Cube: x * (value - y)^3 + z\0";
> = 1;
#line 54
uniform float3 f3UICurveBlackParam <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Curve Parameters";
ui_tooltip = "Enable Technique 'AdaptiveTintDebug'\n#define UI_ADAPTIVE_TINT_DEBUG_WINDOW_WIDTH=xyz\nDefault width is 300";
ui_min = -10.0; ui_max = 10.0;
ui_step = 0.01;
> = float3(0.5, 0.0, 0.0);
#line 63
uniform float fUIColorTempScaling <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Color Temperature Scaling";
ui_tooltip = "Enable Technique 'AdaptiveTintDebug'\n#define UI_ADAPTIVE_TINT_DEBUG_WINDOW_WIDTH=xyz\nDefault width is 300";
ui_min = 1.0; ui_max = 10.0;
ui_step = 0.01;
> = 2.0;
#line 72
uniform float fUISaturation <
ui_type = "slider";
ui_label = "Saturation";
ui_category = "Color";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 80
uniform float3 fUITintWarm <
ui_type = "color";
ui_category = "Color";
ui_label = "Warm Tint";
> = float3(0.04, 0.04, 0.02);
#line 86
uniform float3 fUITintCold <
ui_type = "color";
ui_category = "Color";
ui_label = "Cold Tint";
> = float3(0.02, 0.04, 0.04);
#line 92
uniform int iUIDebug <
ui_type = "combo";
ui_category = "Debug";
ui_label = "Show Tint Layer";
ui_items = "Off\0Tint\0Factor\0";
> = 0;
#line 99
uniform float fUIStrength <
ui_type = "slider";
ui_category = "General";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 110
uniform int2 AdaptiveTintDebugPosition < ui_type = "slider"; ui_category = "AdaptiveTintDebug"; ui_label = "Position"; ui_min = 0; ui_max = 1920; ui_step = 1; > = int2(0, 0); uniform float AdaptiveTintDebugOpacity < ui_type = "slider"; ui_category = "AdaptiveTintDebug"; ui_label = "Opacity"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01; > = 1.0; texture2D texAdaptiveTintDebug { Width = 1920/4; Height = 1080/4; Format = RGBA8; }; sampler2D sAdaptiveTintDebug { Texture = texAdaptiveTintDebug; }; float3 AdaptiveTintDebugoverlay(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target { float3 backbuffer = tex2D(ReShade::BackBuffer, texcoord).rgb; return Canvas::OverlaySampler(backbuffer, sAdaptiveTintDebug, texcoord, AdaptiveTintDebugPosition, AdaptiveTintDebugOpacity); }
#line 115
texture2D texAlphaCheckerboard < source = "alpha-checkerboard.png"; > { Width = 1920; Height = 1080; Format = RGBA8; };
sampler2D SamplerAlphaCheckerboard { Texture = texAlphaCheckerboard; };
#line 121
float2 CalculateLevels(float avgLuma) {
float2 level = float2(0.0, 0.0);
#line 124
if(iUIBlackLevelFormula == 2)
level.x = f3UICurveBlackParam.x * pow(avgLuma - f3UICurveBlackParam.y, 3) + f3UICurveBlackParam.z;
else if(iUIBlackLevelFormula == 1)
level.x = f3UICurveBlackParam.x * ((avgLuma - f3UICurveBlackParam.y) * 2) + f3UICurveBlackParam.z;
else
level.x = f3UICurveBlackParam.x * (avgLuma - f3UICurveBlackParam.y) + f3UICurveBlackParam.z;
#line 131
if(iUIWhiteLevelFormula == 2)
level.y = f3UICurveWhiteParam.x * pow(avgLuma - f3UICurveWhiteParam.y, 3) + f3UICurveWhiteParam.z;
else if(iUIWhiteLevelFormula == 1)
level.y = f3UICurveWhiteParam.x * ((avgLuma - f3UICurveWhiteParam.y) * 2) + f3UICurveWhiteParam.z;
else
level.y = f3UICurveWhiteParam.x * (avgLuma - f3UICurveWhiteParam.y) + f3UICurveWhiteParam.z;
#line 138
return saturate(level);
}
#line 141
float GetColorTemp(float2 texcoord) {
const float colorTemp = Stats::AverageColorTemp();
return Tools::Functions::Map(colorTemp * fUIColorTempScaling, float2(-0.5957, 0.5957), float2(0.0, 1.0));
}
#line 149
float3 AdaptiveTint_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 154
const float3 backbuffer = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 lutWarm = fUITintWarm * backbuffer;
const float3 lutCold = fUITintCold * backbuffer;
#line 161
const float colorTemp = GetColorTemp(texcoord);
const float3 tint = lerp(lutCold, lutWarm, colorTemp);
#line 167
const float3 luma   = dot(backbuffer, float3(0.2126, 0.7151, 0.0721)).rrr;
const float2 levels = CalculateLevels(Stats::AverageLuma());
const float3 factor = Tools::Functions::Level(luma.r, levels.x, levels.y).rrr;
const float3 result = lerp(tint, lerp(luma, backbuffer, fUISaturation + 1.0), factor);
#line 175
if(iUIDebug == 1) 
return lerp(tint, tex2D(SamplerAlphaCheckerboard, texcoord).rgb, factor);
if(iUIDebug == 2) 
return lerp(float3(0.0, 0.0, 0.0), float3(1.0, 1.0, 1.0), factor);
#line 180
return lerp(backbuffer, result, fUIStrength);
}
#line 187
float3 AdaptiveTintDebugdraw(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target { float3 AdaptiveTintDebug = 0.0.rrr;;;
const float3 originalBackBuffer = Stats::OriginalBackBuffer(texcoord);
const float3 originalLuma = dot(originalBackBuffer, float3(0.2126, 0.7151, 0.0721)).xxx;
const float avgLuma = Stats::AverageLuma();
const float3 avgColor = Stats::AverageColor();
const float2 curves = CalculateLevels(texcoord.x);
const float2 levels = CalculateLevels(avgLuma);
const float3 localFactor = saturate(Tools::Functions::Level(originalLuma.r, levels.x, levels.y).rrr);
#line 196
AdaptiveTintDebug = localFactor;;
AdaptiveTintDebug = Canvas::DrawScale(AdaptiveTintDebug, float3(1.0,0.0,0.0), float3(0.0,0.0,1.0), int2(0,10), int2(10,1080/4-10), GetColorTemp(texcoord), float3(0.0,0.0,0.0), float2(texcoord.x,  1.0 - texcoord.y), sAdaptiveTintDebug, 0.002);;
AdaptiveTintDebug = Canvas::DrawScale(AdaptiveTintDebug, float3(0.0,0.0,0.0), float3(1.0,1.0,1.0), int2(10,0), int2(1920/4-10,10), avgLuma, float3(1.0,0.0,1.0), float2(texcoord.x,  1.0 - texcoord.y), sAdaptiveTintDebug, 0.002);;
AdaptiveTintDebug = Canvas::DrawBox(AdaptiveTintDebug, avgColor, int2(0,0), int2(10,10), float2(texcoord.x, 1.0 - texcoord.y), sAdaptiveTintDebug);;
AdaptiveTintDebug = Canvas::DrawCurve(AdaptiveTintDebug, float3(1.0,0.0,0.0), float2(texcoord.x, curves.y), float2(texcoord.x,  1.0 - texcoord.y), 0.002);;
AdaptiveTintDebug = Canvas::DrawCurve(AdaptiveTintDebug, float3(0.0,1.0,1.0), float2(texcoord.x, curves.x), float2(texcoord.x,  1.0 - texcoord.y), 0.002);;
return AdaptiveTintDebug; };
#line 204
technique AdaptiveTint
{
pass {
VertexShader = PostProcessVS;
PixelShader = AdaptiveTint_PS;
}
}
#line 212
technique AdaptiveTintDebug { pass { VertexShader = PostProcessVS; PixelShader = AdaptiveTintDebugdraw; RenderTarget0 = texAdaptiveTintDebug; } pass { VertexShader = PostProcessVS; PixelShader = AdaptiveTintDebugoverlay; } }

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\NeoBloom.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\NeoBloom.fx"
#line 60
static const float cPI = 3.14159;
#line 63
static const int cBloomCount = 5;
static const float4 cBlooms[] = {
float4(0.0, 0.5, 0.5, 1),
float4(0.5, 0.0, 0.25, 2),
float4(0.75, 0.875, 0.125, 3),
float4(0.875, 0.0, 0.0625, 5),
float4(0.0, 0.0, 0.03, 7)
#line 71
};
static const int cMaxBloomLod = cBloomCount - 1;
#line 74
static const int cBlurSamples = 13;
#line 79
static const int cBlurHalfSamples = cBlurSamples / 2;
#line 87
static const float2 cPixelScale = 1.0;
#line 95
uniform float uIntensity <
ui_label = "Intensity";
ui_tooltip =
"Determines how much bloom is added to the image. For HDR games you'd "
"generally want to keep this low-ish, otherwise everything might look "
"too bright.\n"
"\nDefault: 1.0";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.0;
#line 109
uniform float uSaturation <
ui_label = "Saturation";
ui_tooltip =
"Saturation of the bloom texture.\n"
"\nDefault: 1.0";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
> = 1.0;
#line 122
uniform float uLensDirtAmount <
ui_label = "Amount";
ui_tooltip =
"Determines how much lens dirt is added to the bloom texture.\n"
"\nDefault: 0.0";
ui_category = "Lens Dirt";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
> = 0.0;
#line 139
uniform float uAdaptAmount <
ui_label = "Amount";
ui_tooltip =
"How much adaptation affects the image brightness.\n"
"Setting this to 0 disables adaptation, though a more performant "
"option would be to set the macro 'NEO_BLOOM_ADAPT' to 0 in the global "
"preprocessor definitions.\n"
"\bDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 153
uniform float uAdaptSensitivity <
ui_label = "Sensitivity";
ui_tooltip =
"How sensitive is the adaptation towards bright spots?\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 164
uniform float uAdaptExposure <
ui_label = "Exposure";
ui_tooltip =
"Determines the general brightness that the effect should adapt "
"towards.\n"
"This is measured in f-numbers, thus 0 is the base exposure, <0 will "
"be darker and >0 brighter.\n"
"\nDefault: 0.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = -3.0;
ui_max = 3.0;
> = 0.0;
#line 178
uniform bool uAdaptUseLimits <
ui_label = "Use Limits";
ui_tooltip =
"Should the adaptation be limited to the minimum and maximum values "
"specified below?\n"
"\nDefault: On";
ui_category = "Adaptation";
> = true;
#line 187
uniform float2 uAdaptLimits <
ui_label = "Limits";
ui_tooltip =
"The minimum and maximum values that adaptation can achieve.\n"
"Increasing the minimum value will lessen how bright the image can "
"become in dark scenes.\n"
"Decreasing the maximum value will lessen how dark the image can "
"become in bright scenes.\n"
"\nDefault: 0.0 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = float2(0.0, 1.0);
#line 203
uniform float uAdaptTime <
ui_label = "Time";
ui_tooltip =
"The time it takes for the effect to adapt.\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.02;
ui_max = 3.0;
> = 1.0;
#line 214
uniform float uAdaptPrecision <
ui_label = "Precision";
ui_tooltip =
"How precise adaptation will be towards the center of the image.\n"
"This means that 0.0 will yield an adaptation of the overall image "
"brightness, while higher values will focus more and more towards the "
"center pixels.\n"
"\nDefault: 0.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 11;
ui_step = 1.0;
> = 0.0;
#line 229
uniform int uAdaptFormula <
ui_label = "Formula";
ui_tooltip =
"Which formula to use when extracting brightness information from "
"color.\n"
"\nDefault: Luma (Linear)";
ui_category = "Adaptation";
ui_type = "combo";
ui_items = "Average\0Luminance\0Luma (Gamma)\0Luma (Linear)";
> = 3;
#line 244
uniform float uMean <
ui_label = "Mean";
ui_tooltip =
"Acts as a bias between all the bloom textures/sizes. What this means "
"is that lower values will yield more detail bloom, while the opposite "
"will yield big highlights.\n"
"The more variance is specified, the less effective this setting is, "
"so if you want to have very fine detail bloom reduce both "
"parameters.\n"
"\nDefault: 0.0";
ui_category = "Blending";
ui_type = "slider";
ui_min = 0.0;
ui_max = cBloomCount;
#line 259
> = 0.0;
#line 261
uniform float uVariance <
ui_label = "Variance";
ui_tooltip =
"Determines the 'variety'/'contrast' in bloom textures/sizes. This "
"means a low variance will yield more of the bloom size specified by "
"the mean; that is to say that having a low variance and mean will "
"yield more fine-detail bloom.\n"
"A high variance will diminish the effect of the mean, since it'll "
"cause all the bloom textures to blend more equally.\n"
"A low variance and high mean would yield an effect similar to "
"an 'ambient light', with big blooms of light, but few details.\n"
"\nDefault: 1.0";
ui_category = "Blending";
ui_type = "slider";
ui_min = 1.0;
ui_max = cBloomCount;
#line 278
> = cBloomCount;
#line 284
uniform float uGhostingAmount <
ui_label = "Amount";
ui_tooltip =
"Amount of ghosting applied.\n"
"Set NEO_BLOOM_GHOSTING to 0 if you don't use it for reducing resource "
"usage.\n"
"\nDefault: 0.0";
ui_category = "Ghosting";
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.999;
> = 0.0;
#line 301
uniform float uMaxBrightness <
ui_label  = "Max Brightness";
ui_tooltip =
"Determines the maximum brightness a pixel can achieve from being "
"'reverse-tonemapped', that is to say, when the effect attempts to "
"extract HDR information from the image.\n"
"In practice, the difference between a value of 100 and one of 1000 "
"would be in how bright/bloomy/big a white pixel could become, like "
"the sun or the headlights of a car.\n"
"Lower values can also work for making a more 'balanced' bloom, where "
"there are less harsh highlights and the entire scene is equally "
"foggy, like an old TV show or with dirty lenses.\n"
"\nDefault: 100.0";
ui_category = "HDR";
ui_type = "slider";
ui_min = 1.0;
ui_max = 1000.0;
ui_step = 1.0;
> = 100.0;
#line 321
uniform bool uNormalizeBrightness <
ui_label = "Normalize Brightness";
ui_tooltip =
"Whether to normalize the bloom brightness when blending with the "
"image.\n"
"Without it, the bloom may have very harsh bright spots.\n"
"\nDefault: On";
> = true;
#line 332
uniform float uSigma <
ui_label = "Sigma";
ui_tooltip =
"Amount of blurriness. Values too high will break the blur.\n"
"Recommended values are between 2 and 4.\n"
"\nDefault: 2.0";
ui_category = "Blur";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.01;
> = 2.0;
#line 345
uniform float uPadding <
ui_label = "Padding";
ui_tooltip =
"Specifies an additional padding that is added around each bloom "
"texture internally during the blurring process.\n"
"This serves to reduce the 'vignette-like' effect that can occur "
"around the screen edges in the bloom textures, where brightness is "
"lost near the edges. With padding however this is counteracted as it "
"can simulate there being more color information beyond the edges.\n"
"Be aware that this works by effectively reducing the bloom texture's "
"sizes, so it can lead to loss of detail or pixelation when values "
"specified are too high.\n"
"\nDefault: 0.1";
ui_category = "Blur";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.001;
> = 0.1;
#line 369
uniform int uDebugOptions <
ui_label = "Debug Options";
ui_tooltip =
"Debug options containing:\n"
"  - Showing only the bloom texture. The 'bloom texture to show' "
"parameter can be used to determine which bloom texture(s) to "
"visualize.\n"
"  - Showing the raw internal texture used to blur all the bloom "
"'textures', visualizing all the blooms at once in scale.\n"
"\nIf you don't need debug options, you may set the macro "
"'NEO_BLOOM_DEBUG' to 0 in the global preprocessor definitions to "
"disable them for a potential performance gain.\n"
"\nDefault: None";
ui_category = "Debug";
ui_type = "combo";
ui_items =
"None\0Show Only Bloom\0Show Split Textures\0"
#line 387
"Show Adaptation\0"
#line 389
;
> = false;
#line 392
uniform int uBloomTextureToShow <
ui_label = "Bloom Texture To Show";
ui_tooltip =
"Which bloom texture to show with the 'Show Only Bloom' debug option.\n"
"Set to -1 to view all textures blended.\n"
"\nDefault: -1";
ui_category = "Debug";
ui_type = "slider";
ui_min = -1;
ui_max = cMaxBloomLod;
> = -1;
#line 408
uniform float uFrameTime <source = "frametime";>;
#line 416
sampler sBackBuffer {
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
};
#line 421
texture tNeoBloom_DownSample {
Width = 1024;
Height = 1024;
Format = RGBA16F;
MipLevels = 11;
};
sampler sDownSample {
Texture = tNeoBloom_DownSample;
};
#line 431
texture tNeoBloom_TempA {
Width = 1920 / 2;
Height = 1080 / 2;
Format = RGBA16F;
};
sampler sTempA {
Texture = tNeoBloom_TempA;
};
#line 440
texture tNeoBloom_TempB {
Width = 1920 / 2;
Height = 1080 / 2;
Format = RGBA16F;
};
sampler sTempB {
Texture = tNeoBloom_TempB;
};
#line 451
texture tNeoBloom_Adapt {
Format = R16F;
};
sampler sAdapt {
Texture = tNeoBloom_Adapt;
MinFilter = POINT;
MagFilter = POINT;
};
#line 460
texture tNeoBloom_LastAdapt {
Format = R16F;
};
sampler sLastAdapt {
Texture = tNeoBloom_LastAdapt;
MinFilter = POINT;
MagFilter = POINT;
};
#line 473
texture tNeoBloom_LensDirt <
source = "SharedBloom_Dirt.png";
> {
Width = 1920;
Height = 1080;
};
sampler sLensDirt {
Texture = tNeoBloom_LensDirt;
};
#line 487
texture tNeoBloom_Ghosting {
Width = 1920 / (2 / 4.0);
Height = 1080 / (2 / 4.0);
Format = RGBA16F;
};
sampler sGhosting {
Texture = tNeoBloom_Ghosting;
};
#line 502
float2 scale_uv(float2 uv, float2 scale, float2 center) {
return (uv - center) * scale + center;
}
float2 scale_uv(float2 uv, float2 scale) {
return scale_uv(uv, scale, 0.5);
}
#line 509
float gaussian(float x, float o) {
o *= o;
return (1.0 / sqrt(2.0 * cPI * o)) * exp(-((x * x) / (2.0 * o)));
}
#line 514
float4 blur(sampler sp, float2 uv, float2 dir) {
float4 color = 0.0;
float accum = 0.0;
#line 518
uv -= cBlurHalfSamples * dir * ReShade::PixelSize;
#line 520
[unroll]
for (int i = 1; i < cBlurSamples; ++i) {
const float weight = gaussian(i - cBlurHalfSamples, uSigma);
#line 524
uv += dir * ReShade::PixelSize;
color += tex2D(sp, uv) * weight;
accum += weight;
}
#line 529
return color / accum;
}
#line 532
float3 inv_reinhard(float3 color, float inv_max) {
return (color / max(1.0 - color, inv_max));
}
#line 536
float3 inv_reinhard_lum(float3 color, float inv_max) {
const float lum = max(color.r, max(color.g, color.b));
return color * (lum / max(1.0 - lum, inv_max));
}
#line 541
float3 reinhard(float3 color) {
return color / (1.0 + color);
}
#line 545
float3 checkered_pattern(float2 uv) {
static const float cSize = 32.0;
static const float3 cColorA = pow(0.15, 2.2);
static const float3 cColorB = pow(0.5, 2.2);
#line 550
uv *= ReShade::ScreenSize;
uv %= cSize;
#line 553
const float half_size = cSize * 0.5;
const float checkered = step(uv.x, half_size) == step(uv.y, half_size);
return (cColorA * checkered) + (cColorB * (1.0 - checkered));
}
#line 558
float normal_distribution(float x, float u, float o) {
o *= o;
#line 561
float b = x - u;
b *= b;
b /= 2.0 * o;
#line 565
return (1.0 / sqrt(2.0 * cPI * o)) * exp(-(b));
}
#line 568
float get_luma_gamma(float3 color) {
return dot(color, float3(0.299, 0.587, 0.114));
}
#line 572
float get_luma_linear(float3 color) {
return dot(color, float3(0.2126, 0.7152, 0.0722));
}
#line 580
float4 PS_DownSample(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
float4 color = tex2D(sBackBuffer, uv);
color.rgb = inv_reinhard_lum(color.rgb, 1.0 / uMaxBrightness);
color.rgb = lerp(get_luma_linear(color.rgb), color.rgb, uSaturation);
return color;
}
#line 587
float4 PS_Split(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
float4 color = 0.0;
#line 590
[unroll]
for (int i = 0; i < cBloomCount; ++i) {
const float4 rect = cBlooms[i];
float2 rect_uv = scale_uv(uv - rect.xy, 1.0 / rect.z, 0.0);
const float inbounds =
step(0.0, rect_uv.x) * step(rect_uv.x, 1.0) *
step(0.0, rect_uv.y) * step(rect_uv.y, 1.0);
#line 598
rect_uv = scale_uv(rect_uv, 1.0 + uPadding * (i + 1), 0.5);
#line 600
float4 pixel = tex2Dlod(sDownSample, float4(rect_uv, 0, rect.w));
pixel.rgb *= inbounds;
pixel.a = inbounds;
#line 604
color += pixel;
}
#line 607
return color;
}
#line 610
float4 PS_BlurX(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
return blur(sTempA, uv, cPixelScale * float2(1.0, 0.0) * 2);
}
#line 614
float4 PS_BlurY(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
return blur(sTempB, uv, cPixelScale * float2(0.0, 1.0) * 2);
}
#line 620
float4 PS_CalcAdapt(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
float3 color = tex2Dlod(
sDownSample,
float4(0.5, 0.5, 0.0, 11 - uAdaptPrecision)
).rgb;
#line 626
color = reinhard(color);
#line 628
float gs;
switch (uAdaptFormula) {
case 0:
gs = dot(color, 0.333);
break;
case 1:
gs = max(color.r, max(color.g, color.b));
break;
case 2:
gs = get_luma_gamma(color);
break;
case 3:
gs = get_luma_linear(color);
break;
}
#line 644
gs *= uAdaptSensitivity;
#line 646
if (uAdaptUseLimits)
gs = clamp(gs, uAdaptLimits.x, uAdaptLimits.y);
#line 649
gs = lerp(tex2D(sLastAdapt, 0.0).r, gs, (uFrameTime * 0.001) / uAdaptTime);
#line 651
return float4(gs, 0.0, 0.0, 1.0);
}
#line 654
float4 PS_SaveAdapt(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
return tex2D(sAdapt, 0.0);
}
#line 660
float4 PS_JoinBlooms(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
float4 bloom = 0.0;
float accum = 0.0;
#line 664
[unroll]
for (int i = 0; i < cBloomCount; ++i) {
const float4 rect = cBlooms[i];
float2 rect_uv = scale_uv(uv, 1.0 / (1.0 + uPadding * (i + 1)), 0.5);
rect_uv = scale_uv(rect_uv + rect.xy / rect.z, rect.z, 0.0);
#line 670
const float weight = normal_distribution(i, uMean, uVariance);
bloom += tex2D(sTempA, rect_uv) * weight;
accum += weight;
}
bloom /= accum;
#line 677
bloom = lerp(bloom, tex2D(sGhosting, uv), uGhostingAmount);
#line 680
return bloom;
}
#line 685
float4 PS_SaveLastBloom(
float4 p : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
return tex2D(sTempB, uv);
}
#line 694
float4 PS_Blend(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
float4 color = tex2D(sBackBuffer, uv);
color.rgb = inv_reinhard(color.rgb, 1.0 / uMaxBrightness);
#line 699
float4 bloom = tex2D(sTempB, uv);
#line 704
if (uNormalizeBrightness)
bloom *= uIntensity / uMaxBrightness;
else
bloom *= uIntensity;
#line 711
bloom.rgb = mad(tex2D(sLensDirt, uv).rgb, bloom.rgb * uLensDirtAmount, bloom.rgb);
#line 717
switch (uDebugOptions) {
case 1:
if (uBloomTextureToShow == -1) {
color.rgb = reinhard(bloom.rgb);
} else {
const float4 rect = cBlooms[uBloomTextureToShow];
float2 rect_uv = scale_uv(
uv,
1.0 / (1.0 + uPadding * (uBloomTextureToShow + 1)),
0.5
);
#line 729
rect_uv = scale_uv(rect_uv + rect.xy / rect.z, rect.z, 0.0);
color = tex2D(sTempA, rect_uv);
color.rgb = reinhard(color.rgb);
}
#line 734
return color;
case 2:
color = tex2D(sTempA, uv);
color.rgb = lerp(checkered_pattern(uv), color.rgb, color.a);
color.a = 1.0;
#line 740
return color;
#line 743
case 3:
color = tex2Dlod(
sDownSample,
float4(uv, 0.0, 11 - uAdaptPrecision)
);
color.rgb = reinhard(color.rgb);
return color;
#line 751
}
#line 755
color += bloom;
#line 759
color.rgb *= lerp(1.0, exp(uAdaptExposure) / max(tex2D(sAdapt, 0.0).r, 0.001), uAdaptAmount);
#line 765
color.rgb = reinhard(color.rgb);
return color;
}
#line 773
technique NeoBloom {
pass DownSample {
VertexShader = PostProcessVS;
PixelShader = PS_DownSample;
RenderTarget = tNeoBloom_DownSample;
}
pass Split {
VertexShader = PostProcessVS;
PixelShader = PS_Split;
RenderTarget = tNeoBloom_TempA;
}
pass BlurX {
VertexShader = PostProcessVS;
PixelShader = PS_BlurX;
RenderTarget = tNeoBloom_TempB;
}
pass BlurY {
VertexShader = PostProcessVS;
PixelShader = PS_BlurY;
RenderTarget = tNeoBloom_TempA;
}
#line 797
pass CalcAdapt {
VertexShader = PostProcessVS;
PixelShader = PS_CalcAdapt;
RenderTarget = tNeoBloom_Adapt;
}
pass SaveAdapt {
VertexShader = PostProcessVS;
PixelShader = PS_SaveAdapt;
RenderTarget = tNeoBloom_LastAdapt;
}
#line 812
pass JoinBlooms {
VertexShader = PostProcessVS;
PixelShader = PS_JoinBlooms;
RenderTarget = tNeoBloom_TempB;
}
pass SaveLastBloom {
VertexShader = PostProcessVS;
PixelShader = PS_SaveLastBloom;
RenderTarget = tNeoBloom_Ghosting;
}
#line 825
pass Blend {
VertexShader = PostProcessVS;
PixelShader = PS_Blend;
SRGBWriteEnable = true;
}
}

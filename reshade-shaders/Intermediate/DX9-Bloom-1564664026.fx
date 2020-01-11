#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Bloom.fx"
#line 4
uniform int iBloomMixmode <
ui_type = "combo";
ui_items = "Linear add\0Screen add\0Screen/Lighten/Opacity\0Lighten\0";
> = 2;
uniform float fBloomThreshold <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_tooltip = "Every pixel brighter than this value triggers bloom.";
> = 0.8;
uniform float fBloomAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 20.0;
ui_tooltip = "Intensity of bloom.";
> = 0.8;
uniform float fBloomSaturation <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Bloom saturation. 0.0 means white bloom, 2.0 means very, very colorful bloom.";
> = 0.8;
uniform float3 fBloomTint <
ui_type = "color";
ui_tooltip = "R, G and B components of bloom tint the bloom color gets shifted to.";
> = float3(0.7, 0.8, 1.0);
#line 28
uniform bool bLensdirtEnable <
> = false;
uniform int iLensdirtMixmode <
ui_type = "combo";
ui_items = "Linear add\0Screen add\0Screen/Lighten/Opacity\0Lighten\0";
> = 1;
uniform float fLensdirtIntensity <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Intensity of lensdirt.";
> = 0.4;
uniform float fLensdirtSaturation <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Color saturation of lensdirt.";
> = 2.0;
uniform float3 fLensdirtTint <
ui_type = "color";
ui_tooltip = "R, G and B components of lensdirt tint the lensdirt color gets shifted to.";
> = float3(1.0, 1.0, 1.0);
#line 49
uniform bool bAnamFlareEnable <
> = false;
uniform float fAnamFlareThreshold <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_tooltip = "Every pixel brighter than this value gets a flare.";
> = 0.9;
uniform float fAnamFlareWideness <
ui_type = "slider";
ui_min = 1.0; ui_max = 2.5;
ui_tooltip = "Horizontal wideness of flare. Don't set too high, otherwise the single samples are visible.";
> = 2.4;
uniform float fAnamFlareAmount <
ui_type = "slider";
ui_min = 1.0; ui_max = 20.0;
ui_tooltip = "Intensity of anamorphic flare.";
> = 14.5;
uniform float fAnamFlareCurve <
ui_type = "slider";
ui_min = 1.0; ui_max = 2.0;
ui_tooltip = "Intensity curve of flare with distance from source.";
> = 1.2;
uniform float3 fAnamFlareColor <
ui_type = "color";
ui_tooltip = "R, G and B components of anamorphic flare. Flare is always same color.";
> = float3(0.012, 0.313, 0.588);
#line 76
uniform bool bLenzEnable <
> = false;
uniform float fLenzIntensity <
ui_type = "slider";
ui_min = 0.2; ui_max = 3.0;
ui_tooltip = "Power of lens flare effect";
> = 1.0;
uniform float fLenzThreshold <
ui_type = "slider";
ui_min = 0.6; ui_max = 1.0;
ui_tooltip = "Minimum brightness an object must have to cast lensflare.";
> = 0.8;
#line 89
uniform bool bChapFlareEnable <
> = false;
uniform float fChapFlareTreshold <
ui_type = "slider";
ui_min = 0.70; ui_max = 0.99;
ui_tooltip = "Brightness threshold for lensflare generation. Everything brighter than this value gets a flare.";
> = 0.90;
uniform int iChapFlareCount <
ui_type = "slider";
ui_min = 1; ui_max = 20;
ui_tooltip = "Number of single halos to be generated. If set to 0, only the curved halo around is visible.";
> = 15;
uniform float fChapFlareDispersal <
ui_type = "slider";
ui_min = 0.25; ui_max = 1.00;
ui_tooltip = "Distance from screen center (and from themselves) the flares are generated. ";
> = 0.25;
uniform float fChapFlareSize <
ui_type = "slider";
ui_min = 0.20; ui_max = 0.80;
ui_tooltip = "Distance (from screen center) the halo and flares are generated.";
> = 0.45;
uniform float3 fChapFlareCA <
ui_type = "slider";
ui_min = -0.5; ui_max = 0.5;
ui_tooltip = "Offset of RGB components of flares as modifier for Chromatic abberation. Same 3 values means no CA.";
> = float3(0.00, 0.01, 0.02);
uniform float fChapFlareIntensity <
ui_type = "slider";
ui_min = 5.0; ui_max = 200.0;
ui_tooltip = "Intensity of flares and halo, remember that higher threshold lowers intensity, you might play with both values to get desired result.";
> = 100.0;
#line 122
uniform bool bGodrayEnable <
> = false;
uniform float fGodrayDecay <
ui_type = "slider";
ui_min = 0.5000; ui_max = 0.9999;
ui_tooltip = "How fast they decay. It's logarithmic, 1.0 means infinite long rays which will cover whole screen";
> = 0.9900;
uniform float fGodrayExposure <
ui_type = "slider";
ui_min = 0.7; ui_max = 1.5;
ui_tooltip = "Upscales the godray's brightness";
> = 1.0;
uniform float fGodrayWeight <
ui_type = "slider";
ui_min = 0.80; ui_max = 1.70;
ui_tooltip = "weighting";
> = 1.25;
uniform float fGodrayDensity <
ui_type = "slider";
ui_min = 0.2; ui_max = 2.0;
ui_tooltip = "Density of rays, higher means more and brighter rays";
> = 1.0;
uniform float fGodrayThreshold <
ui_type = "slider";
ui_min = 0.6; ui_max = 1.0;
ui_tooltip = "Minimum brightness an object must have to cast godrays";
> = 0.9;
uniform int iGodraySamples <
ui_tooltip = "2^x format values; How many samples the godrays get";
> = 128;
#line 153
uniform float fFlareLuminance <
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "bright pass luminance value ";
> = 0.095;
uniform float fFlareBlur <
ui_type = "slider";
ui_min = 1.0; ui_max = 10000.0;
ui_tooltip = "manages the size of the flare";
> = 200.0;
uniform float fFlareIntensity <
ui_type = "slider";
ui_min = 0.20; ui_max = 5.00;
ui_tooltip = "effect intensity";
> = 2.07;
uniform float3 fFlareTint <
ui_type = "color";
ui_tooltip = "effect tint RGB";
> = float3(0.137, 0.216, 1.0);
#line 188
texture texDirt < source = "LensDBA.png"; > { Width = 1920; Height = 1080; Format = RGBA8; };
texture texSprite < source = "LensSprite.png"; > { Width = 1920; Height = 1080; Format = RGBA8; };
#line 191
sampler SamplerDirt { Texture = texDirt; };
sampler SamplerSprite { Texture = texSprite; };
#line 194
texture texBloom1
{
Width = 1920;
Height = 1080;
Format = RGBA16F;
};
texture texBloom2
{
Width = 1920;
Height = 1080;
Format = RGBA16F;
};
texture texBloom3
{
Width = 1920 / 2;
Height = 1080 / 2;
Format = RGBA16F;
};
texture texBloom4
{
Width = 1920 / 4;
Height = 1080 / 4;
Format = RGBA16F;
};
texture texBloom5
{
Width = 1920 / 8;
Height = 1080 / 8;
Format = RGBA16F;
};
texture texLensFlare1
{
Width = 1920 / 2;
Height = 1080 / 2;
Format = RGBA16F;
};
texture texLensFlare2
{
Width = 1920 / 2;
Height = 1080 / 2;
Format = RGBA16F;
};
#line 237
sampler SamplerBloom1 { Texture = texBloom1; };
sampler SamplerBloom2 { Texture = texBloom2; };
sampler SamplerBloom3 { Texture = texBloom3; };
sampler SamplerBloom4 { Texture = texBloom4; };
sampler SamplerBloom5 { Texture = texBloom5; };
sampler SamplerLensFlare1 { Texture = texLensFlare1; };
sampler SamplerLensFlare2 { Texture = texLensFlare2; };
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Bloom.fx"
#line 247
float4 GaussBlur22(float2 coord, sampler tex, float mult, float lodlevel, bool isBlurVert)
{
float4 sum = 0;
if (isBlurVert)
const float2 axis = (0, 1);
else
const float2 axis = (1, 0);
#line 255
const float weight[11] = {
0.082607,
0.080977,
0.076276,
0.069041,
0.060049,
0.050187,
0.040306,
0.031105,
0.023066,
0.016436,
0.011254
};
#line 269
for (int i = -10; i < 11; i++)
{
const float currweight = weight[abs(i)];
sum += tex2Dlod(tex, float4(coord.xy + axis.xy * (float)i * ReShade::PixelSize * mult, 0, lodlevel)) * currweight;
}
#line 275
return sum;
}
#line 278
float3 GetDnB(sampler tex, float2 coords)
{
float3 color = saturate(dot(tex2Dlod(tex, float4(coords.xy, 0, 4)).rgb, 0.333) - fChapFlareTreshold) * fChapFlareIntensity;
#line 285
return color;
}
float3 GetDistortedTex(sampler tex, float2 sample_center, float2 sample_vector, float3 distortion)
{
const float2 final_vector = sample_center + sample_vector * min(min(distortion.r, distortion.g), distortion.b);
#line 291
if (final_vector.x > 1.0 || final_vector.y > 1.0 || final_vector.x < -1.0 || final_vector.y < -1.0)
return float3(0, 0, 0);
else
return float3(
GetDnB(tex, sample_center + sample_vector * distortion.r).r,
GetDnB(tex, sample_center + sample_vector * distortion.g).g,
GetDnB(tex, sample_center + sample_vector * distortion.b).b);
}
#line 300
float3 GetBrightPass(float2 coords)
{
const float3 c = tex2D(ReShade::BackBuffer, coords).rgb;
const float3 bC = max(c - fFlareLuminance.xxx, 0.0);
float bright = dot(bC, 1.0);
bright = smoothstep(0.0f, 0.5, bright);
float3 result = lerp(0.0, c, bright);
#line 312
return result;
}
float3 GetAnamorphicSample(int axis, float2 coords, float blur)
{
coords = 2.0 * coords - 1.0;
coords.x /= -blur;
return GetBrightPass(0.5 * coords + 0.5);
}
#line 321
void BloomPass0(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 bloom : SV_Target)
{
bloom = 0.0;
#line 325
const float2 offset[4] = {
float2(1.0, 1.0),
float2(1.0, 1.0),
float2(-1.0, 1.0),
float2(-1.0, -1.0)
};
#line 332
for (int i = 0; i < 4; i++)
{
float2 bloomuv = offset[i] * ReShade::PixelSize.xy * 2;
bloomuv += texcoord;
float4 tempbloom = tex2Dlod(ReShade::BackBuffer, float4(bloomuv.xy, 0, 0));
tempbloom.w = saturate(dot(tempbloom.xyz, 0.333) - fAnamFlareThreshold);
tempbloom.xyz = saturate(tempbloom.xyz - fBloomThreshold);
bloom += tempbloom;
}
#line 342
bloom *= 0.25;
}
void BloomPass1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 bloom : SV_Target)
{
bloom = 0.0;
#line 348
const float2 offset[8] = {
float2(1.0, 1.0),
float2(0.0, -1.0),
float2(-1.0, 1.0),
float2(-1.0, -1.0),
float2(0.0, 1.0),
float2(0.0, -1.0),
float2(1.0, 0.0),
float2(-1.0, 0.0)
};
#line 359
for (int i = 0; i < 8; i++)
{
float2 bloomuv = offset[i] * ReShade::PixelSize * 4;
bloomuv += texcoord;
bloom += tex2Dlod(SamplerBloom1, float4(bloomuv, 0, 0));
}
#line 366
bloom *= 0.125;
}
void BloomPass2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 bloom : SV_Target)
{
bloom = 0.0;
#line 372
const float2 offset[8] = {
float2(0.707, 0.707),
float2(0.707, -0.707),
float2(-0.707, 0.707),
float2(-0.707, -0.707),
float2(0.0, 1.0),
float2(0.0, -1.0),
float2(1.0, 0.0),
float2(-1.0, 0.0)
};
#line 383
for (int i = 0; i < 8; i++)
{
float2 bloomuv = offset[i] * ReShade::PixelSize * 8;
bloomuv += texcoord;
bloom += tex2Dlod(SamplerBloom2, float4(bloomuv, 0, 0));
}
#line 390
bloom *= 0.5; 
}
void BloomPass3(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 bloom : SV_Target)
{
bloom = GaussBlur22(texcoord.xy, SamplerBloom3, 16, 0, 0);
bloom.w *= fAnamFlareAmount;
bloom.xyz *= fBloomAmount;
}
void BloomPass4(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 bloom : SV_Target)
{
bloom.xyz = GaussBlur22(texcoord, SamplerBloom4, 16, 0, 1).xyz * 2.5;
bloom.w = GaussBlur22(texcoord, SamplerBloom4, 32 * fAnamFlareWideness, 0, 0).w * 2.5; 
}
#line 404
void LensFlarePass0(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 lens : SV_Target)
{
lens = 0;
#line 409
if (bLenzEnable)
{
const float3 lfoffset[19] = {
float3(0.9, 0.01, 4),
float3(0.7, 0.25, 25),
float3(0.3, 0.25, 15),
float3(1, 1.0, 5),
float3(-0.15, 20, 1),
float3(-0.3, 20, 1),
float3(6, 6, 6),
float3(7, 7, 7),
float3(8, 8, 8),
float3(9, 9, 9),
float3(0.24, 1, 10),
float3(0.32, 1, 10),
float3(0.4, 1, 10),
float3(0.5, -0.5, 2),
float3(2, 2, -5),
float3(-5, 0.2, 0.2),
float3(20, 0.5, 0),
float3(0.4, 1, 10),
float3(0.00001, 10, 20)
};
const float3 lffactors[19] = {
float3(1.5, 1.5, 0),
float3(0, 1.5, 0),
float3(0, 0, 1.5),
float3(0.2, 0.25, 0),
float3(0.15, 0, 0),
float3(0, 0, 0.15),
float3(1.4, 0, 0),
float3(1, 1, 0),
float3(0, 1, 0),
float3(0, 0, 1.4),
float3(1, 0.3, 0),
float3(1, 1, 0),
float3(0, 2, 4),
float3(0.2, 0.1, 0),
float3(0, 0, 1),
float3(1, 1, 0),
float3(1, 1, 0),
float3(0, 0, 0.2),
float3(0.012,0.313,0.588)
};
#line 454
float2 lfcoord = 0;
float3 lenstemp = 0;
float2 distfact = texcoord.xy - 0.5;
distfact.x *= ReShade::AspectRatio;
#line 459
for (int i = 0; i < 19; i++)
{
lfcoord.xy = lfoffset[i].x * distfact;
lfcoord.xy *= pow(2.0 * length(distfact), lfoffset[i].y * 3.5);
lfcoord.xy *= lfoffset[i].z;
lfcoord.xy = 0.5 - lfcoord.xy;
const float2 tempfact = (lfcoord.xy - 0.5) * 2;
const float templensmult = clamp(1.0 - dot(tempfact, tempfact), 0, 1);
float3 lenstemp1 = dot(tex2Dlod(ReShade::BackBuffer, float4(lfcoord.xy, 0, 1)).rgb, 0.333);
#line 475
lenstemp1 = saturate(lenstemp1.xyz - fLenzThreshold);
lenstemp1 *= lffactors[i] * templensmult;
#line 478
lenstemp += lenstemp1;
}
#line 481
lens.rgb += lenstemp * fLenzIntensity;
}
#line 485
if (bChapFlareEnable)
{
const float2 sample_vector = (float2(0.5, 0.5) - texcoord.xy) * fChapFlareDispersal;
const float2 halo_vector = normalize(sample_vector) * fChapFlareSize;
#line 490
float3 chaplens = GetDistortedTex(ReShade::BackBuffer, texcoord.xy + halo_vector, halo_vector, fChapFlareCA * 2.5f).rgb;
#line 492
for (int j = 0; j < iChapFlareCount; ++j)
{
const float2 foffset = sample_vector * float(j);
chaplens += GetDistortedTex(ReShade::BackBuffer, texcoord.xy + foffset, foffset, fChapFlareCA).rgb;
}
#line 498
chaplens *= 1.0 / iChapFlareCount;
lens.xyz += chaplens;
}
#line 503
if (bGodrayEnable)
{
const float2 ScreenLightPos = float2(0.5, 0.5);
float2 texcoord2 = texcoord;
float2 deltaTexCoord = (texcoord2 - ScreenLightPos);
deltaTexCoord *= 1.0 / (float)iGodraySamples * fGodrayDensity;
#line 510
float illuminationDecay = 1.0;
#line 512
for (int g = 0; g < iGodraySamples; g++)
{
texcoord2 -= deltaTexCoord;;
float4 sample2 = tex2Dlod(ReShade::BackBuffer, float4(texcoord2, 0, 0));
float sampledepth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord2, 0, 0)).x;
sample2.w = saturate(dot(sample2.xyz, 0.3333) - fGodrayThreshold);
sample2.r *= 1.00;
sample2.g *= 0.95;
sample2.b *= 0.85;
sample2 *= illuminationDecay * fGodrayWeight;
#line 526
lens.rgb += sample2.xyz * sample2.w;
#line 528
illuminationDecay *= fGodrayDecay;
}
}
#line 533
if (bAnamFlareEnable)
{
float3 anamFlare = 0;
const float gaussweight[5] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };
#line 538
for (int z = -4; z < 5; z++)
{
anamFlare += GetAnamorphicSample(0, texcoord.xy + float2(0, z * ReShade::PixelSize.y * 2), fFlareBlur) * fFlareTint * gaussweight[abs(z)];
}
#line 543
lens.xyz += anamFlare * fFlareIntensity;
}
}
void LensFlarePass1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 lens : SV_Target)
{
lens = GaussBlur22(texcoord, SamplerLensFlare1, 2, 0, 1);
}
void LensFlarePass2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 lens : SV_Target)
{
lens = GaussBlur22(texcoord, SamplerLensFlare2, 2, 0, 0);
}
#line 555
void LightingCombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
color = tex2D(ReShade::BackBuffer, texcoord);
#line 560
float3 colorbloom = 0;
colorbloom += tex2D(SamplerBloom3, texcoord).rgb * 1.0;
colorbloom += tex2D(SamplerBloom5, texcoord).rgb * 9.0;
colorbloom *= 0.1;
colorbloom = saturate(colorbloom);
const float colorbloomgray = dot(colorbloom, 0.333);
colorbloom = lerp(colorbloomgray, colorbloom, fBloomSaturation);
colorbloom *= fBloomTint;
#line 569
if (iBloomMixmode == 0)
color.rgb += colorbloom;
else if (iBloomMixmode == 1)
color.rgb = 1 - (1 - color.rgb) * (1 - colorbloom);
else if (iBloomMixmode == 2)
color.rgb = saturate(max(color.rgb, lerp(color.rgb, (1 - (1 - saturate(colorbloom)) * (1 - saturate(colorbloom))), 1.0)));
else if (iBloomMixmode == 3)
color.rgb = max(color.rgb, colorbloom);
#line 579
if (bAnamFlareEnable)
{
float3 anamflare = tex2D(SamplerBloom5, texcoord.xy).w * 2 * fAnamFlareColor;
anamflare = max(anamflare, 0.0);
color.rgb += pow(anamflare, 1.0 / fAnamFlareCurve);
}
#line 587
if (bLensdirtEnable)
{
const float lensdirtmult = dot(tex2D(SamplerBloom5, texcoord).rgb, 0.333);
const float3 dirttex = tex2D(SamplerDirt, texcoord).rgb;
float3 lensdirt = dirttex * lensdirtmult * fLensdirtIntensity;
#line 593
lensdirt = lerp(dot(lensdirt.xyz, 0.333), lensdirt.xyz, fLensdirtSaturation);
#line 595
if (iLensdirtMixmode == 0)
color.rgb += lensdirt;
else if (iLensdirtMixmode == 1)
color.rgb = 1 - (1 - color.rgb) * (1 - lensdirt);
else if (iLensdirtMixmode == 2)
color.rgb = saturate(max(color.rgb, lerp(color.rgb, (1 - (1 - saturate(lensdirt)) * (1 - saturate(lensdirt))), 1.0)));
else if (iLensdirtMixmode == 3)
color.rgb = max(color.rgb, lensdirt);
}
#line 606
if (bAnamFlareEnable || bLenzEnable || bGodrayEnable || bChapFlareEnable)
{
float3 lensflareSample = tex2D(SamplerLensFlare1, texcoord.xy).rgb, lensflareMask;
lensflareMask  = tex2D(SamplerSprite, texcoord + float2( 0.5,  0.5) * ReShade::PixelSize).rgb;
lensflareMask += tex2D(SamplerSprite, texcoord + float2(-0.5,  0.5) * ReShade::PixelSize).rgb;
lensflareMask += tex2D(SamplerSprite, texcoord + float2( 0.5, -0.5) * ReShade::PixelSize).rgb;
lensflareMask += tex2D(SamplerSprite, texcoord + float2(-0.5, -0.5) * ReShade::PixelSize).rgb;
#line 614
color.rgb += lensflareMask * 0.25 * lensflareSample;
}
}
#line 618
technique BloomAndLensFlares
{
pass BloomPass0
{
VertexShader = PostProcessVS;
PixelShader = BloomPass0;
RenderTarget = texBloom1;
}
pass BloomPass1
{
VertexShader = PostProcessVS;
PixelShader = BloomPass1;
RenderTarget = texBloom2;
}
pass BloomPass2
{
VertexShader = PostProcessVS;
PixelShader = BloomPass2;
RenderTarget = texBloom3;
}
pass BloomPass3
{
VertexShader = PostProcessVS;
PixelShader = BloomPass3;
RenderTarget = texBloom4;
}
pass BloomPass4
{
VertexShader = PostProcessVS;
PixelShader = BloomPass4;
RenderTarget = texBloom5;
}
#line 651
pass LensFlarePass0
{
VertexShader = PostProcessVS;
PixelShader = LensFlarePass0;
RenderTarget = texLensFlare1;
}
pass LensFlarePass1
{
VertexShader = PostProcessVS;
PixelShader = LensFlarePass1;
RenderTarget = texLensFlare2;
}
pass LensFlarePass2
{
VertexShader = PostProcessVS;
PixelShader = LensFlarePass2;
RenderTarget = texLensFlare1;
}
#line 670
pass LightingCombine
{
VertexShader = PostProcessVS;
PixelShader = LightingCombine;
}
}

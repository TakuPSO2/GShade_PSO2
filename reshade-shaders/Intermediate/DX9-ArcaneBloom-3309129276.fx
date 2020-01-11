#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ArcaneBloom.fx"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ArcaneBloom.fxh"
#line 23
namespace ArcaneBloom {
#line 34
namespace _ {
#line 42
texture2D tArcaneBloom_Bloom0 { Width  = 1920 / 2; Height = 1080 / 2; Format = RGBA16F; };
texture2D tArcaneBloom_Bloom1 { Width  = 1920 / 4; Height = 1080 / 4; Format = RGBA16F; };
texture2D tArcaneBloom_Bloom2 { Width  = 1920 / 8; Height = 1080 / 8; Format = RGBA16F; };
texture2D tArcaneBloom_Bloom3 { Width  = 1920 / 16; Height = 1080 / 16; Format = RGBA16F; };
texture2D tArcaneBloom_Bloom4 { Width  = 1920 / 32; Height = 1080 / 32; Format = RGBA16F; };
#line 52
texture2D tArcaneBloom_Adapt {
Format = R32F;
};
#line 56
}
#line 63
sampler2D sBloom0 { Texture = _::tArcaneBloom_Bloom0; };
sampler2D sBloom1 { Texture = _::tArcaneBloom_Bloom1; };
sampler2D sBloom2 { Texture = _::tArcaneBloom_Bloom2; };
sampler2D sBloom3 { Texture = _::tArcaneBloom_Bloom3; };
sampler2D sBloom4 { Texture = _::tArcaneBloom_Bloom4; };
#line 73
sampler2D sAdapt {
Texture   = _::tArcaneBloom_Adapt;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU  = CLAMP;
AddressV  = CLAMP;
AddressW  = CLAMP;
};
#line 88
static const float cPI = 3.1415926535897932384626433832795;
#line 94
float3 inv_reinhard(float3 color, float inv_max) {
return (color / max(1.0 - color, inv_max));
}
#line 98
float3 inv_reinhard_lum(float3 color, float inv_max) {
const float lum = max(color.r, max(color.g, color.b));
return color * (lum / max(1.0 - lum, inv_max));
}
#line 103
float3 reinhard(float3 color) {
return color / (1.0 + color);
}
#line 107
float3 box_blur(sampler2D sp, float2 uv, float2 ps) {
return (tex2D(sp, uv - ps * 0.5).rgb +
tex2D(sp, uv + ps * 0.5).rgb +
tex2D(sp, uv + float2(-ps.x, ps.y) * 0.5).rgb +
tex2D(sp, uv + float2( ps.x,-ps.y) * 0.5).rgb) * 0.25;
}
#line 116
static const int cGaussianSamples = 13;
float get_weight(int i) {
static const float weights[cGaussianSamples] = {
0.017997,
0.033159,
0.054670,
0.080657,
0.106483,
0.125794,
0.132981,
0.125794,
0.106483,
0.080657,
0.054670,
0.033159,
0.017997
};
return weights[i];
}
#line 136
float3 gaussian_blur(sampler2D sp, float2 uv, float2 dir) {
float3 color = 0.0;
uv -= dir * floor(cGaussianSamples * 0.5);
#line 140
[unroll]
for (int i = 0; i < cGaussianSamples; ++i) {
color += tex2D(sp, uv).rgb * get_weight(i);
uv += dir;
}
#line 146
return color;
}
#line 149
float get_luma_linear(float3 c) {
return dot(c, float3(0.2126, 0.7152, 0.0722));
}
#line 153
float normal_distribution(float x, float mean, float variance) {
const float sigma = variance * variance;
const float a = 1.0 / sqrt(2.0 * cPI * sigma);
float b = x - mean;
b *= b;
b /= 2.0 * sigma;
#line 160
return a * exp(-b);
}
}
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ArcaneBloom.fx"
#line 6
namespace ArcaneBloom { namespace _ {
#line 127
static const float AspectRatio = 1920 * (1.0 / 1080);
static const float2 PixelSize = float2((1.0 / 1920), (1.0 / 1080));
static const float2 ScreenSize = float2(1920, 1080);
#line 137
uniform float uBloomIntensity <
ui_label = "Intensity";
ui_category = "Bloom";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 0.01;
> = 1.0;
#line 191
uniform float uAdapt_Intensity <
ui_label   = "Intensity";
ui_category = "Adaptation";
ui_tooltip = "Default: 1.0";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.001;
> = 1.0;
#line 201
uniform float uAdapt_Time <
ui_label   = "Time to Adapt (Seconds)";
ui_category = "Adaptation";
ui_tooltip = "Default: 100.0";
ui_type    = "slider";
ui_min     = 0.01;
ui_max     = 10.0;
ui_step    = 0.01;
> = 1.0;
#line 211
uniform float uAdapt_Sensitivity <
ui_label   = "Sensitivity";
ui_category = "Adaptation";
ui_tooltip = "Default: 1.0";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 3.0;
ui_step    = 0.001;
> = 1.0;
#line 221
uniform float uAdapt_Precision <
ui_label   = "Precision";
ui_category = "Adaptation";
ui_tooltip = "Default: 0.0";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 11.0;
ui_step    = 0.01;
> = 0.0;
#line 231
uniform bool uAdapt_DoLimits <
ui_label   = "Use Limits";
ui_category = "Adaptation";
ui_tooltip = "Default: On";
> = true;
#line 237
uniform float2 uAdapt_Limits <
ui_label   = "Limits (Min/Max)";
ui_category = "Adaptation";
ui_tooltip = "Default: (0.0, 1.0)";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.001;
> = float2(0.0, 1.0);
#line 271
uniform float uExposure <
ui_label   = "Exposure";
ui_category = "Miscellaneous";
ui_tooltip = "Default: 1.0";
ui_type    = "slider";
ui_min     = 0.001;
ui_max     = 3.0;
ui_step    = 0.001;
> = 1.0;
#line 281
uniform float uMaxBrightness <
ui_label   = "Max Brightness";
ui_category = "Miscellaneous";
ui_tooltip = "Default: 100.0";
ui_type    = "slider";
ui_min     = 1.0;
ui_max     = 100.0;
ui_step    = 0.1;
> = 100.0;
#line 293
uniform float uWhitePoint <
ui_label = "White Point";
ui_category = "Miscellaneous";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.01;
> = 1.0;
#line 343
uniform float uTime <source = "timer";>;
uniform float uFrameTime <source = "frametime";>;
#line 350
texture2D tArcaneBloom_BackBuffer : COLOR;
sampler2D sBackBuffer {
Texture     = tArcaneBloom_BackBuffer;
#line 354
SRGBTexture = true;
#line 356
};
#line 358
texture2D tArcaneBloom_Bloom0Alt { Width  = 1920 / 2; Height = 1080 / 2; Format = RGBA16F; }; sampler2D sBloom0Alt { Texture = tArcaneBloom_Bloom0Alt; };
texture2D tArcaneBloom_Bloom1Alt { Width  = 1920 / 4; Height = 1080 / 4; Format = RGBA16F; }; sampler2D sBloom1Alt { Texture = tArcaneBloom_Bloom1Alt; };
texture2D tArcaneBloom_Bloom2Alt { Width  = 1920 / 8; Height = 1080 / 8; Format = RGBA16F; }; sampler2D sBloom2Alt { Texture = tArcaneBloom_Bloom2Alt; };
texture2D tArcaneBloom_Bloom3Alt { Width  = 1920 / 16; Height = 1080 / 16; Format = RGBA16F; }; sampler2D sBloom3Alt { Texture = tArcaneBloom_Bloom3Alt; };
texture2D tArcaneBloom_Bloom4Alt { Width  = 1920 / 32; Height = 1080 / 32; Format = RGBA16F; }; sampler2D sBloom4Alt { Texture = tArcaneBloom_Bloom4Alt; };
#line 367
texture2D tArcaneBloom_Small {
Width     = 1024;
Height    = 1024;
Format    = R32F;
MipLevels = 11;
};
sampler2D sSmall {
Texture = tArcaneBloom_Small;
};
#line 377
texture2D tArcaneBloom_LastAdapt {
Format = R32F;
};
sampler2D sLastAdapt {
Texture   = tArcaneBloom_LastAdapt;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU  = CLAMP;
AddressV  = CLAMP;
AddressW  = CLAMP;
};
#line 424
float get_bloom_weight(int i) {
#line 428
static const float weights[6] = {
9.0 / 9.0,
6.0 / 9.0,
3.0 / 9.0,
2.0 / 9.0,
6.0 / 9.0,
9.0 / 9.0
};
#line 437
return weights[i];
#line 442
}
#line 444
float3 blend_overlay(float3 a, float3 b, float w) {
const float3 c = lerp(
2.0 * a * b,
1.0 - 2.0 * (1.0 - a) * (1.0 - b),
step(0.5, a)
);
return lerp(a, c, w);
}
#line 468
void VS_PostProcess(
uint id : SV_VERTEXID,
out float4 position : SV_POSITION,
out float2 uv : TEXCOORD
) {
if (id == 2)
uv.x = 2.0;
else
uv.x = 0.0;
if (id == 1)
uv.y = 2.0;
else
uv.y = 0.0;
position = float4(
uv * float2(2.0, -2.0) + float2(-1.0, 1.0),
0.0,
1.0
);
}
#line 488
float4 PS_GetHDR( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET {
float3 color = tex2D(sBackBuffer, uv).rgb;
#line 504
color = clamp(color, 0.0, 32767.0);
#line 514
color = inv_reinhard_lum(color, 1.0 / uMaxBrightness);
return float4(color, 1.0);
}
#line 528
float4 PS_GetSmall( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET {
const float3 color = tex2D(sBloom0Alt, uv).rgb;
return float4(get_luma_linear(color), 0.0, 0.0, 1.0);
}
#line 533
float4 PS_GetAdapt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET {
float adapt = tex2Dlod(sSmall, float4(uv, 0, 11 - uAdapt_Precision)).x;
adapt *= uAdapt_Sensitivity;
#line 537
if (uAdapt_DoLimits)
adapt = clamp(adapt, uAdapt_Limits.x, uAdapt_Limits.y);
#line 540
float last = tex2D(sLastAdapt, 0).x;
adapt = lerp(last, adapt, (uFrameTime * 0.001) / uAdapt_Time);
#line 543
return float4(adapt, 0.0, 0.0, 1.0);
}
#line 546
float4 PS_SaveAdapt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET {
return tex2D(sAdapt, 0);
}
#line 552
float4 PS_DownSample_Bloom0Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { return float4(box_blur(sBloom0Alt, uv, PixelSize * 2*2.0), 1.0); }
float4 PS_BlurX_Bloom0( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2((1.0 / 1920) * 2*0.5, 0.0); return float4(gaussian_blur(sBloom0, uv, dir), 1.0); } float4 PS_BlurY_Bloom0Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2(0.0, (1.0 / 1080) * 2*0.5); return float4(gaussian_blur(sBloom0Alt, uv, dir), 1.0); }
#line 555
float4 PS_DownSample_Bloom0( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { return float4(box_blur(sBloom0, uv, PixelSize * 4*2.0), 1.0); }
float4 PS_BlurX_Bloom1( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2((1.0 / 1920) * 4*1.0, 0.0); return float4(gaussian_blur(sBloom1, uv, dir), 1.0); } float4 PS_BlurY_Bloom1Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2(0.0, (1.0 / 1080) * 4*1.0); return float4(gaussian_blur(sBloom1Alt, uv, dir), 1.0); }
#line 558
float4 PS_DownSample_Bloom1( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { return float4(box_blur(sBloom1, uv, PixelSize * 8*2.0), 1.0); }
float4 PS_BlurX_Bloom2( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2((1.0 / 1920) * 8*1.0, 0.0); return float4(gaussian_blur(sBloom2, uv, dir), 1.0); } float4 PS_BlurY_Bloom2Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2(0.0, (1.0 / 1080) * 8*1.0); return float4(gaussian_blur(sBloom2Alt, uv, dir), 1.0); }
#line 561
float4 PS_DownSample_Bloom2( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { return float4(box_blur(sBloom2, uv, PixelSize * 16*2.0), 1.0); }
float4 PS_BlurX_Bloom3( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2((1.0 / 1920) * 16*2.0, 0.0); return float4(gaussian_blur(sBloom3, uv, dir), 1.0); } float4 PS_BlurY_Bloom3Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2(0.0, (1.0 / 1080) * 16*2.0); return float4(gaussian_blur(sBloom3Alt, uv, dir), 1.0); }
#line 564
float4 PS_DownSample_Bloom3( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { return float4(box_blur(sBloom3, uv, PixelSize * 32*2.0), 1.0); }
float4 PS_BlurX_Bloom4( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2((1.0 / 1920) * 32*3.0, 0.0); return float4(gaussian_blur(sBloom4, uv, dir), 1.0); } float4 PS_BlurY_Bloom4Alt( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET { const float2 dir = float2(0.0, (1.0 / 1080) * 32*3.0); return float4(gaussian_blur(sBloom4Alt, uv, dir), 1.0); }
#line 570
float4 PS_Blend( float4 position : SV_POSITION, float2 uv       : TEXCOORD ) : SV_TARGET {
float3 color = tex2D(sBackBuffer, uv).rgb;
color = inv_reinhard(color, 1.0 / uMaxBrightness);
#line 574
float3 bloom =
tex2D(sBloom0, uv).rgb * get_bloom_weight(0) +
tex2D(sBloom1, uv).rgb * get_bloom_weight(1) +
tex2D(sBloom2, uv).rgb * get_bloom_weight(2) +
tex2D(sBloom3, uv).rgb * get_bloom_weight(3) +
tex2D(sBloom4, uv).rgb * get_bloom_weight(4);
#line 586
bloom *= uBloomIntensity / uMaxBrightness;
#line 600
color += bloom;
#line 606
const float adapt = tex2D(sAdapt, 0).x;
const float exposure = uExposure / max(adapt, 0.001);
#line 609
color *= lerp(1.0, exposure, uAdapt_Intensity);
#line 612
const float white = uWhitePoint * lerp(1.0, exposure, uAdapt_Intensity);
#line 625
color = reinhard(color);
#line 628
color /= reinhard(white);
#line 635
return float4(color, 1.0);
}
#line 642
technique ArcaneBloom {
pass GetHDR { VertexShader = VS_PostProcess; PixelShader  = PS_GetHDR; RenderTarget = tArcaneBloom_Bloom0Alt; }
#line 646
pass GetSmall { VertexShader = VS_PostProcess; PixelShader  = PS_GetSmall; RenderTarget = tArcaneBloom_Small; }
pass GetAdapt { VertexShader = VS_PostProcess; PixelShader  = PS_GetAdapt; RenderTarget = tArcaneBloom_Adapt; }
pass SaveAdapt { VertexShader = VS_PostProcess; PixelShader  = PS_SaveAdapt; RenderTarget = tArcaneBloom_LastAdapt; }
#line 651
pass DownSample_Bloom0Alt { VertexShader = VS_PostProcess; PixelShader  = PS_DownSample_Bloom0Alt; RenderTarget = tArcaneBloom_Bloom0; }
pass BlurX_Bloom0 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom0; RenderTarget = tArcaneBloom_Bloom0Alt; } pass BlurY_Bloom0Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom0Alt; RenderTarget = tArcaneBloom_Bloom0; } pass BlurX_Bloom0 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom0; RenderTarget = tArcaneBloom_Bloom0Alt; } pass BlurY_Bloom0Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom0Alt; RenderTarget = tArcaneBloom_Bloom0; }
#line 654
pass DownSample_Bloom0 { VertexShader = VS_PostProcess; PixelShader  = PS_DownSample_Bloom0; RenderTarget = tArcaneBloom_Bloom1; }
pass BlurX_Bloom1 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom1; RenderTarget = tArcaneBloom_Bloom1Alt; } pass BlurY_Bloom1Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom1Alt; RenderTarget = tArcaneBloom_Bloom1; } pass BlurX_Bloom1 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom1; RenderTarget = tArcaneBloom_Bloom1Alt; } pass BlurY_Bloom1Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom1Alt; RenderTarget = tArcaneBloom_Bloom1; }
#line 657
pass DownSample_Bloom1 { VertexShader = VS_PostProcess; PixelShader  = PS_DownSample_Bloom1; RenderTarget = tArcaneBloom_Bloom2; }
pass BlurX_Bloom2 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom2; RenderTarget = tArcaneBloom_Bloom2Alt; } pass BlurY_Bloom2Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom2Alt; RenderTarget = tArcaneBloom_Bloom2; } pass BlurX_Bloom2 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom2; RenderTarget = tArcaneBloom_Bloom2Alt; } pass BlurY_Bloom2Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom2Alt; RenderTarget = tArcaneBloom_Bloom2; }
#line 660
pass DownSample_Bloom2 { VertexShader = VS_PostProcess; PixelShader  = PS_DownSample_Bloom2; RenderTarget = tArcaneBloom_Bloom3; }
pass BlurX_Bloom3 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom3; RenderTarget = tArcaneBloom_Bloom3Alt; } pass BlurY_Bloom3Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom3Alt; RenderTarget = tArcaneBloom_Bloom3; } pass BlurX_Bloom3 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom3; RenderTarget = tArcaneBloom_Bloom3Alt; } pass BlurY_Bloom3Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom3Alt; RenderTarget = tArcaneBloom_Bloom3; }
#line 663
pass DownSample_Bloom3 { VertexShader = VS_PostProcess; PixelShader  = PS_DownSample_Bloom3; RenderTarget = tArcaneBloom_Bloom4; }
pass BlurX_Bloom4 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom4; RenderTarget = tArcaneBloom_Bloom4Alt; } pass BlurY_Bloom4Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom4Alt; RenderTarget = tArcaneBloom_Bloom4; } pass BlurX_Bloom4 { VertexShader = VS_PostProcess; PixelShader  = PS_BlurX_Bloom4; RenderTarget = tArcaneBloom_Bloom4Alt; } pass BlurY_Bloom4Alt { VertexShader = VS_PostProcess; PixelShader  = PS_BlurY_Bloom4Alt; RenderTarget = tArcaneBloom_Bloom4; }
#line 669
pass Blend {
VertexShader = VS_PostProcess;
PixelShader = PS_Blend;
#line 673
SRGBWriteEnable = true;
#line 675
}
#line 686
}
#line 688
}}

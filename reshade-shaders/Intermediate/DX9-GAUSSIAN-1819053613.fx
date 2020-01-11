#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GAUSSIAN.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GAUSSIAN.fx"
#line 36
uniform int gGaussEffect <
ui_label = "Gauss Effect";
ui_type = "combo";
ui_items="Off\0Blur\0Unsharpmask (expensive)\0Bloom\0Sketchy\0Effects Image Only\0";
> = 1;
#line 42
uniform float gGaussStrength <
ui_label = "Gauss Strength";
ui_tooltip = "Amount of effect blended into the final image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.3;
#line 51
uniform bool gAddBloom <
ui_label = "Add Bloom";
> = 0;
#line 59
uniform float gBloomStrength <
ui_label = "Bloom Strength";
ui_tooltip = "Amount of Bloom added to the final image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.33;
#line 68
uniform float gBloomIntensity <
ui_label = "Bloom Intensity";
ui_tooltip = "Makes bright spots brighter. Also affects Blur and Unsharpmask.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 6.0;
ui_step = 0.001;
> = 3.0;
#line 77
uniform int gGaussBloomWarmth <
ui_label = "Bloom Warmth";
ui_tooltip = "Choose a tonemapping algorithm fitting your personal taste.";
ui_type = "combo";
ui_items="Neutral\0Warm\0Hazy/Foggy\0";
> = 0;
#line 84
uniform int gN_PASSES <
ui_label = "Number of Gaussian Passes";
ui_tooltip = "When gGaussQuality = 0, N_PASSES must be set to 3, 4, or 5.\nWhen using gGaussQuality = 1, N_PASSES must be set to 3,4,5,6,7,8, or 9.\nStill fine tuning this. Changing the number of passes can affect brightness.";
ui_type = "slider";
ui_min = 3;
ui_max = 9;
ui_step = 1;
> = 5;
#line 93
uniform float gBloomHW <
ui_label = "Horizontal Bloom Width";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 1.0;
#line 102
uniform float gBloomVW <
ui_label = "Vertical Bloom Width";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 1.0;
#line 111
uniform float gBloomSW <
ui_label = "Bloom Slant";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 2.0;
#line 127
texture origframeTex2D
{
Width = 1920;
Height = 1080;
Format = R8G8B8A8;
};
#line 134
sampler origframeSampler
{
Texture = origframeTex2D;
AddressU  = Clamp; AddressV = Clamp;
MipFilter = None; MinFilter = Linear; MagFilter = Linear;
SRGBTexture = false;
};
#line 142
float4 BrightPassFilterPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
const float4 color = tex2D(ReShade::BackBuffer, texcoord);
return float4 (color.rgb * pow (abs (max (color.r, max (color.g, color.b))), 2.0), 2.0f)*gBloomIntensity;
}
#line 148
float4 HGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 151
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 158
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomHW * float2((1.0 / 1920),(1.0 / 1080)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsets[i]*gBloomHW * float2((1.0 / 1920),(1.0 / 1080)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 166
float4 VGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 169
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 176
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(0.0, sampleOffsets[i]*gBloomVW * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(0.0, sampleOffsets[i]*gBloomVW * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 184
float4 SGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 187
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 194
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1080)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1080)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(-sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1080)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1080)).x, -sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1080)).y), 0.0, 0.0)) * sampleWeights[i];
}
return color * 0.50;
}
#line 204
float4 CombinePS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 210
float4 orig = tex2D(origframeSampler, texcoord);
const float4 blur = tex2D(ReShade::BackBuffer, texcoord);
float3 sharp;
if (gGaussEffect == 0)
orig = orig;
else if (gGaussEffect == 1)
{
#line 218
orig = lerp(orig, blur, gGaussStrength);
}
else if (gGaussEffect == 2)
{
#line 223
sharp = orig.rgb - blur.rgb;
float sharp_luma = dot(sharp, (float3(0.2126, 0.7152, 0.0722)       * gGaussStrength + 0.2));
sharp_luma = clamp(sharp_luma, -0.035, 0.035);
orig = orig + sharp_luma;
}
else if (gGaussEffect == 3)
{
#line 231
if (gGaussBloomWarmth == 0)
orig = lerp(orig, blur *4, gGaussStrength);
#line 234
else if (gGaussBloomWarmth == 1)
orig = lerp(orig, max(orig *1.8 + (blur *5) - 1.0, 0.0), gGaussStrength);       
else
orig = lerp(orig, (1.0 - ((1.0 - orig) * (1.0 - blur *1.0))), gGaussStrength);  
}
else if (gGaussEffect == 4)
{
#line 242
sharp = orig.rgb - blur.rgb;
orig = float4(1.0, 1.0, 1.0, 0.0) - min(orig, dot(sharp, (float3(0.2126, 0.7152, 0.0722)       * gGaussStrength + 0.2))) *3;
#line 245
}
else
orig = blur;
#line 249
if (gAddBloom == 1)
{
if (gGaussBloomWarmth == 0)
{
orig += lerp(orig, blur *4, gBloomStrength);
orig = orig * 0.5;
}
else if (gGaussBloomWarmth == 1)
{
orig += lerp(orig, max(orig *1.8 + (blur *5) - 1.0, 0.0), gBloomStrength);
orig = orig * 0.5;
}
else
{
orig += lerp(orig, (1.0 - ((1.0 - orig) * (1.0 - blur *1.0))), gBloomStrength);
orig = orig * 0.5;
}
}
else
orig = orig;
#line 275
return orig;
}
#line 278
float4 PassThrough(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return tex2D(ReShade::BackBuffer, texcoord);
}
#line 283
technique GAUSSSIAN
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PassThrough;
RenderTarget = origframeTex2D;
}
#line 293
pass P0
{
VertexShader = PostProcessVS;
PixelShader = BrightPassFilterPS;
}
#line 301
pass P1
{
VertexShader = PostProcessVS;
PixelShader = HGaussianBlurPS;
}
#line 309
pass P2
{
VertexShader = PostProcessVS;
PixelShader = VGaussianBlurPS;
}
#line 317
pass P3
{
VertexShader = PostProcessVS;
PixelShader = SGaussianBlurPS;
}
#line 324
pass P5
{
VertexShader = PostProcessVS;
PixelShader = CombinePS;
}
}

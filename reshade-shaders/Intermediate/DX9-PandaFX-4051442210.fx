#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PandaFX.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\PandaFX.fx"
#line 20
uniform float Blend_Amount <
ui_label = "Blend Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Blend the effect with the original image.";
> = 1.0;
#line 30
uniform bool Enable_Diffusion <
ui_label = "Enable the lens diffusion effect";
ui_tooltip = "Enable a light diffusion that emulates the glare of a camera lens.";
> = true;
#line 35
uniform bool Enable_Bleach_Bypass <
ui_label = "Enable the 'Bleach Bypass' effect";
ui_tooltip = "Enable a cinematic contrast effect that emulates a bleach bypass on film. Used a lot in war movies and gives the image a grittier feel.";
> = true;
#line 40
uniform bool Enable_Dither <
ui_label = "Dither";
ui_tooltip = "Dither the final result.";
> = true;
#line 48
uniform float Contrast_R <
ui_label = "Contrast (Red)";
ui_type = "slider";
ui_min = 0.00001;
ui_max = 20.0;
ui_tooltip = "Apply contrast to red.";
> = 2.2;
#line 56
uniform float Contrast_G <
ui_label = "Contrast (Green)";
ui_type = "slider";
ui_min = 0.00001;
ui_max = 20.0;
ui_tooltip = "Apply contrast to green.";
> = 2.0;
#line 64
uniform float Contrast_B <
ui_label = "Contrast (Blue)";
ui_type = "slider";
ui_min = 0.00001;
ui_max = 20.0;
ui_tooltip = "Apply contrast to blue.";
> = 2.0;
#line 72
uniform float Gamma_R <
ui_label = "Gamma (Red)";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to red.";
> = 1.0;
#line 80
uniform float Gamma_G <
ui_label = "Gamma (Green)";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to green.";
> = 1.0;
#line 88
uniform float Gamma_B <
ui_label = "Gamma (Blue)";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to blue.";
> = 1.0;
#line 98
uniform float Diffusion_1_Amount <
ui_label = "Diffusion 1 Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the amount of the first diffusion layer.";
> = 0.5;
#line 106
uniform float Diffusion_2_Amount <
ui_label = "Diffusion 2 Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the amount of the second diffusion layer.";
> = 0.5;
#line 114
uniform float Diffusion_3_Amount <
ui_label = "Diffusion 3 Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the amount of the third diffusion layer.";
> = 0.5;
#line 122
uniform int Diffusion_1_Radius <
ui_label = "Diffusion 1 Radius";
ui_type = "slider";
ui_min = 5;
ui_max = 20;
ui_tooltip = "Set the radius of the first diffusion layer.";
> = 8;
#line 130
uniform int Diffusion_2_Radius <
ui_label = "Diffusion 2 Radius";
ui_type = "slider";
ui_min = 5;
ui_max = 20;
ui_tooltip = "Set the radius of the second diffusion layer.";
> = 8;
#line 138
uniform int Diffusion_3_Radius <
ui_label = "Diffusion 3 Radius";
ui_type = "slider";
ui_min = 5;
ui_max = 20;
ui_tooltip = "Set the radius of the third diffusion layer.";
> = 8;
#line 146
uniform float Diffusion_1_Gamma <
ui_label = "Diffusion 1 Gamma";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to first diffusion layer.";
> = 2.2;
#line 154
uniform float Diffusion_2_Gamma <
ui_label = "Diffusion 2 Gamma";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to second diffusion layer.";
> = 1.3;
#line 162
uniform float Diffusion_3_Gamma <
ui_label = "Diffusion 3 Gamma";
ui_type = "slider";
ui_min = 0.02;
ui_max = 5.0;
ui_tooltip = "Apply Gamma to third diffusion layer.";
> = 1.0;
#line 172
uniform float Bleach_Bypass_Amount <
ui_label = "Bleach Bypass Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the amount of the third diffusion layer.";
> = 0.5;
#line 182
uniform float Dither_Amount <
ui_label = "Dither Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the amount of the dither on the diffusion layers (to smooth out banding).";
> = 0.15;
#line 192
uniform float Diffusion_1_Desaturate <
ui_label = "Diffusion 1 desaturation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the saturation of the first diffusion layer.";
> = 0.0;
#line 200
uniform float Diffusion_2_Desaturate <
ui_label = "Diffusion 2 desaturation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the saturation of the second diffusion layer.";
> = 0.5;
#line 208
uniform float Diffusion_3_Desaturate <
ui_label = "Diffusion 3 desaturation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the saturation of the third diffusion layer.";
> = 0.75;
#line 218
uniform float Diffusion_1_Quality <
ui_label = "Diffusion 1 sampling quality";
#line 223
ui_tooltip = "Set the quality of the first diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 2;
#line 226
uniform float Diffusion_2_Quality <
ui_label = "Diffusion 2 sampling quality";
#line 231
ui_tooltip = "Set the quality of the second diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 16;
#line 234
uniform float Diffusion_3_Quality <
ui_label = "Diffusion 3 sampling quality";
#line 239
ui_tooltip = "Set the quality of the third diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 64;
#line 247
texture NoiseTex <source = "hd_noise.png"; > { Width = 1920; Height = 1080; Format = RGBA8; };
sampler NoiseSampler { Texture = NoiseTex; };
#line 250
texture prePassLayer { Width = 1920; Height = 1080; Format = RGBA8; };
#line 252
texture blurLayerHorizontal { Width = 1920 / 2; Height = 1080 / 2; Format = RGBA8; };
texture blurLayerVertical { Width = 1920 / 2; Height = 1080 / 2; Format = RGBA8; };
texture blurLayerHorizontalMedRes { Width = 1920 / 16; Height = 1080 / 16; Format = RGBA8; };
texture blurLayerVerticalMedRes { Width = 1920 / 16; Height = 1080 / 16; Format = RGBA8; };
texture blurLayerHorizontalLoRes { Width = 1920 / 64; Height = 1080 / 64; Format = RGBA8; };
texture blurLayerVerticalLoRes { Width = 1920 / 64; Height = 1080 / 64; Format = RGBA8; };
#line 259
uniform float framecount < source = "framecount"; >;
#line 261
sampler2D PFX_PrePassLayer { Texture = prePassLayer; };
#line 264
sampler2D PFX_blurHorizontalLayer {	Texture = blurLayerHorizontal; };
sampler2D PFX_blurVerticalLayer { Texture = blurLayerVertical; };
sampler2D PFX_blurHorizontalLayerMedRes { Texture = blurLayerHorizontalMedRes; };
sampler2D PFX_blurVerticalLayerMedRes {	Texture = blurLayerVerticalMedRes; };
sampler2D PFX_blurHorizontalLayerLoRes { Texture = blurLayerHorizontalLoRes; };
sampler2D PFX_blurVerticalLayerLoRes { Texture = blurLayerVerticalLoRes; };
#line 272
float AdjustableSigmoidCurve (float value, float amount) {
#line 274
float curve = 1.0;
#line 276
if (value < 0.5)
{
curve = pow(value, amount) * pow(2.0, amount) * 0.5;
}
#line 281
else
{
curve = 1.0 - pow(abs(1.0 - value), amount) * pow(2.0, amount) * 0.5;
}
#line 286
return curve;
}
#line 289
float Randomize (float2 coord) {
return clamp((frac(sin(dot(coord, float2(12.9898, 78.233))) * 43758.5453)), 0.0, 1.0);
}
#line 293
float SigmoidCurve (float value) {
const value = value * 2.0 - 1.0;
return -value * abs(value) * 0.5 + value + 0.5;
}
#line 298
float SoftLightBlend (float A, float B) {
#line 300
if (A > 0.5)
{
return (2 * A - 1) * (sqrt(B) - B) + B;
}
#line 305
else
{
return (2 * A - 1) * (B - (B * 2)) + B;
}
#line 310
return 0;
}
#line 313
float4 BlurH (sampler input, float2 uv, float radius, float sampling) {
#line 316
float2 coordinate = float2(0.0, 0.0);
float4 A = float4(0.0, 0.0, 0.0, 1.0);
float4 C = float4(0.0, 0.0, 0.0, 1.0);
float weight = 1.0;
const float width = 1.0 / 1920 * sampling;
float divisor = 0.000001;
#line 323
for (float x = -radius; x <= radius; x++)
{
coordinate = uv + float2(x * width, 0.0);
coordinate = clamp(coordinate, 0.0, 1.0);
A = tex2Dlod(input, float4(coordinate, 0.0, 0.0));
weight = SigmoidCurve(1.0 - (abs(x) / radius));
C += A * weight;
divisor += weight;
}
#line 333
return C / divisor;
}
#line 336
float4 BlurV (sampler input, float2 uv, float radius, float sampling) {
#line 338
float2 coordinate = float2(0.0, 0.0);
float4 A = float4(0.0, 0.0, 0.0, 1.0);
float4 C = float4(0.0, 0.0, 0.0, 1.0);
float weight = 1.0;
const float height = 1.0 / 1080 * sampling;
float divisor = 0.000001;
#line 345
for (float y = -radius; y <= radius; y++)
{
coordinate = uv + float2(0.0, y * height);
coordinate = clamp(coordinate, 0.0, 1.0);
A = tex2Dlod(input, float4(coordinate, 0.0, 0.0));
weight = SigmoidCurve(1.0 - (abs(y) / radius));
C += A * weight;
divisor += weight;
}
#line 355
return C / divisor;
}
#line 359
void PS_PrePass (float4 pos : SV_Position,
float2 uv : TEXCOORD,
out float4 result : SV_Target)
{
#line 364
float4 A = tex2D(ReShade::BackBuffer, uv);
A.r = pow(abs(A.r), Gamma_R);
A.g = pow(abs(A.g), Gamma_G);
A.b = pow(abs(A.b), Gamma_B);
A.r = AdjustableSigmoidCurve(A.r, Contrast_R);
A.g = AdjustableSigmoidCurve(A.g, Contrast_G);
A.b = AdjustableSigmoidCurve(A.b, Contrast_B);
#line 374
A.g = A.g * 0.8 + A.b * 0.2;
#line 376
float red = A.r - A.g - A.b;
float green = A.g - A.r - A.b;
float blue = A.b - A.r - A.g;
#line 380
red = clamp(red, 0.0, 1.0);
green = clamp(green, 0.0, 1.0);
blue = clamp(blue, 0.0, 1.0);
#line 384
A = A * (1.0 - red * 0.6);
A = A * (1.0 - green * 0.8);
A = A * (1.0 - blue * 0.3);
#line 391
result = A;
}
#line 395
void PS_HorizontalPass (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurH(PFX_PrePassLayer, uv, Diffusion_1_Radius, Diffusion_1_Quality);
#line 400
}
#line 402
void PS_VerticalPass (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurV(PFX_blurHorizontalLayer, uv, Diffusion_1_Radius, Diffusion_1_Quality);
}
#line 408
void PS_HorizontalPassMedRes (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurH(PFX_blurVerticalLayer, uv, Diffusion_2_Radius, Diffusion_2_Quality);
}
#line 414
void PS_VerticalPassMedRes (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurV(PFX_blurHorizontalLayerMedRes, uv, Diffusion_2_Radius, Diffusion_2_Quality);
}
#line 420
void PS_HorizontalPassLoRes (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurH(PFX_blurVerticalLayerMedRes, uv, Diffusion_3_Radius, Diffusion_3_Quality);
}
#line 426
void PS_VerticalPassLoRes (float4 pos : SV_Position,
float2 uv : TEXCOORD, out float4 result : SV_Target)
{
result = BlurV(PFX_blurHorizontalLayerLoRes, uv, Diffusion_3_Radius, Diffusion_3_Quality);
}
#line 435
float4 PandaComposition (float4 vpos : SV_Position,
float2 uv : TEXCOORD) : SV_Target
{
#line 440
float4 blurLayer;
float4 blurLayerMedRes;
float4 blurLayerLoRes;
#line 444
if (Enable_Diffusion)
{
#line 447
blurLayer = tex2D(PFX_blurVerticalLayer, uv);
blurLayerMedRes = tex2D(PFX_blurVerticalLayerMedRes, uv);
blurLayerLoRes = tex2D(PFX_blurVerticalLayerLoRes, uv);
#line 454
const float4 blurLayerGray = dot(0.3333, blurLayer.rgb);
blurLayer = lerp(blurLayer, blurLayerGray, Diffusion_2_Desaturate);
#line 457
const float4 blurLayerMedResGray = dot(0.3333, blurLayerMedRes.rgb);
blurLayerMedRes = lerp(blurLayerMedRes, blurLayerMedResGray, Diffusion_2_Desaturate);
#line 460
const float4 blurLayerLoResGray = dot(0.3333, blurLayerLoRes.rgb);
blurLayerLoRes = lerp(blurLayerLoRes, blurLayerLoResGray, Diffusion_3_Desaturate);
#line 472
blurLayer *= Diffusion_1_Amount;
blurLayerMedRes *= Diffusion_2_Amount;
blurLayerLoRes *= Diffusion_3_Amount;
#line 476
blurLayer = pow(abs(blurLayer), Diffusion_1_Gamma);
blurLayerMedRes = pow(abs(blurLayerMedRes), Diffusion_2_Gamma);
blurLayerLoRes = pow(abs(blurLayerLoRes), Diffusion_3_Gamma);
}
#line 484
float4 A = tex2D(PFX_PrePassLayer, uv);
const float4 O = tex2D(ReShade::BackBuffer, uv);
#line 489
if (Enable_Diffusion)
{
blurLayer = clamp(blurLayer, 0.0, 1.0);
blurLayerMedRes = clamp(blurLayerMedRes, 0.0, 1.0);
blurLayerLoRes = clamp(blurLayerLoRes, 0.0, 1.0);
#line 495
A.rgb = 1.0 - (1.0 - blurLayer.rgb) * (1.0 - A.rgb);
A.rgb = 1.0 - (1.0 - blurLayerMedRes.rgb) * (1.0 - A.rgb);
A.rgb = 1.0 - (1.0 - blurLayerLoRes.rgb) * (1.0 - A.rgb);
}
#line 503
if (Enable_Bleach_Bypass)
{
float Ag = dot(float3(0.3333, 0.3333, 0.3333), A.rgb);
float4 B = A;
float4 C = 0;
#line 509
if (Ag > 0.5)
{
C = 1 - 2 * (1 - Ag) * (1 - B);
}
#line 514
else
{
C = 2 * Ag * B;
}
#line 519
C = pow(abs(C), 0.6);
A = lerp(A, C, Bleach_Bypass_Amount);
}
#line 526
if (Enable_Dither)
{
float4 rndSample = tex2D(NoiseSampler, uv);
float uvRnd = Randomize(rndSample.xy * framecount);
float uvRnd2 = Randomize(-rndSample.xy * framecount);
#line 532
float4 Nt = tex2D(NoiseSampler, uv * uvRnd);
float4 Nt2 = tex2D(NoiseSampler, uv * uvRnd2);
float4 Nt3 = tex2D(NoiseSampler, -uv * uvRnd);
#line 536
float3 noise = float3(Nt.x, Nt2.x, Nt3.x);
#line 538
float4 B = A;
#line 540
B.r = SoftLightBlend(noise.r, A.r);
B.g = SoftLightBlend(noise.g, A.g);
B.b = SoftLightBlend(noise.b, A.b);
#line 544
A = lerp(A, B, Dither_Amount);
}
#line 551
return lerp(O, A, Blend_Amount);
}
#line 554
technique PandaFX
{
pass PreProcess
{
VertexShader = PostProcessVS;
PixelShader = PS_PrePass;
RenderTarget = prePassLayer;
}
#line 563
pass HorizontalPass
{
VertexShader = PostProcessVS;
PixelShader = PS_HorizontalPass;
RenderTarget = blurLayerHorizontal;
}
#line 570
pass VerticalPass
{
VertexShader = PostProcessVS;
PixelShader = PS_VerticalPass;
RenderTarget = blurLayerVertical;
}
#line 577
pass HorizontalPassMedRes
{
VertexShader = PostProcessVS;
PixelShader = PS_HorizontalPassMedRes;
RenderTarget = blurLayerHorizontalMedRes;
}
#line 584
pass VerticalPassMedRes
{
VertexShader = PostProcessVS;
PixelShader = PS_VerticalPassMedRes;
RenderTarget = blurLayerVerticalMedRes;
}
#line 591
pass HorizontalPassLoRes
{
VertexShader = PostProcessVS;
PixelShader = PS_HorizontalPassLoRes;
RenderTarget = blurLayerHorizontalLoRes;
}
#line 598
pass VerticalPassLoRes
{
VertexShader = PostProcessVS;
PixelShader = PS_VerticalPassLoRes;
RenderTarget = blurLayerVerticalLoRes;
}
#line 605
pass CustomPass
{
VertexShader = PostProcessVS;
PixelShader = PandaComposition ;
}
}

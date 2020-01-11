#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FilmicPass.fx"
#line 8
uniform float Strength <
ui_type = "slider";
ui_min = 0.05; ui_max = 1.5;
ui_toolip = "Strength of the color curve altering";
> = 0.85;
#line 14
uniform float Fade <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.6;
ui_tooltip = "Decreases contrast to imitate faded image";
> = 0.4;
uniform float Contrast <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
> = 1.0;
uniform float Linearization <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
> = 0.5;
uniform float Bleach <
ui_type = "slider";
ui_min = -0.5; ui_max = 1.0;
ui_tooltip = "More bleach means more contrasted and less colorful image";
> = 0.0;
uniform float Saturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
> = -0.15;
#line 37
uniform float RedCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform float GreenCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform float BlueCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform float BaseCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.5;
#line 54
uniform float BaseGamma <
ui_type = "slider";
ui_min = 0.7; ui_max = 2.0;
ui_tooltip = "Gamma Curve";
> = 1.0;
uniform float EffectGamma <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 0.65;
uniform float EffectGammaR <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform float EffectGammaG <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform float EffectGammaB <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
#line 76
uniform float3 LumCoeff <
> = float3(0.212656, 0.715158, 0.072186);
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FilmicPass.fx"
#line 81
float3 FilmPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 B = lerp(0.01, pow(saturate(tex2D(ReShade::BackBuffer, texcoord).rgb), Linearization), Contrast);
#line 85
float3 D = dot(B.rgb, LumCoeff);
#line 87
B = pow(abs(B), 1.0 / BaseGamma);
#line 89
const float y = 1.0 / (1.0 + exp(RedCurve / 2.0));
const float z = 1.0 / (1.0 + exp(GreenCurve / 2.0));
const float w = 1.0 / (1.0 + exp(BlueCurve / 2.0));
const float v = 1.0 / (1.0 + exp(BaseCurve / 2.0));
#line 94
float3 C = B;
#line 96
D.r = (1.0 / (1.0 + exp(-RedCurve * (D.r - 0.5))) - y) / (1.0 - 2.0 * y);
D.g = (1.0 / (1.0 + exp(-GreenCurve * (D.g - 0.5))) - z) / (1.0 - 2.0 * z);
D.b = (1.0 / (1.0 + exp(-BlueCurve * (D.b - 0.5))) - w) / (1.0 - 2.0 * w);
#line 100
D = pow(abs(D), 1.0 / EffectGamma);
#line 102
D = lerp(D, 1.0 - D, Bleach);
#line 104
D.r = pow(abs(D.r), 1.0 / EffectGammaR);
D.g = pow(abs(D.g), 1.0 / EffectGammaG);
D.b = pow(abs(D.b), 1.0 / EffectGammaB);
#line 108
if (D.r < 0.5)
C.r = (2.0 * D.r - 1.0) * (B.r - B.r * B.r) + B.r;
else
C.r = (2.0 * D.r - 1.0) * (sqrt(B.r) - B.r) + B.r;
#line 113
if (D.g < 0.5)
C.g = (2.0 * D.g - 1.0) * (B.g - B.g * B.g) + B.g;
else
C.g = (2.0 * D.g - 1.0) * (sqrt(B.g) - B.g) + B.g;
#line 118
if (D.b < 0.5)
C.b = (2.0 * D.b - 1.0) * (B.b - B.b * B.b) + B.b;
else
C.b = (2.0 * D.b - 1.0) * (sqrt(B.b) - B.b) + B.b;
#line 123
float3 F = (1.0 / (1.0 + exp(-BaseCurve * (lerp(B, C, Strength) - 0.5))) - v) / (1.0 - 2.0 * v);
#line 125
const float3 iF = F;
#line 127
F.r = (iF.r * (1.0 - Saturation) + iF.g * (0.0 + Saturation) + iF.b * Saturation);
F.g = (iF.r * Saturation + iF.g * ((1.0 - Fade) - Saturation) + iF.b * (Fade + Saturation));
F.b = (iF.r * Saturation + iF.g * (Fade + Saturation) + iF.b * ((1.0 - Fade) - Saturation));
#line 131
const float N = dot(F.rgb, LumCoeff);
#line 133
float3 Cn;
if (N < 0.5)
Cn = (2.0 * N - 1.0) * (F - F * F) + F;
else
Cn = (2.0 * N - 1.0) * (sqrt(F) - F) + F;
#line 139
return lerp(B, pow(max(Cn,0), 1.0 / Linearization), Strength);
}
#line 142
technique FilmicPass
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FilmPass;
}
}

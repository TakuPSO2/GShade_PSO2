#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ImageSharpening.fx"
#line 5
uniform float g_sldSharpen <
ui_type = "slider";
ui_min = 0.000; ui_max=1.000;
ui_label = "Sharpen";
ui_tooltip = "Increase to sharpen details within the image.";
ui_step = 0.001;
> = 0.5;
#line 13
uniform float g_sldDenoise <
ui_type = "slider";
ui_min = 0.000; ui_max=1.000;
ui_label = "Ignore Film Grain";
ui_tooltip = "Increase to limit how intensely film grain within the image gets sharpened.";
ui_step = 0.001;
> = 0.17;
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ReShade.fxh"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ImageSharpening.fx"
#line 23
float GetLuma(float r, float g, float b)
{
#line 26
return 0.299f * r + 0.587f * g + 0.114f * b;
}
#line 29
float GetLuma(float4 p)
{
return GetLuma(p.x, p.y, p.z);
}
#line 34
float Square(float v)
{
return v * v;
}
#line 48
void PS_ImageSharpening(in float4 i_pos : SV_POSITION, in float2 i_uv : TEXCOORD, out float4 x : SV_Target)
{
x = tex2D(ReShade::BackBuffer, i_uv);
#line 52
const float lx = GetLuma(x);
#line 54
const float la = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(-1, 0)));
const float lb = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(1, 0)));
const float lc = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(0, 1)));
const float ld = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(0, -1)));
#line 59
const float le = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(-1, -1)));
const float lf = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(1, 1)));
const float lg = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(-1, 1)));
const float lh = GetLuma(tex2Doffset(ReShade::BackBuffer, i_uv, int2(1, -1)));
#line 65
const float ncmin = min(min(le, lf), min(lg, lh));
const float ncmax = max(max(le, lf), max(lg, lh));
#line 69
const float npmin = min(min(min(la, lb), min(lc, ld)), lx);
const float npmax = max(max(max(la, lb), max(lc, ld)), lx);
#line 73
const float lmin = 0.5f * min(ncmin, npmin) + 0.5f * npmin;
const float lmax = 0.5f * max(ncmax, npmax) + 0.5f * npmax;
#line 85
const float nw = Square((lmax - lmin) * (1.0f / ((0.001f) + ((-0.1f) - (0.001f)) * min(max(g_sldDenoise, 0.0f), 1.0f))));
#line 88
const float boost = min(min(lmin / (lmax + (1.0f / 256.0f)), Square(1.0f - Square(max(lmax - 0.65f, 0.0f) / ((1.0f - 0.65f))))), nw);
#line 99
const float k = boost * ((-1.0f / 14.0f) + ((-1.0f / 6.5f) - (-1.0f / 14.0f)) * min(max(g_sldSharpen, 0.0f), 1.0f));
#line 101
float accum = lx;
accum += la * k;
accum += lb * k;
accum += lc * k;
accum += ld * k;
accum += le * (k * 0.5f);
accum += lf * (k * 0.5f);
accum += lg * (k * 0.5f);
accum += lh * (k * 0.5f);
#line 112
accum /= 1.0f + 6.0f * k;
#line 115
float delta = accum - GetLuma(x);
x.x += delta;
x.y += delta;
x.z += delta;
}
#line 121
technique ImageSharpening
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_ImageSharpening;
}
}

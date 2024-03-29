#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_sharp.fx"
#line 27
uniform float SHARP_STRENGTH <
ui_type = "slider";
ui_label = "Sharpen Strength";
ui_min = 0.0;
ui_max = 1.0;
> = 0.7;
#line 34
uniform bool DEPTH_MASK_ENABLE <
ui_label = "Use Depth Mask";
> = true;
#line 38
uniform bool RMS_MASK_ENABLE <
ui_label = "Use Local Contrast Enhancer";
> = true;
#line 42
uniform int SHARPEN_MODE <
ui_type = "radio";
ui_label = "Sharpen Mode";
ui_category = "Sharpen Mode";
ui_items = "Chroma\0Luma\0";
> = 1;
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_common.fxh"
#line 58
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 63
static const float2 ASPECT_RATIO 	= float2(1.0, 1920 * (1.0 / 1080));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1920), (1.0 / 1080));
static const float2 SCREEN_SIZE 	= float2(1920, 1080);
#line 68
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 71
sampler sBackBufferTex 	{ Texture = BackBufferTex; 	};
sampler sDepthBufferTex { Texture = DepthBufferTex; };
#line 75
float linear_depth(float2 uv)
{
#line 80
float depth = tex2Dlod(sDepthBufferTex, float4(uv, 0, 0)).x;
#line 89
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 92
return saturate(depth);
}
}
#line 97
void PostProcessVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_sharp.fx"
#line 102
}
#line 60
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
#line 66
VSOUT VS_Sharp(in uint id : SV_VertexID)
{
VSOUT o;
#line 70
o.uv.x = (id == 2) ? 2.0 : 0.0;
o.uv.y = (id == 1) ? 2.0 : 0.0;
#line 73
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return o;
}
#line 81
float color_to_lum(float3 color)
{
return dot(color, float3(0.3, 0.59, 0.11));
}
#line 86
float3 blend_overlay(float3 a, float3 b)
{
float3 c = 1.0 - a;
float3 d = 1.0 - b;
#line 91
return a < 0.5 ? (2.0 * a * b) : (1.0 - 2.0 * c * d);
}
#line 94
float4 fetch_color_and_depth(float2 uv)
{
return float4( tex2D(qUINT::sBackBufferTex, uv).rgb,
qUINT::linear_depth(uv));
}
#line 104
void PS_Sharp(in VSOUT i, out float3 o : SV_Target0)
{
#line 110
float4 A, B, C, D, E, F, G, H, I;
#line 112
float3 offsets = float3(1, 0, -1);
#line 114
A = fetch_color_and_depth(i.uv + offsets.zz * qUINT::PIXEL_SIZE);
B = fetch_color_and_depth(i.uv + offsets.yz * qUINT::PIXEL_SIZE);
C = fetch_color_and_depth(i.uv + offsets.xz * qUINT::PIXEL_SIZE);
D = fetch_color_and_depth(i.uv + offsets.zy * qUINT::PIXEL_SIZE);
E = fetch_color_and_depth(i.uv + offsets.yy * qUINT::PIXEL_SIZE);
F = fetch_color_and_depth(i.uv + offsets.xy * qUINT::PIXEL_SIZE);
G = fetch_color_and_depth(i.uv + offsets.zx * qUINT::PIXEL_SIZE);
H = fetch_color_and_depth(i.uv + offsets.yx * qUINT::PIXEL_SIZE);
I = fetch_color_and_depth(i.uv + offsets.xx * qUINT::PIXEL_SIZE);
#line 124
float4 corners = (A + C) + (G + I);
float4 neighbours = (B + D) + (F + H);
float4 center = E;
#line 128
float4 edge = corners + 2.0 * neighbours - 12.0 * center;
float3 sharpen = edge.rgb;
#line 135
if(RMS_MASK_ENABLE)
{
float3 mean = (corners.rgb + neighbours.rgb + center.rgb) / 9.0;
float3 RMS = (mean - A.rgb) * (mean - A.rgb);
RMS += (mean - B.rgb) * (mean - B.rgb);
RMS += (mean - C.rgb) * (mean - C.rgb);
RMS += (mean - D.rgb) * (mean - D.rgb);
RMS += (mean - E.rgb) * (mean - E.rgb);
RMS += (mean - F.rgb) * (mean - F.rgb);
RMS += (mean - G.rgb) * (mean - G.rgb);
RMS += (mean - H.rgb) * (mean - H.rgb);
RMS += (mean - I.rgb) * (mean - I.rgb);
#line 149
sharpen *= rsqrt(RMS + 0.001) * 0.1;
}
#line 155
sharpen *= DEPTH_MASK_ENABLE ? saturate(1.0 - abs(edge.w) * 4000.0) : 1;
#line 159
if(SHARPEN_MODE == 1)
sharpen = color_to_lum(sharpen);
#line 162
sharpen = -sharpen * SHARP_STRENGTH * 0.1;
#line 164
sharpen = sign(sharpen) * log(abs(sharpen) * 10.0 + 1.0)*0.3;
#line 166
o = blend_overlay(center.rgb, (0.5 + sharpen));
}
#line 175
technique DELC_Sharpen
< ui_tooltip = "                     >> qUINT::DELCS <<\n\n"
"DELCS is an advanced sharpen filter made to enhance texture detail.\n"
"It offers a local contrast detection method and allows to suppress\n"
"oversharpening on depth edges to combat common sharpen artifacts.\n"
"get access to more functionality.\n"
"\nDELCS is best positioned after most shaders but before film grain or such.\n"
"\DELCS is written by Marty McFly / Pascal Gilcher"; >
{
pass
{
VertexShader = VS_Sharp;
PixelShader  = PS_Sharp;
}
}

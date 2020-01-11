#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Posterize.fx"
#line 23
uniform float ZEBRA_INTENSITY <
ui_type = "slider";
ui_label = "Zebra Lines Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
#line 30
uniform float3 PALETTE_COLOR_1 <
ui_type = "color";
ui_label = "Color 1";
> = float3(1/255.0, 48/255.0, 74/255.0);
#line 35
uniform float3 PALETTE_COLOR_2 <
ui_type = "color";
ui_label = "Color 2";
> = float3(219/255.0, 33/255.0, 38/255.0);
#line 40
uniform float3 PALETTE_COLOR_3 <
ui_type = "color";
ui_label = "Color 3";
> = float3(113/255.0, 153/255.0, 165/255.0);
#line 45
uniform float3 PALETTE_COLOR_4 <
ui_type = "color";
ui_label = "Color 4";
> = float3(255/255.0, 250/255.0, 182/255.0);
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Posterize.fx"
#line 102
}
#line 61
struct VSOUT
{
float4   vpos        : SV_Position;
float2   uv          : TEXCOORD0;
};
#line 67
VSOUT VS_Paint(in uint id : SV_VertexID)
{
VSOUT o;
o.uv.x = (id == 2) ? 2.0 : 0.0;
o.uv.y = (id == 1) ? 2.0 : 0.0;
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return o;
}
#line 80
float3 paint_filter(in VSOUT i, in float pass_id)
{
float3 least_divergent = 0;
float3 total_sum = 0;
float min_divergence = 1e10;
#line 86
[loop]
for(int j = 0; j < 5; j++)
{
float2 dir; sincos(radians(180.0 * (j + pass_id / 4) / 5), dir.y, dir.x);
#line 91
float3 col_avg_per_dir = 0;
float curr_divergence = 0;
#line 94
float3 col_prev = tex2Dlod(qUINT::sBackBufferTex, float4(i.uv.xy - dir * 4 * qUINT::PIXEL_SIZE, 0, 0)).rgb;
#line 96
for(int k = -4 + 1; k <= 4; k++)
{
float3 col_curr = tex2Dlod(qUINT::sBackBufferTex, float4(i.uv.xy + dir * k * qUINT::PIXEL_SIZE, 0, 0)).rgb;
col_avg_per_dir += col_curr;
#line 101
const float3 color_diff = abs(col_curr - col_prev);
#line 103
curr_divergence += max(max(color_diff.x, color_diff.y), color_diff.z);
col_prev = col_curr;
}
#line 107
[flatten]
if(curr_divergence < min_divergence)
{
least_divergent = col_avg_per_dir;
min_divergence = curr_divergence;
}
#line 114
total_sum += col_avg_per_dir;
}
#line 117
least_divergent /= 2 * 4;
total_sum /= 2 * 4 * 5;
min_divergence /= 2 * 4;
#line 121
float lumasharpen = dot(least_divergent - total_sum, 0.333);
least_divergent += lumasharpen * 0.7;
#line 124
least_divergent *= saturate(1 - min_divergence * 0);
return least_divergent;
}
#line 132
void PS_Paint_1(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 1);
o.w = 1;
}
#line 138
void PS_Paint_2(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 2);
o.w = 1;
}
#line 144
void PS_Paint_3(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 3);
o.w = 1;
}
#line 150
void PS_Paint_4(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 4);
o.w = 1;
}
#line 156
void PS_Paint_5(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 5);
o.w = 1;
}
#line 162
void PS_Posterize(in VSOUT i, out float4 o : SV_Target0)
{
const bool zebra = frac(i.vpos.y * 0.125) > 0.5;
#line 166
int posterized = round(dot(tex2D(qUINT::sBackBufferTex, i.uv).rgb, float3(0.3, 0.59, 0.11)) * 3 + (zebra - 0.5) * ZEBRA_INTENSITY * 0.2);
posterized = clamp(posterized, 0, 3);
#line 169
const float3 palette[4] =
{
PALETTE_COLOR_1,
PALETTE_COLOR_2,
PALETTE_COLOR_3,
PALETTE_COLOR_4
};
#line 177
o = palette[posterized];
#line 180
}
#line 186
technique Posterize
{
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_1;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_2;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_3;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_4;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Posterize;
}
}

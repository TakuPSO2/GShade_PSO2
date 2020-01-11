#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Deband.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Deband.fx"
#line 47
uniform int threshold_preset <
ui_type = "combo";
ui_label = "Debanding strength";
ui_items = "Low\0Medium\0High\0Custom\0";
ui_tooltip = "Debanding presets. Use Custom to be able to use custom thresholds in the advanced section.";
> = 3;
#line 54
uniform float Range <
ui_type = "slider";
ui_min = 1.0;
ui_max = 128.0;
ui_step = 1.0;
ui_label = "Initial radius";
ui_tooltip = "The radius increases linearly for each iteration. A higher radius will find more gradients, but a lower radius will smooth more aggressively.";
> = 128.0;
#line 63
uniform int Iterations <
ui_type = "slider";
ui_min = 1;
ui_max = 16;
ui_label = "Iterations";
ui_tooltip = "The number of debanding steps to perform per sample. Each step reduces a bit more banding, but takes time to compute.";
> = 1;
#line 71
uniform float custom_avgdiff <
ui_type = "slider";
ui_min = 0.0;
ui_max = 255.0;
ui_step = 0.1;
ui_label = "Average threshold";
ui_tooltip = "Threshold for the difference between the average of reference pixel values and the original pixel value. Higher numbers increase the debanding strength but progressively diminish image details. In pixel shaders a 8-bit color step equals to 1.0/255.0";
ui_category = "Advanced";
> = 255.0;
#line 81
uniform float custom_maxdiff <
ui_type = "slider";
ui_min = 0.0;
ui_max = 255.0;
ui_step = 0.1;
ui_label = "Maximum threshold";
ui_tooltip = "Threshold for the difference between the maximum difference of one of the reference pixel values and the original pixel value. Higher numbers increase the debanding strength but progressively diminish image details. In pixel shaders a 8-bit color step equals to 1.0/255.0";
ui_category = "Advanced";
> = 10.0;
#line 91
uniform float custom_middiff <
ui_type = "slider";
ui_min = 0.0;
ui_max = 255.0;
ui_step = 0.1;
ui_label = "Middle threshold";
ui_tooltip = "Threshold for the difference between the average of diagonal reference pixel values and the original pixel value. Higher numbers increase the debanding strength but progressively diminish image details. In pixel shaders a 8-bit color step equals to 1.0/255.0";
ui_category = "Advanced";
> = 255.0;
#line 101
uniform bool debug_output <
ui_label = "Debug view";
ui_tooltip = "Shows the low-pass filtered (blurred) output. Could be useful when making sure that range and iterations capture all of the banding in the picture.";
ui_category = "Advanced";
> = false;
#line 108
uniform float drandom < source = "random"; min = 0; max = 32767.0; >;
#line 110
float rand(float x)
{
return frac(x / 41.0);
}
#line 115
float permute(float x)
{
return ((34.0 * x + 1.0) * x) % 289.0;
}
#line 120
void analyze_pixels(float3 ori, sampler2D tex, float2 texcoord, float2 _range, float2 dir, out float3 ref_avg, out float3 ref_avg_diff, out float3 ref_max_diff, out float3 ref_mid_diff1, out float3 ref_mid_diff2)
{
#line 125
float3 ref = tex2Dlod(tex, float4(texcoord + _range * dir, 0.0, 0.0)).rgb;
float3 diff = abs(ori - ref);
ref_max_diff = diff;
ref_avg = ref;
ref_mid_diff1 = ref;
#line 132
ref = tex2Dlod(tex, float4(texcoord + _range * -dir, 0.0, 0.0)).rgb;
diff = abs(ori - ref);
ref_max_diff = max(ref_max_diff, diff);
ref_avg += ref;
ref_mid_diff1 = abs(((ref_mid_diff1 + ref) * 0.5) - ori);
#line 139
ref = tex2Dlod(tex, float4(texcoord + _range * float2(-dir.y, dir.x), 0.0, 0.0)).rgb;
diff = abs(ori - ref);
ref_max_diff = max(ref_max_diff, diff);
ref_avg += ref;
ref_mid_diff2 = ref;
#line 146
ref = tex2Dlod(tex, float4(texcoord + _range * float2( dir.y, -dir.x), 0.0, 0.0)).rgb;
diff = abs(ori - ref);
ref_max_diff = max(ref_max_diff, diff);
ref_avg += ref;
ref_mid_diff2 = abs(((ref_mid_diff2 + ref) * 0.5) - ori);
#line 152
ref_avg *= 0.25; 
ref_avg_diff = abs(ori - ref_avg);
}
#line 156
float3 PS_Deband(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 160
float avgdiff;
float maxdiff;
float middiff;
#line 164
if (threshold_preset == 0) {
avgdiff = 0.6;
maxdiff = 1.9;
middiff = 1.2;
}
else if (threshold_preset == 1) {
avgdiff = 1.8;
maxdiff = 4.0;
middiff = 2.0;
}
else if (threshold_preset == 2) {
avgdiff = 3.4;
maxdiff = 6.8;
middiff = 3.3;
}
else if (threshold_preset == 3) {
avgdiff = custom_avgdiff;
maxdiff = custom_maxdiff;
middiff = custom_middiff;
}
#line 186
avgdiff /= 255.0;
maxdiff /= 255.0;
middiff /= 255.0;
#line 191
float h = permute(permute(permute(texcoord.x) + texcoord.y) + drandom / 32767.0);
#line 193
float3 ref_avg; 
float3 ref_avg_diff; 
float3 ref_max_diff; 
float3 ref_mid_diff1; 
float3 ref_mid_diff2; 
#line 199
const float3 ori = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb; 
float3 res; 
#line 203
const float dir  = rand(permute(h)) * 6.2831853;
const float2 o = float2(cos(dir), sin(dir));
#line 206
for (int i = 1; i <= Iterations; ++i) {
#line 208
const float dist = rand(h) * Range * i;
const float2 pt = dist * ReShade::PixelSize;
#line 211
analyze_pixels(ori, ReShade::BackBuffer, texcoord, pt, o,
ref_avg,
ref_avg_diff,
ref_max_diff,
ref_mid_diff1,
ref_mid_diff2);
#line 218
const float3 ref_avg_diff_threshold = avgdiff * i;
const float3 ref_max_diff_threshold = maxdiff * i;
const float3 ref_mid_diff_threshold = middiff * i;
#line 223
const float3 factor = pow(saturate(3.0 * (1.0 - ref_avg_diff  / ref_avg_diff_threshold)) *
saturate(3.0 * (1.0 - ref_max_diff  / ref_max_diff_threshold)) *
saturate(3.0 * (1.0 - ref_mid_diff1 / ref_mid_diff_threshold)) *
saturate(3.0 * (1.0 - ref_mid_diff2 / ref_mid_diff_threshold)), 0.1);
#line 228
if (debug_output)
res = ref_avg;
else
res = lerp(ori, ref_avg, factor);
#line 233
h = permute(h);
}
#line 236
const float dither_bit = 8.0; 
#line 242
const float grid_position = frac(dot(texcoord, (ReShade::ScreenSize * float2(1.0 / 16.0, 10.0 / 36.0)) + 0.25));
#line 245
const float dither_shift = 0.25 * (1.0 / (pow(2, dither_bit) - 1.0));
#line 248
float3 dither_shift_RGB = float3(dither_shift, -dither_shift, dither_shift); 
#line 251
dither_shift_RGB = lerp(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position); 
#line 254
res += dither_shift_RGB;
#line 256
return res;
}
#line 259
technique Deband <
ui_tooltip = "Alleviates color banding by trying to approximate original color values.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Deband;
}
}

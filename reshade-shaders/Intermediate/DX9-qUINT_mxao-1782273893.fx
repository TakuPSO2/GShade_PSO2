#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_mxao.fx"
#line 50
uniform int qMXAO_GLOBAL_SAMPLE_QUALITY_PRESET <
ui_type = "combo";
ui_label = "Sample Quality";
ui_items = "Very Low  (4 samples)\0Low       (8 samples)\0Medium    (16 samples)\0High      (24 samples)\0Very High (32 samples)\0Ultra     (64 samples)\0Maximum   (255 samples)\0Auto      (variable)\0";
ui_tooltip = "Global quality control, main performance knob. Higher radii might require higher quality.";
ui_category = "Global";
> = 2;
#line 58
uniform float qMXAO_SAMPLE_RADIUS <
ui_type = "slider";
ui_min = 0.5; ui_max = 20.0;
ui_label = "Sample Radius";
ui_tooltip = "Sample radius of MXAO, higher means more large-scale occlusion with less fine-scale details.";
ui_category = "Global";
> = 2.5;
#line 67
uniform float qMXAO_SAMPLE_NORMAL_BIAS <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.8;
ui_label = "Normal Bias";
ui_tooltip = "Occlusion Cone bias to reduce self-occlusion of surfaces that have a low angle to each other.";
ui_category = "Global";
> = 0.2;
#line 78
uniform float qMXAO_GLOBAL_RENDER_SCALE <
ui_type = "slider";
ui_label = "Render Size Scale";
ui_min = 0.50; ui_max = 1.00;
ui_tooltip = "Factor of MXAO resolution, lower values greatly reduce performance overhead but decrease quality.\n1.0 = MXAO is computed in original resolution\n0.5 = MXAO is computed in 1/2 width 1/2 height of original resolution\n...";
ui_category = "Global";
> = 1.0;
#line 86
uniform float qMXAO_SSAO_AMOUNT <
ui_type = "slider";
ui_min = 0.00; ui_max = 4.00;
ui_label = "Ambient Occlusion Amount";
ui_tooltip = "Intensity of AO effect. Can cause pitch black clipping if set too high.";
ui_category = "Ambient Occlusion";
> = 1.00;
#line 113
uniform float qMXAO_SAMPLE_RADIUS_SECONDARY <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.00;
ui_label = "Fine AO Scale";
ui_tooltip = "Multiplier of Sample Radius for fine geometry. A setting of 0.5 scans the geometry at half the radius of the main AO.";
ui_category = "Double Layer";
> = 0.2;
#line 121
uniform float qMXAO_AMOUNT_FINE <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Fine AO intensity multiplier";
ui_tooltip = "Intensity of small scale AO / IL.";
ui_category = "Double Layer";
> = 1.0;
#line 129
uniform float qMXAO_AMOUNT_COARSE <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Coarse AO intensity multiplier";
ui_tooltip = "Intensity of large scale AO / IL.";
ui_category = "Double Layer";
> = 1.0;
#line 138
uniform int qMXAO_BLEND_TYPE <
ui_type = "slider";
ui_min = 0; ui_max = 3;
ui_label = "Blending Mode";
ui_tooltip = "Different blending modes for merging AO/IL with original color.\0Blending mode 0 matches formula of MXAO 2.0 and older.";
ui_category = "Blending";
> = 0;
#line 146
uniform float qMXAO_FADE_DEPTH_START <
ui_type = "slider";
ui_label = "Fade Out Start";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO starts to fade out. 0.0 = camera, 1.0 = sky. Must be less than Fade Out End.";
ui_category = "Blending";
> = 0.05;
#line 154
uniform float qMXAO_FADE_DEPTH_END <
ui_type = "slider";
ui_label = "Fade Out End";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO completely fades out. 0.0 = camera, 1.0 = sky. Must be greater than Fade Out Start.";
ui_category = "Blending";
> = 0.4;
#line 162
uniform int qMXAO_DEBUG_VIEW_ENABLE <
ui_type = "combo";
ui_label = "Enable Debug View";
ui_items = "None\0AO/IL channel\0Normal vectors\0";
ui_tooltip = "Different debug outputs";
ui_category = "Debug";
> = 0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_mxao.fx"
#line 102
}
#line 177
texture2D qMXAO_ColorTex 	{ Width = 1920;   Height = 1080;   Format = RGBA8; MipLevels = 3+2	;};
texture2D qMXAO_DepthTex 	{ Width = 1920;   Height = 1080;   Format = R16F;  MipLevels = 3+0	;};
texture2D qMXAO_NormalTex	{ Width = 1920;   Height = 1080;   Format = RGBA8; MipLevels = 3+2	;};
#line 181
sampler2D sMXAO_ColorTex	{ Texture = qMXAO_ColorTex;	};
sampler2D sMXAO_DepthTex	{ Texture = qMXAO_DepthTex;	};
sampler2D sMXAO_NormalTex	{ Texture = qMXAO_NormalTex;	};
#line 185
texture2D CommonTex0 	{ Width = 1920;   Height = 1080;   Format = RGBA8; };
sampler2D sCommonTex0	{ Texture = CommonTex0;	};
#line 188
texture2D CommonTex1 	{ Width = 1920;   Height = 1080;   Format = RGBA8; };
sampler2D sCommonTex1	{ Texture = CommonTex1;	};
#line 201
struct qMXAO_VSOUT
{
float4                  vpos        : SV_Position;
float4                  uv          : TEXCOORD0;
nointerpolation float   samples     : TEXCOORD1;
nointerpolation float3  uvtoviewADD : TEXCOORD4;
nointerpolation float3  uvtoviewMUL : TEXCOORD5;
};
#line 210
struct BlurData
{
float4 key;
float4 mask;
};
#line 216
qMXAO_VSOUT VS_qMXAO(in uint id : SV_VertexID)
{
qMXAO_VSOUT MXAO;
#line 220
MXAO.uv.x = (id == 2) ? 2.0 : 0.0;
MXAO.uv.y = (id == 1) ? 2.0 : 0.0;
MXAO.uv.zw = MXAO.uv.xy / qMXAO_GLOBAL_RENDER_SCALE;
MXAO.vpos = float4(MXAO.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 225
static const int samples_per_preset[8] = {4, 8, 16, 24, 32, 64, 255, 8 };
MXAO.samples   = samples_per_preset[qMXAO_GLOBAL_SAMPLE_QUALITY_PRESET];
#line 228
MXAO.uvtoviewADD = float3(-1.0,-1.0,1.0);
MXAO.uvtoviewMUL = float3(2.0,2.0,0.0);
#line 237
return MXAO;
}
#line 244
float3 get_position_from_uv(in float2 uv, in qMXAO_VSOUT MXAO)
{
return (uv.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * qUINT::linear_depth(uv) * 1000.0;
}
#line 249
float3 get_position_from_uv_mipmapped(in float2 uv, in qMXAO_VSOUT MXAO, in int miplevel)
{
return (uv.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * tex2Dlod(sMXAO_DepthTex, float4(uv.xyx, miplevel)).x;
}
#line 254
void spatial_blur_data(inout BlurData o, in sampler inputsampler, in float inputscale, in float4 uv)
{
o.key = tex2Dlod(inputsampler, uv * inputscale);
o.mask = tex2Dlod(sMXAO_NormalTex, uv);
o.mask.xyz = o.mask.xyz * 2 - 1;
}
#line 261
float compute_spatial_tap_weight(in BlurData center, in BlurData tap)
{
float depth_term = saturate(1 - abs(tap.mask.w - center.mask.w));
float normal_term = saturate(dot(tap.mask.xyz, center.mask.xyz) * 16 - 15);
return depth_term * normal_term;
}
#line 268
float4 blur_filter(in qMXAO_VSOUT MXAO, in sampler inputsampler, in float inputscale, in float radius, in int blursteps)
{
float4 blur_uv = float4(MXAO.uv.xy, 0, 0);
#line 272
BlurData center, tap;
spatial_blur_data(center, inputsampler, inputscale, blur_uv);
#line 275
float4 blursum 			= center.key;
float4 blursum_noweight = center.key;
float blurweight = 1;
#line 279
static const float2 offsets[8] =
{
float2(1.5,0.5),float2(-1.5,-0.5),float2(-0.5,1.5),float2(0.5,-1.5),
float2(1.5,2.5),float2(-1.5,-2.5),float2(-2.5,1.5),float2(2.5,-1.5)
};
#line 285
float2 blur_offsetscale = qUINT::PIXEL_SIZE / inputscale * radius;
#line 287
[unroll]
for(int i = 0; i < blursteps; i++)
{
blur_uv.xy = MXAO.uv.xy + offsets[i] * blur_offsetscale;
spatial_blur_data(tap, inputsampler, inputscale, blur_uv);
#line 293
float tap_weight = compute_spatial_tap_weight(center, tap);
#line 295
blurweight += tap_weight;
blursum.w += tap.key.w * tap_weight;
blursum_noweight.w += tap.key.w;
}
#line 300
blursum.w /= blurweight;
blursum_noweight.w /= 1 + blursteps;
#line 303
return lerp(blursum.w, blursum_noweight.w, blurweight < 2);
}
#line 306
void sample_parameter_setup(in qMXAO_VSOUT MXAO, in float scaled_depth, in float layer_id, out float scaled_radius, out float falloff_factor)
{
scaled_radius  = 0.25 * qMXAO_SAMPLE_RADIUS / (MXAO.samples * (scaled_depth + 2.0));
falloff_factor = -1.0/(qMXAO_SAMPLE_RADIUS * qMXAO_SAMPLE_RADIUS);
#line 312
scaled_radius  *= lerp(1.0, qMXAO_SAMPLE_RADIUS_SECONDARY + 1e-6, layer_id);
falloff_factor *= lerp(1.0, 1.0 / (qMXAO_SAMPLE_RADIUS_SECONDARY * qMXAO_SAMPLE_RADIUS_SECONDARY + 1e-6), layer_id);
#line 315
}
#line 317
void smooth_normals(inout float3 normal, in float3 position, in qMXAO_VSOUT MXAO)
{
float2 scaled_radius = 0.018 / position.z * qUINT::ASPECT_RATIO;
float3 neighbour_normal[4] = {normal, normal, normal, normal};
#line 322
[unroll]
for(int i = 0; i < 4; i++)
{
float2 direction;
sincos(6.28318548 * 0.25 * i, direction.y, direction.x);
#line 328
[unroll]
for(int direction_step = 1; direction_step <= 5; direction_step++)
{
float search_radius = exp2(direction_step);
float2 sample_uv = MXAO.uv.zw + direction * search_radius * scaled_radius;
#line 334
float3 temp_normal = tex2Dlod(sMXAO_NormalTex, float4(sample_uv, 0, 0)).xyz * 2.0 - 1.0;
float3 temp_position = get_position_from_uv_mipmapped(sample_uv, MXAO, 0);
#line 337
float3 position_delta = temp_position - position;
float distance_weight = saturate(1.0 - dot(position_delta, position_delta) * 20.0 / search_radius);
float normal_angle = dot(normal, temp_normal);
float angle_weight = smoothstep(0.3, 0.98, normal_angle) * smoothstep(1.0, 0.98, normal_angle); 
#line 342
float total_weight = saturate(3.0 * distance_weight * angle_weight / search_radius);
#line 344
neighbour_normal[i] = lerp(neighbour_normal[i], temp_normal, total_weight);
}
}
#line 348
normal = normalize(neighbour_normal[0] + neighbour_normal[1] + neighbour_normal[2] + neighbour_normal[3]);
}
#line 355
void PS_qInputBufferSetup(in qMXAO_VSOUT MXAO, out float4 color : SV_Target0, out float4 depth : SV_Target1, out float4 normal : SV_Target2)
{
float3 single_pixel_offset = float3(qUINT::PIXEL_SIZE.xy, 0);
#line 359
float3 position          =              get_position_from_uv(MXAO.uv.xy, MXAO);
float3 position_delta_x1 = - position + get_position_from_uv(MXAO.uv.xy + single_pixel_offset.xz, MXAO);
float3 position_delta_x2 =   position - get_position_from_uv(MXAO.uv.xy - single_pixel_offset.xz, MXAO);
float3 position_delta_y1 = - position + get_position_from_uv(MXAO.uv.xy + single_pixel_offset.zy, MXAO);
float3 position_delta_y2 =   position - get_position_from_uv(MXAO.uv.xy - single_pixel_offset.zy, MXAO);
#line 365
position_delta_x1 = lerp(position_delta_x1, position_delta_x2, abs(position_delta_x1.z) > abs(position_delta_x2.z));
position_delta_y1 = lerp(position_delta_y1, position_delta_y2, abs(position_delta_y1.z) > abs(position_delta_y2.z));
#line 368
float deltaz = abs(position_delta_x1.z * position_delta_x1.z - position_delta_x2.z * position_delta_x2.z)
+ abs(position_delta_y1.z * position_delta_y1.z - position_delta_y2.z * position_delta_y2.z);
#line 371
normal  = float4(normalize(cross(position_delta_y1, position_delta_x1)) * 0.5 + 0.5, deltaz);
color 	= tex2D(qUINT::sBackBufferTex, MXAO.uv.xy);
depth 	= qUINT::linear_depth(MXAO.uv.xy) * 1000.0;
}
#line 376
void PS_StencilSetup(in qMXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
if(    qUINT::linear_depth(MXAO.uv.zw) >= qMXAO_FADE_DEPTH_END
|| 0.25 * 0.5 * qMXAO_SAMPLE_RADIUS / (tex2D(sMXAO_DepthTex, MXAO.uv.zw).x + 2.0) * 1080 < 1.0
|| MXAO.uv.z > 1.0
|| MXAO.uv.w > 1.0
) discard;
#line 384
color = 1.0;
}
#line 387
void PS_qAmbientObscurance(in qMXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
float3 position = get_position_from_uv_mipmapped(MXAO.uv.zw, MXAO, 0);
float3 normal = tex2D(sMXAO_NormalTex, MXAO.uv.zw).xyz * 2.0 - 1.0;
#line 392
float sample_jitter = dot(floor(MXAO.vpos.xy % 4 + 0.1), float2(0.0625, 0.25)) + 0.0625;
#line 394
float  layer_id = (MXAO.vpos.x + MXAO.vpos.y) % 2.0;
#line 397
smooth_normals(normal, position, MXAO);
#line 399
float linear_depth = position.z / 1000.0;
position += normal * linear_depth;
#line 402
if(qMXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 7) MXAO.samples = 2 + floor(0.05 * qMXAO_SAMPLE_RADIUS / linear_depth);
#line 404
float scaled_radius;
float falloff_factor;
sample_parameter_setup(MXAO, position.z, layer_id, scaled_radius, falloff_factor);
#line 408
float2 sample_uv, sample_direction;
sincos(2.3999632 * 16 * sample_jitter, sample_direction.x, sample_direction.y); 
sample_direction *= scaled_radius;
#line 412
color = 0.0;
#line 414
[loop]
for(int i = 0; i < MXAO.samples; i++)
{
sample_uv = MXAO.uv.zw + sample_direction.xy * qUINT::ASPECT_RATIO * (i + sample_jitter);
sample_direction.xy = mul(sample_direction.xy, float2x2(0.76465, -0.64444, 0.64444, 0.76465)); 
#line 420
float sample_mip = saturate(scaled_radius * i * 20.0) * 3.0;
#line 422
float3 occlusion_vector = -position + get_position_from_uv_mipmapped(sample_uv, MXAO, sample_mip + 0	);
float  occlusion_distance_squared = dot(occlusion_vector, occlusion_vector);
float  occlusion_normal_angle = dot(occlusion_vector, normal) * rsqrt(occlusion_distance_squared);
#line 426
float sample_occlusion = saturate(1.0 + falloff_factor * occlusion_distance_squared) * saturate(occlusion_normal_angle - qMXAO_SAMPLE_NORMAL_BIAS);
#line 437
color.w += sample_occlusion;
#line 439
}
#line 441
color = saturate(color / ((1.0 - qMXAO_SAMPLE_NORMAL_BIAS) * MXAO.samples) * 2.0);
color = color.w;
#line 445
color *= lerp(qMXAO_AMOUNT_COARSE, qMXAO_AMOUNT_FINE, layer_id);
#line 447
}
#line 449
void PS_qAmbientObscuranceHQ(in qMXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
float3 position = get_position_from_uv_mipmapped(MXAO.uv.zw, MXAO, 0);
float3 normal 	= tex2D(sMXAO_NormalTex, MXAO.uv.zw).xyz * 2.0 - 1.0;
#line 455
smooth_normals(normal, position, MXAO);
#line 458
float3 viewdir 	= normalize(-position);
#line 460
int directions = 2 + floor(MXAO.samples / 32) * 2;
int stepshalf = MXAO.samples / (directions * 2);
#line 463
float angle_correct = 1 - viewdir.z * viewdir.z;
float scaled_radius = qMXAO_SAMPLE_RADIUS / position.z / stepshalf * 1000.0;
float falloff_factor = 0.25 * rcp(qMXAO_SAMPLE_RADIUS * qMXAO_SAMPLE_RADIUS);
#line 467
float sample_jitter = dot(floor(MXAO.vpos.xy % 4 + 0.1), float2(0.0625, 0.25)) + 0.0625;
#line 469
float dir_phi = 3.14159265 / directions;
float2 sample_direction; sincos(dir_phi * sample_jitter * 6, sample_direction.y, sample_direction.x);
float2x2 rot_dir = float2x2(cos(dir_phi),-sin(dir_phi),
sin(dir_phi),cos(dir_phi));
#line 474
color = 0;
#line 476
[loop]
for(float i = 0; i < directions; i++)
{
sample_direction = mul(sample_direction, rot_dir);
float2 start = sample_direction * sample_jitter;
#line 482
float3 sliceDir = float3(sample_direction, 0);
float2 h = -1.0;
#line 485
[loop]
for(int j = 0; j < stepshalf; j++)
{
float4 sample_uv = MXAO.uv.zwzw + scaled_radius * qUINT::PIXEL_SIZE.xyxy * start.xyxy * float4(1,1,-1,-1);
float sample_mip = saturate(scaled_radius * j * 0.01) * 3.0;
#line 491
float3 occlusion_vector[2];
occlusion_vector[0] = -position + get_position_from_uv_mipmapped(sample_uv.xy, MXAO, sample_mip + 0	);
occlusion_vector[1] = -position + get_position_from_uv_mipmapped(sample_uv.zw, MXAO, sample_mip + 0	);
#line 495
float2  occlusion_distance_squared = float2(dot(occlusion_vector[0], occlusion_vector[0]),
dot(occlusion_vector[1], occlusion_vector[1]));
#line 498
float2 inv_distance = rsqrt(occlusion_distance_squared);
#line 500
float2 sample_h = float2(dot(occlusion_vector[0], viewdir),
dot(occlusion_vector[1], viewdir)) * inv_distance;
#line 503
sample_h = lerp(sample_h, h, saturate( occlusion_distance_squared * falloff_factor));
#line 505
h.xy = (sample_h > h) ? sample_h : lerp(sample_h, h, 0.75);
start += sample_direction;
}
#line 509
float3 normal_slice_plane = normalize(cross(sliceDir, viewdir));
float3 tangent = cross(viewdir, normal_slice_plane);
float3 proj_normal = normal - normal_slice_plane * dot(normal, normal_slice_plane);
#line 513
float proj_length = length(proj_normal);
float cos_gamma = clamp(dot(proj_normal, viewdir) * rcp(proj_length), -1.0, 1.0);
float gamma = -sign(dot(proj_normal, tangent)) * acos(cos_gamma);
#line 517
h = acos(min(h, 1));
#line 519
h.x = gamma + max(-h.x - gamma, -1.5707963);
h.y = gamma + min( h.y - gamma,  1.5707963);
#line 522
h *= 2;
#line 524
float2 sample_occlusion = cos_gamma + h * sin(gamma) - cos(h - gamma);
color.w += proj_length * dot(sample_occlusion, 0.25);
}
#line 528
color /= directions;
color.w = 1 - color.w;
color = color.w;
}
#line 533
void PS_qSpatialFilter1(in qMXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = blur_filter(MXAO, sCommonTex0, qMXAO_GLOBAL_RENDER_SCALE, 0.75, 4);
}
#line 538
void PS_qSpatialFilter2(qMXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
float4 ssil_ssao = blur_filter(MXAO, sCommonTex1, 1, 1.0 / qMXAO_GLOBAL_RENDER_SCALE, 8);
#line 542
color = tex2D(sMXAO_ColorTex, MXAO.uv.xy);
#line 544
static const float3 lumcoeff = float3(0.2126, 0.7152, 0.0722);
float scenedepth = qUINT::linear_depth(MXAO.uv.xy);
float colorgray = dot(color.rgb, lumcoeff);
float blendfact = 1.0 - colorgray;
#line 552
ssil_ssao.xyz = 0.0;
#line 555
ssil_ssao = saturate(ssil_ssao); 
#line 557
ssil_ssao.w  = 1.0 - pow(1.0 - ssil_ssao.w, qMXAO_SSAO_AMOUNT * 2.0);
#line 561
ssil_ssao    *= 1.0 - smoothstep(qMXAO_FADE_DEPTH_START, qMXAO_FADE_DEPTH_END, scenedepth * float4(2.0, 2.0, 2.0, 1.0));
#line 563
if(qMXAO_BLEND_TYPE == 0)
{
color.rgb -= (ssil_ssao.www - ssil_ssao.xyz) * blendfact * color.rgb;
}
else if(qMXAO_BLEND_TYPE == 1)
{
color.rgb = color.rgb * saturate(1.0 - ssil_ssao.www * blendfact * 1.2) + ssil_ssao.xyz * blendfact * colorgray * 2.0;
}
else if(qMXAO_BLEND_TYPE == 2)
{
float colordiff = saturate(2.0 * distance(normalize(color.rgb + 1e-6),normalize(ssil_ssao.rgb + 1e-6)));
color.rgb = color.rgb + ssil_ssao.rgb * lerp(color.rgb, dot(color.rgb, 0.3333), colordiff) * blendfact * blendfact * 4.0;
color.rgb = color.rgb * (1.0 - ssil_ssao.www * (1.0 - dot(color.rgb, lumcoeff)));
}
else if(qMXAO_BLEND_TYPE == 3)
{
color.rgb *= color.rgb;
color.rgb -= (ssil_ssao.www - ssil_ssao.xyz) * color.rgb;
color.rgb = sqrt(color.rgb);
}
#line 584
if(qMXAO_DEBUG_VIEW_ENABLE == 1)
{
color.rgb = max(0.0, 1.0 - ssil_ssao.www + ssil_ssao.xyz);
color.rgb *= (0	 != 0) ? 0.5 : 1.0;
}
else if(qMXAO_DEBUG_VIEW_ENABLE == 2)
{
color.rgb = tex2D(sMXAO_NormalTex, MXAO.uv.xy).xyz;
color.b = 1-color.b; 
}
#line 595
color.a = 1.0;
}
#line 602
technique qMXAO
< ui_tooltip = "                     >> qUINT::qMXAO <<\n\n"
"qMXAO is a screen-space ambient occlusion shader.\n"
"It adds diffuse shading to object corners to give more depth\n"
"and detail to the scene. Check out the preprocessor options to\n"
"get access to more functionality.\n"
"\nMake sure to move qMXAO to the very top of your shader list for\n"
"maximum compatibility with other shaders.\n"
"\nqMXAO is written by Marty McFly / Pascal Gilcher"; >
{
pass
{
VertexShader = VS_qMXAO;
PixelShader  = PS_qInputBufferSetup;
RenderTarget0 = qMXAO_ColorTex;
RenderTarget1 = qMXAO_DepthTex;
RenderTarget2 = qMXAO_NormalTex;
}
pass
{
VertexShader = VS_qMXAO;
PixelShader  = PS_StencilSetup;
#line 625
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = REPLACE;
StencilRef = 1;
}
#line 643
pass
{
VertexShader = VS_qMXAO;
PixelShader  = PS_qAmbientObscurance;
RenderTarget = CommonTex0;
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = KEEP;
StencilFunc = EQUAL;
StencilRef = 1;
}
#line 655
pass
{
VertexShader = VS_qMXAO;
PixelShader  = PS_qSpatialFilter1;
RenderTarget = CommonTex1;
}
pass
{
VertexShader = VS_qMXAO;
PixelShader  = PS_qSpatialFilter2;
#line 666
}
}

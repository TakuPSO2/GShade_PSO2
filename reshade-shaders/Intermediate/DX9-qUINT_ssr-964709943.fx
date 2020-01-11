#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_ssr.fx"
#line 27
uniform float SSR_FIELD_OF_VIEW <
ui_type = "slider";
ui_min = 0.00; ui_max = 100.00;
ui_label = "Vertical Field of View";
ui_tooltip = "Vertical FoV, should match camera FoV but since ReShade's\ndepth linearization is not always precise, this value\nmight differ from the actual value. Just set to what looks best.";
ui_category = "Global";
> = 50.0;
#line 35
uniform float SSR_REFLECTION_INTENSITY <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Reflection Intensity";
ui_tooltip = "Amount of reflection.";
ui_category = "Global";
> = 1.0;
#line 43
uniform float SSR_FRESNEL_EXP <
ui_type = "slider";
ui_min = 1.00; ui_max = 10.00;
ui_label = "Reflection Exponent";
ui_tooltip = "qUINT uses Schlick's fresnel approximation.\nThis parameter represents the power of the angle falloff.\nHigher values restrict reflections to very flat angles.\nOriginal Schlick value: 5.\nThe Fresnel Coefficient is set to 0 to match most surfaces.";
ui_category = "Global";
> = 5.0;
#line 51
uniform float SSR_FADE_DIST <
ui_type = "slider";
ui_min = 0.001; ui_max = 1.00;
ui_label = "Fade Distance";
ui_tooltip = "Distance where reflection is completely faded out.\n1 means infinite distance.";
ui_category = "Global";
> = 0.8;
#line 59
uniform float SSR_RAY_INC <
ui_type = "slider";
ui_min = 1.01; ui_max = 3.00;
ui_label = "Ray Increment";
ui_tooltip = "Rate of ray step size growth.\nA parameter of 1.0 means same sized steps,\n2.0 means the step size doubles each iteration.\nIncrease if not the entire scene is represented (e.g. sky missing) at the cost of precision.";
ui_category = "Ray Tracing";
> = 1.6;
#line 67
uniform float SSR_ACCEPT_RANGE <
ui_type = "slider";
ui_min = 0.0; ui_max = 12.00;
ui_label = "Acceptance Range";
ui_tooltip = "Acceptable error for ray intersection. Larger values will cause more coherent but incorrect reflections.";
ui_category = "Ray Tracing";
> = 2.5;
#line 75
uniform float SSR_JITTER_AMOUNT <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_label = "Ray Jitter Amount";
ui_tooltip = "Changes ray step size randomly per pixel to produce\na more coherent reflection at the cost of noise that needs to be filtered away.";
ui_category = "Ray Tracing";
> = 0.25;
#line 83
uniform float SSR_FILTER_SIZE <
ui_type = "slider";
ui_min = 0.0; ui_max = 5.00;
ui_label = "Filter Kernel Size";
ui_tooltip = "Size of spatial filter, higher values create more blurry reflections at the cost of detail.";
ui_category = "Filtering and Details";
> = 0.5;
#line 91
uniform float SSR_RELIEF_AMOUNT <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_label = "Surface Relief Height";
ui_tooltip = "Strength of embossed texture relief. Higher values cause more bumpy surfaces.";
ui_category = "Filtering and Details";
> = 0.05;
#line 99
uniform float SSR_RELIEF_SCALE <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.00;
ui_label = "Surface Relief Scale";
ui_tooltip = "Scale of embossed texture relief, lower values cause more high frequency relief.";
ui_category = "Filtering and Details";
> = 0.35;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\qUINT_ssr.fx"
#line 102
}
#line 114
texture2D SSR_ColorTex 	{ Width = 1920; Height = 1080; Format = RGBA8; AddressU = MIRROR;};
sampler2D sSSR_ColorTex	{ Texture = SSR_ColorTex;	};
#line 117
texture2D CommonTex0 	{ Width = 1920;   Height = 1080;   Format = RGBA8; };
sampler2D sCommonTex0	{ Texture = CommonTex0;	};
#line 120
texture2D CommonTex1 	{ Width = 1920;   Height = 1080;   Format = RGBA8; };
sampler2D sCommonTex1	{ Texture = CommonTex1;	};
#line 127
struct SSR_VSOUT
{
float4   vpos        : SV_Position;
float2   uv          : TEXCOORD0;
float3   uvtoviewADD : TEXCOORD4;
float3   uvtoviewMUL : TEXCOORD5;
};
#line 135
SSR_VSOUT VS_SSR(in uint id : SV_VertexID)
{
SSR_VSOUT o;
o.uv.x = (id == 2) ? 2.0 : 0.0;
o.uv.y = (id == 1) ? 2.0 : 0.0;
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 145
o.uvtoviewADD = float3(-tan(radians(SSR_FIELD_OF_VIEW * 0.5)).xx,1.0) * qUINT::ASPECT_RATIO.yxx;
o.uvtoviewMUL = float3(-2.0 * o.uvtoviewADD.xy,0.0);
#line 148
return o;
}
#line 155
float3 get_position_from_uv(in float2 uv, in SSR_VSOUT i)
{
return (uv.xyx * i.uvtoviewMUL + i.uvtoviewADD) * qUINT::linear_depth(uv) * 1000.0;
}
#line 160
float2 get_uv_from_position(in float3 pos, in SSR_VSOUT i)
{
return pos.xy / (i.uvtoviewMUL.xy * pos.z) - i.uvtoviewADD.xy/i.uvtoviewMUL.xy;
}
#line 165
float4 get_normal_and_edges_from_depth(in SSR_VSOUT i)
{
float3 single_pixel_offset = float3(qUINT::PIXEL_SIZE, 0);
#line 169
float3 position              =              get_position_from_uv(i.uv, i);
float3 position_delta_x1 	 = - position + get_position_from_uv(i.uv + single_pixel_offset.xz, i);
float3 position_delta_x2 	 =   position - get_position_from_uv(i.uv - single_pixel_offset.xz, i);
float3 position_delta_y1 	 = - position + get_position_from_uv(i.uv + single_pixel_offset.zy, i);
float3 position_delta_y2 	 =   position - get_position_from_uv(i.uv - single_pixel_offset.zy, i);
#line 175
position_delta_x1 = lerp(position_delta_x1, position_delta_x2, abs(position_delta_x1.z) > abs(position_delta_x2.z));
position_delta_y1 = lerp(position_delta_y1, position_delta_y2, abs(position_delta_y1.z) > abs(position_delta_y2.z));
#line 178
float deltaz = abs(position_delta_x1.z * position_delta_x1.z - position_delta_x2.z * position_delta_x2.z)
+ abs(position_delta_y1.z * position_delta_y1.z - position_delta_y2.z * position_delta_y2.z);
#line 181
return float4(normalize(cross(position_delta_y1, position_delta_x1)), deltaz);
}
#line 184
float3 get_normal_from_color(float2 uv, float2 offset, float scale, float sharpness)
{
float3 offset_swiz = float3(offset.xy, 0);
float hpx = dot(tex2Dlod(qUINT::sBackBufferTex, float4(uv + offset_swiz.xz,0,0)).xyz, 0.333) * scale;
float hmx = dot(tex2Dlod(qUINT::sBackBufferTex, float4(uv - offset_swiz.xz,0,0)).xyz, 0.333) * scale;
float hpy = dot(tex2Dlod(qUINT::sBackBufferTex, float4(uv + offset_swiz.zy,0,0)).xyz, 0.333) * scale;
float hmy = dot(tex2Dlod(qUINT::sBackBufferTex, float4(uv - offset_swiz.zy,0,0)).xyz, 0.333) * scale;
#line 192
float dpx = qUINT::linear_depth(uv + offset_swiz.xz);
float dmx = qUINT::linear_depth(uv - offset_swiz.xz);
float dpy = qUINT::linear_depth(uv + offset_swiz.zy);
float dmy = qUINT::linear_depth(uv - offset_swiz.zy);
#line 197
float2 xymult = float2(abs(dmx - dpx), abs(dmy - dpy)) * sharpness;
xymult = saturate(1.0 - xymult);
#line 200
float3 normal;
normal.xy = float2(hmx - hpx, hmy - hpy) * xymult / offset.xy * 0.5;
normal.z = 1.0;
#line 204
return normalize(normal);
}
#line 207
float3 blend_normals(float3 n1, float3 n2)
{
#line 210
n1 += float3( 0, 0, 1);
n2 *= float3(-1, -1, 1);
return n1*dot(n1, n2)/n1.z - n2;
}
#line 215
float bayer(float2 vpos, int max_level)
{
float finalBayer   = 0.0;
float finalDivisor = 0.0;
float layerMult	   = 1.0;
#line 221
for(float bayerLevel = max_level; bayerLevel >= 1.0; bayerLevel--)
{
layerMult 		   *= 4.0;
#line 225
float2 bayercoord 	= floor(vpos.xy * exp2(1 - bayerLevel)) % 2;
float line0202 = bayercoord.x*2.0;
#line 228
finalBayer += lerp(line0202, 3.0 - line0202, bayercoord.y) / 3.0 * layerMult;
finalDivisor += layerMult;
}
#line 232
return finalBayer / finalDivisor;
}
#line 239
struct Ray
{
float3 origin;
float3 dir;
float  step;
float3 pos;
};
#line 247
struct SceneData
{
float3 eyedir;
float3 normal;
float3 position;
float  depth;
};
#line 255
struct TraceData
{
int num_steps;
int num_refines;
float2 uv;
float3 error;
bool hit;
};
#line 264
struct BlurData
{
float4 key;
float4 mask;
};
#line 270
void PS_PrepareColor(in SSR_VSOUT i, out float4 o : SV_Target0)
{
o = tex2D(qUINT::sBackBufferTex, i.uv);
}
void PS_SSR(in SSR_VSOUT i, out float4 reflection : SV_Target0, out float4 blurbuffer : SV_Target1)
{
blurbuffer 		= get_normal_and_edges_from_depth(i);
float jitter 	= bayer(i.vpos.xy,3) - 0.5;
#line 279
SceneData scene;
scene.position = get_position_from_uv(i.uv, i);
scene.eyedir   = normalize(scene.position); 
scene.normal   = blend_normals(blurbuffer.xyz, get_normal_from_color(i.uv, 40.0 * qUINT::PIXEL_SIZE / scene.position.z * SSR_RELIEF_SCALE, 0.005 * SSR_RELIEF_AMOUNT, 1000.0));
scene.depth    = scene.position.z / 1000.0;
#line 285
Ray ray;
ray.origin = scene.position;
ray.dir = reflect(scene.eyedir, scene.normal);
ray.step = (0.2 + 0.05 * jitter * SSR_JITTER_AMOUNT) * sqrt(scene.depth) * rcp(1e-3 + saturate(1 - dot(ray.dir, scene.eyedir))); 
ray.pos = ray.origin + ray.dir * ray.step;
#line 291
TraceData trace;
trace.uv = i.uv;
trace.hit = 0;
trace.num_steps = 20;
trace.num_refines = 3;
#line 297
int j = 0;
int k = 0;
bool uv_inside_screen;
#line 301
while(j++ < trace.num_steps)
{
trace.uv =  get_uv_from_position(ray.pos, i);
trace.error = get_position_from_uv(trace.uv, i) - ray.pos;
#line 306
if(trace.error.z < 0 && trace.error.z > -SSR_ACCEPT_RANGE * ray.step)
{
j = 0; 
#line 310
if(k < trace.num_refines)
{
#line 313
ray.step /= SSR_RAY_INC;
ray.pos -= ray.dir * ray.step;
#line 317
ray.step *= SSR_RAY_INC * rcp(trace.num_steps);
}
else
{
j += trace.num_steps; 
}
k++;
}
#line 326
ray.pos += ray.dir * ray.step;
ray.step *= SSR_RAY_INC;
#line 329
uv_inside_screen = all(saturate(-trace.uv.y * trace.uv.y + trace.uv.y));
j += trace.num_steps * !uv_inside_screen;
}
#line 333
trace.hit = k != 0;	
#line 335
float SSR_FRESNEL_K = 0.04; 
#line 337
float schlick = lerp(SSR_FRESNEL_K, 1, pow(saturate(1 - dot(-scene.eyedir, scene.normal)), SSR_FRESNEL_EXP)) * SSR_REFLECTION_INTENSITY;
float fade 	  = saturate(dot(scene.eyedir, ray.dir)) * saturate(1 - dot(-scene.eyedir, scene.normal));
#line 340
reflection.a   = trace.hit * schlick * fade;
reflection.rgb = tex2D(sSSR_ColorTex, trace.uv).rgb * reflection.a;
#line 343
blurbuffer.xyz = blurbuffer.xyz * 0.5 + 0.5;
}
#line 346
void spatial_blur_data(inout BlurData o, in sampler inputsampler, in float4 uv)
{
o.key 	= tex2Dlod(inputsampler, uv);
o.mask 	= tex2Dlod(sCommonTex1, uv);
o.mask.xyz = o.mask.xyz * 2 - 1;
}
#line 353
float compute_spatial_tap_weight(in BlurData center, in BlurData tap)
{
float depth_term = saturate(1 - abs(tap.mask.w - center.mask.w) * 50);
float normal_term = saturate(dot(tap.mask.xyz, center.mask.xyz) * 50 - 49);
return depth_term * normal_term;
}
#line 360
float4 blur_filter(in SSR_VSOUT i, in sampler inputsampler, in float radius, in float2 axis)
{
float4 blur_uv = float4(i.uv.xy, 0, 0);
#line 364
BlurData center, tap;
spatial_blur_data(center, inputsampler, blur_uv);
#line 367
if(SSR_FILTER_SIZE == 0) return center.key;
#line 369
float kernel_size = radius;
float k = -2.0 * rcp(kernel_size * kernel_size + 1e-3);
#line 372
float4 blursum 					= 0;
float4 blursum_noweight 		= 0;
float blursum_weight 			= 1e-3;
float blursum_noweight_weight 	= 1e-3; 
#line 377
[unroll] 1;
for(float j = -floor(kernel_size); j <= floor(kernel_size); j++)
{
spatial_blur_data(tap, inputsampler,  float4(i.uv + axis * (2.0 * j - 0.5), 0, 0));
float tap_weight = compute_spatial_tap_weight(center, tap);
#line 383
blursum 			+= tap.key * tap_weight * exp(j * j * k) * tap.key.w;
blursum_weight 		+= tap_weight * exp(j * j * k) * tap.key.w;
blursum_noweight 			+= tap.key * exp(j * j * k) * tap.key.w;
blursum_noweight_weight 	+= exp(j * j * k) * tap.key.w;
}
#line 389
blursum /= blursum_weight;
blursum_noweight /= blursum_noweight_weight;
#line 392
return lerp(center.key, blursum, saturate(blursum_weight * 2));
}
#line 395
void PS_FilterH(in SSR_VSOUT i, out float4 o : SV_Target0)
{
o = blur_filter(i, sCommonTex0, SSR_FILTER_SIZE, float2(0, 1) * qUINT::PIXEL_SIZE);
}
#line 400
void PS_FilterV(in SSR_VSOUT i, out float4 o : SV_Target0)
{
float4 reflection = blur_filter(i, sSSR_ColorTex, SSR_FILTER_SIZE, float2(1, 0) * qUINT::PIXEL_SIZE);
float alpha = reflection.w; 
#line 405
float fade = saturate(1 - qUINT::linear_depth(i.uv) / SSR_FADE_DIST);
o = tex2D(qUINT::sBackBufferTex, i.uv);
#line 408
o.rgb = lerp(o.rgb, reflection.rgb, alpha * fade);
}
#line 415
technique SSR
< ui_tooltip = "                      >> qUINT::SSR <<\n\n"
"SSR adds screen-space reflections to the scene. This shader is\n"
"intended to only be used in screenshots as it will add reflections\n"
"to _everything_ - ReShade limitation.\n"
"\nSSR is written by Marty McFly / Pascal Gilcher"; >
{
pass
{
VertexShader = VS_SSR;
PixelShader  = PS_PrepareColor;
RenderTarget = SSR_ColorTex;
}
pass
{
VertexShader = VS_SSR;
PixelShader  = PS_SSR;
RenderTarget0 = CommonTex0;
RenderTarget1 = CommonTex1;
}
pass
{
VertexShader = VS_SSR;
PixelShader  = PS_FilterH;
RenderTarget = SSR_ColorTex;
}
pass
{
VertexShader = VS_SSR;
PixelShader  = PS_FilterV;
}
}

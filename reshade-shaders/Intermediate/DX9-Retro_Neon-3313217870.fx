#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Retro_Neon.fx"
#line 24
uniform float GLOW_COLOR <
ui_type = "slider";
ui_label = "Glow Color";
ui_min = 0.0;
ui_max = 1.0;
> = 0.567;
#line 31
uniform bool USE_PING
<
ui_label = "Use Radar Ping Effect";
> = true;
#line 36
uniform float LENS_DISTORT <
ui_type = "slider";
ui_label = "Lens Distortion Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.2;
#line 43
uniform float CHROMA_SHIFT <
ui_type = "slider";
ui_label = "Chromatic Aberration Intensity";
ui_min = -1.0;
ui_max = 1.0;
> = 0.5;
#line 50
uniform float EDGES_AMT <
ui_type = "slider";
ui_label = "Edge Amount";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 65
uniform bool DEBUG_CHEAT_MASK = false;
uniform bool DEBUG_LINE_MODE = false;
uniform bool DEBUG_FADE_MULT = 0.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Retro_Neon.fx"
#line 102
}
#line 75
uniform float timer < source = "timer"; >;
#line 78
texture2D TempTex0 	{ Width = 1920;   Height = 1080;   Format = RGBA16F; };
texture2D TempTex1 	{ Width = 1920;   Height = 1080;   Format = RGBA16F; };
#line 81
sampler2D sTempTex0	{ Texture = TempTex0;	};
sampler2D sTempTex1	{ Texture = TempTex1;	};
#line 84
texture2D GlowTex0 	{ Width = 1920/2;   Height = 1080/2;   Format = RGBA16F; };
texture2D GlowTex1 	{ Width = 1920/4;   Height = 1080/4;   Format = RGBA16F; };
texture2D GlowTex2 	{ Width = 1920/8;   Height = 1080/8;   Format = RGBA16F; };
texture2D GlowTex3 	{ Width = 1920/16;   Height = 1080/16;   Format = RGBA16F; };
texture2D GlowTex4 	{ Width = 1920/32;   Height = 1080/32;   Format = RGBA16F; };
#line 90
sampler2D sGlowTex0	{ Texture = GlowTex0;	};
sampler2D sGlowTex1	{ Texture = GlowTex1;	};
sampler2D sGlowTex2	{ Texture = GlowTex2;	};
sampler2D sGlowTex3	{ Texture = GlowTex3;	};
sampler2D sGlowTex4	{ Texture = GlowTex4;	};
#line 100
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
nointerpolation float3  uvtoviewADD : TEXCOORD2;
nointerpolation float3  uvtoviewMUL : TEXCOORD3;
};
#line 108
VSOUT VSMain(in uint id : SV_VertexID)
{
VSOUT o;
#line 112
o.uv.x = (id == 2) ? 2.0 : 0.0;
o.uv.y = (id == 1) ? 2.0 : 0.0;
#line 115
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 117
o.uvtoviewADD = float3(-1.0,-1.0,1.0);
o.uvtoviewMUL = float3(2.0,2.0,0.0);
#line 120
return o;
}
#line 127
float depth_to_distance(in float depth)
{
return depth * 1000.0 + 1;
}
#line 132
float3 get_position_from_uv(in VSOUT i)
{
return (i.uv.xyx * i.uvtoviewMUL + i.uvtoviewADD) * depth_to_distance(qUINT::linear_depth(i.uv.xy));
}
#line 137
float3 get_position_from_uv(in VSOUT i, in float2 uv)
{
return (uv.xyx * i.uvtoviewMUL + i.uvtoviewADD) * depth_to_distance(qUINT::linear_depth(uv));
}
#line 142
float4 gaussian_1D(in VSOUT i, in sampler input_tex, int kernel_size, float2 axis)
{
float4 sum = tex2D(input_tex, i.uv);
float weightsum = 1;
#line 147
[unroll]
for(float j = 1; j <= kernel_size; j++)
{
float w = exp(-2 * j * j / (kernel_size * kernel_size));
sum += tex2Dlod(input_tex, float4(i.uv + qUINT::PIXEL_SIZE * axis * (j * 2 - 0.5), 0, 0)) * w;
sum += tex2Dlod(input_tex, float4(i.uv - qUINT::PIXEL_SIZE * axis * (j * 2 - 0.5), 0, 0)) * w;
weightsum += w * 2;
}
return sum / weightsum;
}
#line 158
float4 downsample(sampler2D tex, float2 tex_size, float2 uv)
{
float4 offset_uv = 0;
#line 162
const float2 kernel_small_offsets = float2(2.0,2.0) / tex_size;
const float2 kernel_large_offsets = float2(4.0,4.0) / tex_size;
#line 165
const float4 kernel_center = tex2D(tex, uv);
#line 167
float4 kernel_small = 0;
#line 169
offset_uv.xy = uv + kernel_small_offsets;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_small_offsets.y;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
#line 178
float4 kernel_large_1 = 0;
#line 180
offset_uv.xy = uv + kernel_large_offsets;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_large_offsets.y;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
#line 189
float4 kernel_large_2 = 0;
#line 191
offset_uv.xy = uv;
offset_uv.x += kernel_large_offsets.x;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x -= kernel_large_offsets.x * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x;
offset_uv.y += kernel_large_offsets.y;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.y -= kernel_large_offsets.y * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
#line 202
return kernel_center * 0.5 / 4.0
+ kernel_small  * 0.5 / 4.0
+ kernel_large_1 * 0.125 / 4.0
+ kernel_large_2 * 0.25 / 4.0;
}
#line 208
float3 hue_to_rgb(float hue)
{
return saturate(float3(abs(hue * 6.0 - 3.0) - 1.0,
2.0 - abs(hue * 6.0 - 2.0),
2.0 - abs(hue * 6.0 - 4.0)));
}
#line 219
void PrepareInput(in VSOUT i, out float4 o : SV_Target0)
{
float4 A, B, C, D, E, F, G, H, I;
#line 223
float3 offsets = float3(1, 0, -1);
#line 231
A.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zz * qUINT::PIXEL_SIZE).rgb;
B.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yz * qUINT::PIXEL_SIZE).rgb;
C.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xz * qUINT::PIXEL_SIZE).rgb;
D.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zy * qUINT::PIXEL_SIZE).rgb;
E.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yy * qUINT::PIXEL_SIZE).rgb;
F.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xy * qUINT::PIXEL_SIZE).rgb;
G.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zx * qUINT::PIXEL_SIZE).rgb;
H.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yx * qUINT::PIXEL_SIZE).rgb;
I.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xx * qUINT::PIXEL_SIZE).rgb;
#line 241
A.w = qUINT::linear_depth(i.uv + offsets.zz * qUINT::PIXEL_SIZE);
B.w = qUINT::linear_depth(i.uv + offsets.yz * qUINT::PIXEL_SIZE);
C.w = qUINT::linear_depth(i.uv + offsets.xz * qUINT::PIXEL_SIZE);
D.w = qUINT::linear_depth(i.uv + offsets.zy * qUINT::PIXEL_SIZE);
E.w = qUINT::linear_depth(i.uv + offsets.yy * qUINT::PIXEL_SIZE);
F.w = qUINT::linear_depth(i.uv + offsets.xy * qUINT::PIXEL_SIZE);
G.w = qUINT::linear_depth(i.uv + offsets.zx * qUINT::PIXEL_SIZE);
H.w = qUINT::linear_depth(i.uv + offsets.yx * qUINT::PIXEL_SIZE);
I.w = qUINT::linear_depth(i.uv + offsets.xx * qUINT::PIXEL_SIZE);
#line 251
float3 color_edge;
{
const float3 corners = (A.rgb + C.rgb) + (G.rgb + I.rgb);
const float3 neighbours = (B.rgb + D.rgb) + (F.rgb + H.rgb);
const float3 center = E.rgb;
#line 257
color_edge = corners + 2.0 * neighbours - 12.0 * center;
#line 259
}
#line 261
const float depth_delta_x1 = D.w - E.w;
const float depth_delta_x2 = E.w - F.w;
#line 264
float depth_edge_x;
if (abs(depth_delta_x1) < abs(depth_delta_x2))
depth_edge_x = depth_delta_x1;
else
depth_edge_x = depth_delta_x2;
#line 271
const float depth_delta_y1 = B.w - E.w;
const float depth_delta_y2 = E.w - H.w;
#line 274
float depth_edge_y;
if (abs(depth_delta_y1) < abs(depth_delta_y2))
depth_edge_y = depth_delta_y1;
else
depth_edge_y = depth_delta_y2;
#line 280
o.xyz = normalize(float3(depth_edge_x, depth_edge_y, 0.000001));
o.w = smoothstep(0.15, 0.25, sqrt(dot(color_edge, color_edge))); 
}
#line 284
void Filter_Input_A(in VSOUT i, out float4 o : SV_Target0)
{
o = gaussian_1D(i, sTempTex0, 1, float2(0, 1));
}
#line 289
void Filter_Input_B(in VSOUT i, out float4 o : SV_Target0)
{
o = gaussian_1D(i, sTempTex1, 1, float2(1, 0));
}
#line 294
void GenerateEdges(in VSOUT i, out float4 o : SV_Target0)
{
if(DEBUG_LINE_MODE)
{
float3 blurred = 0;
#line 300
for(int x = -2; x<=2; x++)
for(int y = -2; y<=2; y++)
{
blurred += tex2Doffset(sTempTex0, i.uv, int2(x, y)).xyz;
}
#line 306
o = dot(normalize(blurred), tex2D(sTempTex0, i.uv).xyz);
o = smoothstep(1, 0.7 * EDGES_AMT, o);
#line 309
}else{
#line 311
float3x3 sobel = float3x3(1, 2, 1, 0, 0, 0, -1, -2, -1);
#line 313
float3 sobelx = 0, sobely = 0;
#line 315
for(int x = 0; x < 3; x++)
for(int y = 0; y < 3; y++)
{
float3 n = tex2Doffset(sTempTex0, i.uv, int2(x - 1, y - 1)).xyz;
sobelx += n * sobel[x][y];
sobely += n * sobel[y][x];
}
#line 323
o = pow(abs(EDGES_AMT * 0.2 * (dot(sobelx, sobelx) + dot(sobely, sobely))), 1.5);
}
#line 326
o *= smoothstep(0.5,0.48, max(abs(i.uv.x-0.5), abs(i.uv.y-0.5))); 
o.w = tex2D(sTempTex0, i.uv).w; 
}
#line 330
void Downsample0(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sTempTex1, qUINT::SCREEN_SIZE, i.uv);
#line 335
o *= saturate(1.0 - qUINT::linear_depth(i.uv) * 40.0 * DEBUG_FADE_MULT);
}
void Downsample1(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex0, qUINT::SCREEN_SIZE/2, i.uv);
}
void Downsample2(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex1, qUINT::SCREEN_SIZE/4, i.uv);
}
void Downsample3(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex2, qUINT::SCREEN_SIZE/8, i.uv);
}
void Downsample4(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex3, qUINT::SCREEN_SIZE/16, i.uv);
}
#line 354
void Combine(in VSOUT i, out float4 o : SV_Target0)
{
o = 0;
#line 358
const float depth = qUINT::linear_depth(i.uv);
#line 360
const float lines = tex2D(sTempTex1, i.uv).x * 0.63;
#line 362
const float glow = tex2D(sGlowTex0, i.uv).x * 0.07
+ tex2D(sGlowTex1, i.uv).x * 1.08
+ tex2D(sGlowTex2, i.uv).x * 0.92
+ tex2D(sGlowTex3, i.uv).x * 0.95
+ tex2D(sGlowTex4, i.uv).x * 0.5;
#line 368
float wave = frac(sqrt(length(get_position_from_uv(i)))*0.09 - (timer % 100000)* 0.003*0.1);
wave = wave*wave*wave*wave*wave*0.8;
#line 374
wave *= saturate(1.0 - depth * 50.0 * DEBUG_FADE_MULT);
#line 376
if(!USE_PING) wave = 0;
#line 378
o.rgb = lines + (lines + glow + wave) * hue_to_rgb(GLOW_COLOR);
#line 380
if(DEBUG_CHEAT_MASK) o.rgb *= tex2D(sGlowTex2, i.uv).w * 2.0;
o.w = 1;
}
#line 384
void PostFX(in VSOUT i, out float4 o : SV_Target0)
{
#line 394
o = 0;
#line 396
float3 offsets[5] =
{
float3(1.5, 0.5,4),
float3(-1.5, -0.5,4),
float3(-0.5, 1.5,4),
float3(0.5, -1.5,4),
float3(0,0,1)
};
#line 405
for(int j = 0; j < 5; j++)
{
const float2 uv = i.uv.xy - 0.5;
const float distort = 1 + dot(uv, uv) * 0 + dot(uv, uv) * dot(uv, uv) * -(LENS_DISTORT * 0.9 + 0.5);
o.x += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1 - 0.008 * CHROMA_SHIFT) * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).x * offsets[j].z;
o.y += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1       )  * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).y * offsets[j].z;
o.z += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1 + 0.008 * CHROMA_SHIFT) * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).z * offsets[j].z;
o.w += offsets[j].z;
}
#line 415
o /= o.w;
}
#line 422
technique TRON
{
pass
{
VertexShader = VSMain;
PixelShader  = PrepareInput;
RenderTarget = TempTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = Filter_Input_A;
RenderTarget = TempTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Filter_Input_B;
RenderTarget = TempTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = GenerateEdges;
RenderTarget = TempTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample0;
RenderTarget = GlowTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample1;
RenderTarget = GlowTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample2;
RenderTarget = GlowTex2;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample3;
RenderTarget = GlowTex3;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample4;
RenderTarget = GlowTex4;
}
pass
{
VertexShader = VSMain;
PixelShader  = Combine;
}
pass
{
VertexShader = VSMain;
PixelShader  = PostFX;
}
}

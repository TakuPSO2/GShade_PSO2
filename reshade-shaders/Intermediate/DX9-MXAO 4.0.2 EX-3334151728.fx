#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MXAO 4.0.2 EX.fx"
#line 40
uniform int MXAO_GLOBAL_SAMPLE_QUALITY_PRESET <
ui_type = "combo";
ui_label = "Sample Quality";
ui_items = "Very Low (4)\0Low (8)\0Medium (16)\0High (24)\0Very High (32)\0Ultra (64)\0Maximum (255)\0";
ui_tooltip = "Global quality control, main performance knob. Higher radii might require higher quality.";
> = 2;
#line 47
uniform float MXAO_SAMPLE_RADIUS <
ui_type = "slider";
ui_min = 0.5; ui_max = 20.0;
ui_label = "Sample Radius";
ui_tooltip = "Sample radius of MXAO, higher means more large-scale occlusion with less fine-scale details.";
> = 2.5;
#line 54
uniform float MXAO_SAMPLE_NORMAL_BIAS <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Normal Bias";
ui_tooltip = "Occlusion Cone bias to reduce self-occlusion of surfaces that have a low angle to each other.";
> = 0.2;
#line 61
uniform float MXAO_GLOBAL_RENDER_SCALE <
ui_type = "slider";
ui_label = "Render Size Scale";
ui_min = 0.50; ui_max = 1.00;
ui_tooltip = "Factor of MXAO resolution, lower values greatly reduce performance overhead but decrease quality.\n1.0 = MXAO is computed in original resolution\n0.5 = MXAO is computed in 1/2 width 1/2 height of original resolution\n...";
> = 1.0;
#line 68
uniform float MXAO_SSAO_AMOUNT <
ui_type = "slider";
ui_min = 0.00; ui_max = 6.00;
ui_label = "Ambient Occlusion Amount";
ui_tooltip = "Intensity of AO effect. Can cause pitch black clipping if set too high.";
> = 1.00;
#line 128
uniform float MXAO_GAMMA <
ui_type = "slider";
ui_min = 1.00; ui_max = 3.00;
ui_label = "AO Gamma";
ui_tooltip = "Exponent for the AO result. ( pow(<AO>, gamma) )";
> = 1.00;
#line 135
uniform int MXAO_DEBUG_VIEW_ENABLE <
ui_type = "combo";
ui_label = "Enable Debug View";
ui_items = "None\0AO/IL channel\0Culling Mask\0";
ui_tooltip = "Different debug outputs";
> = 0;
#line 142
uniform int MXAO_BLEND_TYPE <
ui_type = "combo";
ui_items = "MXAO 2.0\0MXAO 3.0\0MXAO 4.0\0Beats Me What This Does - Marot\0";
ui_label = "Blending Mode";
ui_tooltip = "Different blending modes for merging AO/IL with original color.\0Blending mode 0 matches formula of MXAO 2.0 and older.";
> = 0;
#line 149
uniform float MXAO_FADE_DEPTH_START <
ui_type = "slider";
ui_label = "Fade Out Start";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO starts to fade out. 0.0 = camera, 1.0 = sky. Must be less than Fade Out End.";
> = 0.05;
#line 156
uniform float MXAO_FADE_DEPTH_END <
ui_type = "slider";
ui_label = "Fade Out End";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO completely fades out. 0.0 = camera, 1.0 = sky. Must be greater than Fade Out Start.";
> = 0.4;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MXAO 4.0.2 EX.fx"
#line 169
texture2D MXAO_ColorTex 	{ Width = 1920;   Height = 1080;   Format = RGBA8; MipLevels = 3+2	;};
texture2D MXAO_DepthTex 	{ Width = 1920;   Height = 1080;   Format = R16F;  MipLevels = 3+0	;};
texture2D MXAO_NormalTex	{ Width = 1920;   Height = 1080;   Format = RGBA8; MipLevels = 3+2	;};
texture2D MXAO_CullingTex	{ Width = 1920/8; Height = 1080/8; Format = R8; };
#line 174
sampler2D sMXAO_ColorTex	{ Texture = MXAO_ColorTex;	};
sampler2D sMXAO_DepthTex	{ Texture = MXAO_DepthTex;	};
sampler2D sMXAO_NormalTex	{ Texture = MXAO_NormalTex;	};
sampler2D sMXAO_CullingTex	{ Texture = MXAO_CullingTex;	};
#line 183
struct MXAO_VSOUT
{
float4              position    : SV_Position;
float2              texcoord    : TEXCOORD0;
float2              scaledcoord : TEXCOORD1;
float   	    samples     : TEXCOORD2;
float3              uvtoviewADD : TEXCOORD4;
float3              uvtoviewMUL : TEXCOORD5;
};
#line 193
MXAO_VSOUT VS_MXAO(in uint id : SV_VertexID)
{
MXAO_VSOUT MXAO;
#line 197
if (id == 2)
MXAO.texcoord.x = 2.0;
else
MXAO.texcoord.x = 0.0;
#line 202
if (id == 1)
MXAO.texcoord.y = 2.0;
else
MXAO.texcoord.y = 0.0;
#line 207
MXAO.scaledcoord.xy = MXAO.texcoord.xy / MXAO_GLOBAL_RENDER_SCALE;
MXAO.position = float4(MXAO.texcoord.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 210
MXAO.samples   = 8;
#line 212
if(     MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 0) { MXAO.samples = 4;     }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 1) { MXAO.samples = 8;     }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 2) { MXAO.samples = 16;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 3) { MXAO.samples = 24;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 4) { MXAO.samples = 32;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 5) { MXAO.samples = 64;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 6) { MXAO.samples = 255;   }
#line 220
MXAO.uvtoviewADD = float3(-1.0,-1.0,1.0);
MXAO.uvtoviewMUL = float3(2.0,2.0,0.0);
#line 229
return MXAO;
}
#line 236
float GetLinearDepth(in float2 coords)
{
return ReShade::GetLinearizedDepth(coords);
}
#line 243
float3 GetPosition(in float2 coords, in MXAO_VSOUT MXAO)
{
return (coords.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * GetLinearDepth(coords.xy) * 1000.0;
}
#line 250
float3 GetPositionLOD(in float2 coords, in MXAO_VSOUT MXAO, in int mipLevel)
{
return (coords.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * tex2Dlod(sMXAO_DepthTex, float4(coords.xy,0,mipLevel)).x;
}
#line 257
void GetBlurWeight(in float4 tempKey, in float4 centerKey, in float surfacealignment, inout float weight)
{
const float depthdiff = abs(tempKey.w - centerKey.w);
const float normaldiff = saturate(1.0 - dot(tempKey.xyz,centerKey.xyz));
#line 262
weight = saturate(0.15 / surfacealignment - depthdiff) * saturate(0.65 - normaldiff);
weight = saturate(weight * 4.0) * 2.0;
}
#line 268
void GetBlurKeyAndSample(in float2 texcoord, in float inputscale, in sampler inputsampler, inout float4 tempsample, inout float4 key)
{
const float4 lodcoord = float4(texcoord.xy,0,0);
tempsample = tex2Dlod(inputsampler,lodcoord * inputscale);
key = float4(tex2Dlod(sMXAO_NormalTex,lodcoord).xyz*2-1, tex2Dlod(sMXAO_DepthTex,lodcoord).x);
}
#line 277
float4 BlurFilter(in MXAO_VSOUT MXAO, in sampler inputsampler, in float inputscale, in float radius, in int blursteps)
{
float4 tempsample;
float4 centerkey, tempkey;
float  centerweight = 1.0, tempweight;
float4 blurcoord = 0.0;
#line 284
GetBlurKeyAndSample(MXAO.texcoord.xy,inputscale,inputsampler,tempsample,centerkey);
float surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(MXAO.texcoord.xy*2.0-1.0,1.0)*centerkey.w)));
#line 293
float4 blurSum = tempsample.w;
const float2 blurOffsets[8] = {float2(1.5,0.5),float2(-1.5,-0.5),float2(-0.5,1.5),float2(0.5,-1.5),float2(1.5,2.5),float2(-1.5,-2.5),float2(-2.5,1.5),float2(2.5,-1.5)};
#line 296
[loop]
for(int iStep = 0; iStep < blursteps; iStep++)
{
const float2 sampleCoord = MXAO.texcoord.xy + blurOffsets[iStep] * ReShade::PixelSize * radius / inputscale;
#line 301
GetBlurKeyAndSample(sampleCoord, inputscale, inputsampler, tempsample, tempkey);
GetBlurWeight(tempkey, centerkey, surfacealignment, tempweight);
#line 304
blurSum += tempsample.w * tempweight;
centerweight  += tempweight;
}
#line 308
blurSum.w /= centerweight;
#line 311
blurSum.xyz = centerkey.xyz*0.5+0.5;
#line 314
return blurSum;
}
#line 319
void SetupAOParameters(in MXAO_VSOUT MXAO, in float3 P, in float layerID, out float scaledRadius, out float falloffFactor)
{
scaledRadius  = 0.25 * MXAO_SAMPLE_RADIUS / (MXAO.samples * (P.z + 2.0));
falloffFactor = -1.0/(MXAO_SAMPLE_RADIUS * MXAO_SAMPLE_RADIUS);
#line 328
}
#line 332
void TesselateNormals(inout float3 N, in float3 P, in MXAO_VSOUT MXAO)
{
const float2 searchRadiusScaled = 0.018 / P.z * float2(1.0,ReShade::AspectRatio);
float3 likelyFace[4] = {N,N,N,N};
#line 337
for(int iDirection=0; iDirection < 4; iDirection++)
{
float2 cdir;
sincos(6.28318548 * 0.25 * iDirection,cdir.y,cdir.x);
for(int i=1; i<=5; i++)
{
const float cSearchRadius = exp2(i);
const float2 cOffset = MXAO.scaledcoord.xy + cdir * cSearchRadius * searchRadiusScaled;
#line 346
const float3 cN = tex2Dlod(sMXAO_NormalTex,float4(cOffset,0,0)).xyz * 2.0 - 1.0;
const float3 cP = GetPositionLOD(cOffset.xy,MXAO,0);
#line 349
const float3 cDelta = cP - P;
const float validWeightDistance = saturate(1.0 - dot(cDelta,cDelta) * 20.0 / cSearchRadius);
const float Angle = dot(N.xyz,cN.xyz);
const float validWeightAngle = smoothstep(0.3,0.98,Angle) * smoothstep(1.0,0.98,Angle); 
#line 354
const float validWeight = saturate(3.0 * validWeightDistance * validWeightAngle / cSearchRadius);
#line 356
likelyFace[iDirection] = lerp(likelyFace[iDirection],cN.xyz, validWeight);
}
}
#line 360
N = normalize(likelyFace[0] + likelyFace[1] + likelyFace[2] + likelyFace[3]);
}
#line 365
bool GetCullingMask(in MXAO_VSOUT MXAO)
{
const float4 cOffsets = float4(ReShade::PixelSize.xy,-ReShade::PixelSize.xy) * 8;
float cullingArea = tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.xy).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.zy).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.xw).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.zw).x;
return cullingArea  > 0.000001;
}
#line 377
float3 RGBtoHSV(in float3 RGB){
float3 HSV = 0;
HSV.z = max(RGB.r, max(RGB.g, RGB.b));
const float M = min(RGB.r, min(RGB.g, RGB.b));
const float C = HSV.z - M;
if (C != 0){
const float4 RGB0 = float4(RGB, 0);
float4 Delta = (HSV.z - RGB0) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
Delta.brg = step(HSV.z, RGB) * Delta.brg;
HSV.x = max(Delta.r, max(Delta.g, Delta.b));
HSV.x = frac(HSV.x / 6);
HSV.y = 1 / Delta.w;
}
return HSV;
}
#line 399
void PS_InputBufferSetup(in MXAO_VSOUT MXAO, out float4 color : SV_Target0, out float4 depth : SV_Target1, out float4 normal : SV_Target2)
{
const float3 offs = float3(ReShade::PixelSize.xy,0);
#line 403
const float3 f 	 =       GetPosition(MXAO.texcoord.xy, MXAO);
float3 gradx1 	 = - f + GetPosition(MXAO.texcoord.xy + offs.xz, MXAO);
const float3 gradx2 	 =   f - GetPosition(MXAO.texcoord.xy - offs.xz, MXAO);
float3 grady1 	 = - f + GetPosition(MXAO.texcoord.xy + offs.zy, MXAO);
const float3 grady2 	 =   f - GetPosition(MXAO.texcoord.xy - offs.zy, MXAO);
#line 409
gradx1 = lerp(gradx1, gradx2, abs(gradx1.z) > abs(gradx2.z));
grady1 = lerp(grady1, grady2, abs(grady1.z) > abs(grady2.z));
#line 412
normal          = float4(normalize(cross(grady1,gradx1)) * 0.5 + 0.5,0.0);
color 		= tex2D(ReShade::BackBuffer, MXAO.texcoord.xy);
depth 		= GetLinearDepth(MXAO.texcoord.xy)*1000.0;
}
#line 419
void PS_Culling(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = 0.0;
MXAO.scaledcoord.xy = MXAO.texcoord.xy;
MXAO.samples = clamp(MXAO.samples, 8, 32);
#line 425
float3 P             = GetPositionLOD(MXAO.scaledcoord.xy, MXAO, 0);
float3 N             = tex2D(sMXAO_NormalTex, MXAO.scaledcoord.xy).xyz * 2.0 - 1.0;
#line 428
P += N * P.z / 1000.0;
#line 430
float scaledRadius;
float falloffFactor;
SetupAOParameters(MXAO, P, 0, scaledRadius, falloffFactor);
#line 434
float randStep = dot(floor(MXAO.position.xy % 4 + 0.1),int2(1,4)) + 1;
randStep *= 0.0625;
#line 437
float2 sampleUV, Dir;
sincos(38.39941 * randStep, Dir.x, Dir.y);
#line 440
Dir *= scaledRadius;
#line 442
[loop]
for(int iSample=0; iSample < MXAO.samples; iSample++)
{
sampleUV = MXAO.scaledcoord.xy + Dir.xy * float2(1.0, ReShade::AspectRatio) * (iSample + randStep);
Dir.xy = mul(Dir.xy, float2x2(0.76465,-0.64444,0.64444,0.76465));
#line 448
const float sampleMIP = saturate(scaledRadius * iSample * 20.0) * 3.0;
#line 450
const float3 V 		= -P + GetPositionLOD(sampleUV, MXAO, sampleMIP + 0	);
const float  VdotV            = dot(V, V);
const float  VdotN            = dot(V, N) * rsqrt(VdotV);
#line 454
const float fAO = saturate(1.0 + falloffFactor * VdotV) * saturate(VdotN - MXAO_SAMPLE_NORMAL_BIAS * 0.5);
color.w += fAO;
}
#line 458
color = color.w;
}
#line 463
void PS_StencilSetup(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
if(    GetLinearDepth(MXAO.scaledcoord.xy) >= MXAO_FADE_DEPTH_END
|| 0.25 * 0.5 * MXAO_SAMPLE_RADIUS / (tex2D(sMXAO_DepthTex,MXAO.scaledcoord.xy).x + 2.0) * 1080 < 1.0
|| MXAO.scaledcoord.x > 1.0
|| MXAO.scaledcoord.y > 1.0
|| !GetCullingMask(MXAO)
) discard;
#line 472
color = 1.0;
}
#line 477
void PS_AmbientObscurance(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = 0.0;
#line 481
float3 P             = GetPositionLOD(MXAO.scaledcoord.xy, MXAO, 0);
float3 N             = tex2D(sMXAO_NormalTex, MXAO.scaledcoord.xy).xyz * 2.0 - 1.0;
const float  layerID       = (MXAO.position.x + MXAO.position.y) % 2.0;
#line 486
TesselateNormals(N, P, MXAO);
#line 489
P += N * P.z / 1000.0;
#line 491
float scaledRadius;
float falloffFactor;
SetupAOParameters(MXAO, P, layerID, scaledRadius, falloffFactor);
#line 495
float randStep = dot(floor(MXAO.position.xy % 4 + 0.1),int2(1,4)) + 1;
randStep *= 0.0625;
#line 498
float2 sampleUV, Dir;
sincos(38.39941 * randStep, Dir.x, Dir.y);
#line 501
Dir *= scaledRadius;
#line 503
[loop]
for(int iSample=0; iSample < MXAO.samples; iSample++)
{
sampleUV = MXAO.scaledcoord.xy + Dir.xy * float2(1.0, ReShade::AspectRatio) * (iSample + randStep);
Dir.xy = mul(Dir.xy, float2x2(0.76465,-0.64444,0.64444,0.76465));
#line 509
const float sampleMIP = saturate(scaledRadius * iSample * 20.0) * 3.0;
#line 511
const float3 V 		= -P + GetPositionLOD(sampleUV, MXAO, sampleMIP + 0	);
const float  VdotV            = dot(V, V);
const float  VdotN            = dot(V, N) * rsqrt(VdotV);
#line 515
const float fAO = saturate(1.0 + falloffFactor * VdotV) * saturate(VdotN - MXAO_SAMPLE_NORMAL_BIAS);
#line 527
color.w += fAO;
#line 529
}
#line 531
color = saturate(color/((1.0-MXAO_SAMPLE_NORMAL_BIAS)*MXAO.samples));
color = sqrt(color); 
#line 541
color.w = pow(color.w, MXAO_GAMMA) * MXAO_GAMMA;
}
#line 546
void PS_BlurX(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = BlurFilter(MXAO, ReShade::BackBuffer, MXAO_GLOBAL_RENDER_SCALE, 1.0, 8);
}
#line 551
void PS_BlurYandCombine(MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
float4 aoil = BlurFilter(MXAO, ReShade::BackBuffer, 1.0, 0.75/MXAO_GLOBAL_RENDER_SCALE, 4);
aoil *= aoil; 
#line 556
color                   = tex2D(sMXAO_ColorTex, MXAO.texcoord.xy);
#line 558
const float scenedepth        = GetLinearDepth(MXAO.texcoord.xy);
const float3 lumcoeff         = float3(0.2126, 0.7152, 0.0722);
const float colorgray         = dot(color.rgb,lumcoeff);
const float blendfact         = 1.0 - colorgray;
#line 566
aoil.xyz = 0.0;
#line 569
aoil.w  = 1.0-pow(abs(1.0-aoil.w), MXAO_SSAO_AMOUNT*4.0);
aoil    = lerp(aoil,0.0,smoothstep(MXAO_FADE_DEPTH_START, MXAO_FADE_DEPTH_END, scenedepth * float4(2.0,2.0,2.0,1.0)));
#line 572
if(MXAO_BLEND_TYPE == 0)
{
color.rgb -= (aoil.www - aoil.xyz) * blendfact * color.rgb;
}
else if(MXAO_BLEND_TYPE == 1)
{
color.rgb = color.rgb * saturate(1.0 - aoil.www * blendfact * 1.2) + aoil.xyz * blendfact * colorgray * 2.0;
}
else if(MXAO_BLEND_TYPE == 2)
{
const float colordiff = saturate(2.0 * distance(normalize(color.rgb + 1e-6),normalize(aoil.rgb + 1e-6)));
color.rgb = color.rgb + aoil.rgb * lerp(color.rgb, dot(color.rgb, 0.3333), colordiff) * blendfact * blendfact * 4.0;
color.rgb = color.rgb * (1.0 - aoil.www * (1.0 - dot(color.rgb, lumcoeff)));
}
else if(MXAO_BLEND_TYPE == 3)
{
color.rgb = pow(abs(color.rgb),2.2);
color.rgb -= (aoil.www - aoil.xyz) * color.rgb;
color.rgb = pow(abs(color.rgb),1.0/2.2);
}
#line 593
color.rgb = saturate(color.rgb);
#line 595
if(MXAO_DEBUG_VIEW_ENABLE == 1) 
{
color.rgb = saturate(1.0 - aoil.www + aoil.xyz);
if (0	 != 0)
color.rgb *= 0.5;
else
color.rgb *= 1.0;
}
else if(MXAO_DEBUG_VIEW_ENABLE == 2)
{
color.rgb = GetCullingMask(MXAO);
}
#line 608
color.a = 1.0;
}
#line 615
technique MXAO
{
#line 618
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_InputBufferSetup;
RenderTarget0 = MXAO_ColorTex;
RenderTarget1 = MXAO_DepthTex;
RenderTarget2 = MXAO_NormalTex;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_Culling;
RenderTarget = MXAO_CullingTex;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_StencilSetup;
#line 637
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = REPLACE;
StencilRef = 1;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_AmbientObscurance;
#line 647
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = KEEP;
StencilFunc = EQUAL;
StencilRef = 1;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_BlurX;
#line 658
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_BlurYandCombine;
#line 664
}
}

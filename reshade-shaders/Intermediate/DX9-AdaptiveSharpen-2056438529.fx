#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveSharpen.fx"
#line 31
uniform float curve_height <
ui_type = "slider";
ui_min = 0.01; ui_max = 2.0;
ui_label = "Sharpening strength";
ui_tooltip = "Main control of sharpening strength";
ui_step = 0.01;
> = 1.0;
#line 39
uniform float curveslope <
ui_type = "slider";
ui_min = 0.01; ui_max = 2.0;
ui_tooltip = "Sharpening curve slope, high edge values";
ui_category = "Advanced";
> = 0.5;
#line 46
uniform float L_overshoot <
ui_type = "slider";
ui_min = 0.001; ui_max = 0.1;
ui_tooltip = "Max light overshoot before compression";
ui_category = "Advanced";
> = 0.003;
#line 53
uniform float L_compr_low <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Light compression, default (0.167=~6x)";
ui_category = "Advanced";
> = 0.167;
#line 60
uniform float L_compr_high <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Light compression, surrounded by edges (0.334=~3x)";
ui_category = "Advanced";
> = 0.334;
#line 67
uniform float D_overshoot <
ui_type = "slider";
ui_min = 0.001; ui_max = 0.1;
ui_tooltip = "Max dark overshoot before compression";
ui_category = "Advanced";
> = 0.009;
#line 74
uniform float D_compr_low <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Dark compression, default (0.250=4x)";
ui_category = "Advanced";
> = 0.250;
#line 81
uniform float D_compr_high <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Dark compression, surrounded by edges (0.500=2x)";
ui_category = "Advanced";
> = 0.500;
#line 88
uniform float scale_lim <
ui_type = "slider";
ui_min = 0.01; ui_max = 1.0;
ui_tooltip = "Abs max change before compression";
ui_category = "Advanced";
> = 0.1;
#line 95
uniform float scale_cs <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Compression slope above scale_lim";
ui_category = "Advanced";
> = 0.056;
#line 102
uniform float pm_p <
ui_type = "slider";
ui_min = 0.01; ui_max = 1.0;
ui_tooltip = "Power mean p-value";
ui_category = "Advanced";
> = 0.7;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\AdaptiveSharpen.fx"
#line 117
texture AS_Pass0Tex < pooled = true; > { Width = 1920; Height = 1080; Format = RG16F; };
sampler AS_Pass0Sampler { Texture = AS_Pass0Tex; };
#line 164
float2 AdaptiveSharpenP0(float4 vpos : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 172
const float3 c[13] = { ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, 0) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(-1, -1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, -1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(1, -1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(-1, 0) + tex )).rgb) ),
( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(1, 0) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(-1, 1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, 1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(1, 1) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, -2) + tex )).rgb) ),
( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(-2, 0) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(2, 0) + tex )).rgb) ), ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, 2) + tex )).rgb) ) };
#line 177
const float luma = sqrt(dot(float3(0.2558, 0.6511, 0.0931), ( (c[0])*(c[0]) )));
#line 180
const float3 blur = (2*(c[2]+c[4]+c[5]+c[7]) + (c[1]+c[3]+c[6]+c[8]) + 4*c[0])/16;
#line 183
const float c_comp = saturate(4.0/15.0 + 0.9*exp2(dot(blur, -37.0/15.0)));
#line 192
const float edge = length( 1.38*(( abs(blur - c[0]) ))
+ 1.15*(( abs(blur - c[2]) ) + ( abs(blur - c[4]) )  + ( abs(blur - c[5]) )  + ( abs(blur - c[7]) ))
+ 0.92*(( abs(blur - c[1]) ) + ( abs(blur - c[3]) )  + ( abs(blur - c[6]) )  + ( abs(blur - c[8]) ))
+ 0.23*(( abs(blur - c[9]) ) + ( abs(blur - c[10]) ) + ( abs(blur - c[11]) ) + ( abs(blur - c[12]) )) );
#line 197
return float2(edge*c_comp, luma);
}
#line 200
float3 AdaptiveSharpenP1(float4 vpos : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
float3 origsat = ( saturate(tex2D(ReShade::BackBuffer, ( ReShade::PixelSize*float2(0, 0) + tex )).rgb) );
#line 212
const float2 d[25] = { ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, 0) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-1, -1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, -1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(1, -1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-1, 0) + tex )).xy ),
( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(1, 0) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-1, 1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, 1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(1, 1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, -2) + tex )).xy ),
( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-2, 0) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(2, 0) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, 2) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, 3) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(1, 2) + tex )).xy ),
( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-1, 2) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(3, 0) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(2, 1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(2, -1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-3, 0) + tex )).xy ),
( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-2, 1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-2, -1) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(0, -3) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(1, -2) + tex )).xy ), ( tex2D(AS_Pass0Sampler, ( ReShade::PixelSize*float2(-1, -2) + tex )).xy ) };
#line 1
const float maxedge = ( max(max((max(max(d[1].x,d[2].x),max(d[3].x,d[4].x))), (max(max(d[5].x,d[6].x),max(d[7].x,d[8].x)))), max(
#line 220
(max(max(d[9].x,d[10].x),max(d[11].x,d[12].x))), d[0].x)) );
#line 229
const float sbe = ( saturate((d[2].x + d[9].x + d[22].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )*( saturate((d[7].x + d[12].x + d[13].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )  
+ ( saturate((d[4].x + d[10].x + d[19].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )*( saturate((d[5].x + d[11].x + d[16].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )  
+ ( saturate((d[1].x + d[24].x + d[21].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )*( saturate((d[8].x + d[14].x + d[17].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )  
+ ( saturate((d[3].x + d[23].x + d[18].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) )*( saturate((d[6].x + d[20].x + d[15].x + 0.056)*rcp(abs(maxedge) + 0.03) - 0.85) ); 
#line 235
const float2 cs = lerp( float2(L_compr_low,  D_compr_low),
float2(L_compr_high, D_compr_high), saturate(1.091*sbe - 2.282) );
#line 242
float luma[25] = { d[0].y,  d[1].y,  d[2].y,  d[3].y,  d[4].y,
d[5].y,  d[6].y,  d[7].y,  d[8].y,  d[9].y,
d[10].y, d[11].y, d[12].y, d[13].y, d[14].y,
d[15].y, d[16].y, d[17].y, d[18].y, d[19].y,
d[20].y, d[21].y, d[22].y, d[23].y, d[24].y };
#line 249
const float3 W1 = float3(0.5,           1.0, 1.41421356237); 
const float3 W2 = float3(0.86602540378, 1.0, 0.54772255751); 
#line 254
const float3 dW = ( (lerp(W1,W2,saturate(2.4*d[0].x-0.82)))*(lerp(W1,W2,saturate(2.4*d[0].x-0.82))) );
#line 259
const float mdiff_c0 = 0.02 + 3*( abs(luma[0]-luma[2]) + abs(luma[0]-luma[4])
+ abs(luma[0]-luma[5]) + abs(luma[0]-luma[7])
+ 0.25*(abs(luma[0]-luma[1]) + abs(luma[0]-luma[3])
+abs(luma[0]-luma[6]) + abs(luma[0]-luma[8])) );
#line 266
float weights[12] = { ( min(mdiff_c0/( abs(luma[1] - luma[24]) + abs(luma[1] - luma[21])       + abs(luma[1] - luma[2]) + abs(luma[1] - luma[4])       + 0.5*(abs(luma[1] - luma[9]) + abs(luma[1] - luma[10])) ),  dW.y) ),   
( dW.x ),                                                    
( min(mdiff_c0/( abs(luma[3] - luma[23]) + abs(luma[3] - luma[18])       + abs(luma[3] - luma[5]) + abs(luma[3] - luma[2])       + 0.5*(abs(luma[3] - luma[9]) + abs(luma[3] - luma[11])) ),  dW.y) ),   
( dW.x ),                                                    
( dW.x ),                                                    
( min(mdiff_c0/( abs(luma[6] - luma[4]) + abs(luma[6] - luma[20])       + abs(luma[6] - luma[15]) + abs(luma[6] - luma[7])       + 0.5*(abs(luma[6] - luma[10]) + abs(luma[6] - luma[12])) ),  dW.y) ),   
( dW.x ),                                                    
( min(mdiff_c0/( abs(luma[8] - luma[5]) + abs(luma[8] - luma[7])       + abs(luma[8] - luma[17]) + abs(luma[8] - luma[14])       + 0.5*(abs(luma[8] - luma[12]) + abs(luma[8] - luma[11])) ),  dW.y) ),   
( min(mdiff_c0/( abs(luma[9] - luma[2]) + abs(luma[9] - luma[24])       + abs(luma[9] - luma[23]) + abs(luma[9] - luma[22])       + 0.5*(abs(luma[9] - luma[1]) + abs(luma[9] - luma[3])) ),  dW.z) ),   
( min(mdiff_c0/( abs(luma[10] - luma[20]) + abs(luma[10] - luma[19])       + abs(luma[10] - luma[21]) + abs(luma[10] - luma[4])       + 0.5*(abs(luma[10] - luma[1]) + abs(luma[10] - luma[6])) ), dW.z) ),   
( min(mdiff_c0/( abs(luma[11] - luma[17]) + abs(luma[11] - luma[5])       + abs(luma[11] - luma[18]) + abs(luma[11] - luma[16])       + 0.5*(abs(luma[11] - luma[3]) + abs(luma[11] - luma[8])) ), dW.z) ),   
( min(mdiff_c0/( abs(luma[12] - luma[13]) + abs(luma[12] - luma[15])       + abs(luma[12] - luma[7]) + abs(luma[12] - luma[14])       + 0.5*(abs(luma[12] - luma[6]) + abs(luma[12] - luma[8])) ), dW.z) ) }; 
#line 279
weights[0] = (max(max((weights[8]  + weights[9])/4,  weights[0]), 0.25) + weights[0])/2;
weights[2] = (max(max((weights[8]  + weights[10])/4, weights[2]), 0.25) + weights[2])/2;
weights[5] = (max(max((weights[9]  + weights[11])/4, weights[5]), 0.25) + weights[5])/2;
weights[7] = (max(max((weights[10] + weights[11])/4, weights[7]), 0.25) + weights[7])/2;
#line 285
float lowthrsum   = 0;
float weightsum   = 0;
float neg_laplace = 0;
#line 289
[loop] for (int pix = 0; pix < 12; ++pix)
{
#line 292
const float lowthr = clamp((13.2*d[pix + 1].x - 0.221), 0.01, 1);
#line 294
neg_laplace += ( (luma[pix+1])*(luma[pix+1]) )*(weights[pix]*lowthr);
#line 301
weightsum += weights[pix]*lowthr;
lowthrsum += lowthr/12;
}
#line 306
neg_laplace = sqrt(neg_laplace/weightsum);
#line 312
const float sharpen_val = curve_height/(curve_height*curveslope*pow(abs(d[0].x), 3.5) + 0.625);
#line 315
float sharpdiff = (d[0].y - neg_laplace)*(lowthrsum*sharpen_val + 0.01);
#line 318
[branch] if (abs(sharpdiff) > ( 0.114*pow(( min(abs(L_overshoot), abs(D_overshoot)) ), 0.676) + 3.20e-4 ) )
{
#line 322
{
float temp; int i; int ii;
#line 326
[unroll] for (i = 0; i < 24; i += 2)
{
temp = luma[i];
luma[i]   = min(luma[i], luma[i+1]);
luma[i+1] = max(temp, luma[i+1]);
}
[unroll] for (ii = 24; ii > 0; ii -= 2)
{
temp = luma[0];
luma[0]    = min(luma[0], luma[ii]);
luma[ii]   = max(temp, luma[ii]);
#line 338
temp = luma[24];
luma[24]   = max(luma[24], luma[ii-1]);
luma[ii-1] = min(temp, luma[ii-1]);
}
#line 344
[unroll] for (i = 1; i < 23; i += 2)
{
temp = luma[i];
luma[i]   = min(luma[i], luma[i+1]);
luma[i+1] = max(temp, luma[i+1]);
}
[unroll] for (ii = 23; ii > 1; ii -= 2)
{
temp = luma[1];
luma[1]    = min(luma[1], luma[ii]);
luma[ii]   = max(temp, luma[ii]);
#line 356
temp = luma[23];
luma[23]   = max(luma[23], luma[ii-1]);
luma[ii-1] = min(temp, luma[ii-1]);
}
#line 379
}
#line 383
const float nmax = (max(luma[23], d[0].y)*2 + luma[24])/3;
const float nmin = (min(luma[1],  d[0].y)*2 + luma[0])/3;
#line 386
const float min_dist  = min(abs(nmax - d[0].y), abs(d[0].y - nmin));
float pos_scale = min_dist + L_overshoot;
float neg_scale = min_dist + D_overshoot;
#line 398
pos_scale = min(pos_scale, scale_lim*(1 - scale_cs) + pos_scale*scale_cs);
neg_scale = min(neg_scale, scale_lim*(1 - scale_cs) + neg_scale*scale_cs);
#line 402
sharpdiff = ( pow(abs(cs.x)*pow(abs(max(sharpdiff,0)), pm_p) + abs(1-cs.x)*pow(abs((saturate(abs(max(sharpdiff,0)/pos_scale)*(27+((max(sharpdiff,0)/pos_scale)*(max(sharpdiff,0)/pos_scale)))/(27+9*((max(sharpdiff,0)/pos_scale)*(max(sharpdiff,0)/pos_scale))))*pos_scale)), pm_p), (1.0/pm_p)) )
- ( pow(abs(cs.y)*pow(abs(min(sharpdiff,0)), pm_p) + abs(1-cs.y)*pow(abs((saturate(abs(min(sharpdiff,0)/neg_scale)*(27+((min(sharpdiff,0)/neg_scale)*(min(sharpdiff,0)/neg_scale)))/(27+9*((min(sharpdiff,0)/neg_scale)*(min(sharpdiff,0)/neg_scale))))*neg_scale)), pm_p), (1.0/pm_p)) );
}
#line 407
const float sharpdiff_lim = saturate(d[0].y + sharpdiff) - d[0].y;
const float satmul = (d[0].y + max(sharpdiff_lim*0.9, sharpdiff_lim)*1.03 + 0.03)/(d[0].y + 0.03);
#line 410
return saturate(d[0].y + (sharpdiff_lim*3 + sharpdiff)/4 + (origsat - d[0].y)*satmul);
}
#line 413
technique AdaptiveSharpen
{
pass AdaptiveSharpenPass1
{
VertexShader = PostProcessVS;
PixelShader  = AdaptiveSharpenP0;
RenderTarget = AS_Pass0Tex;
}
#line 422
pass AdaptiveSharpenPass2
{
VertexShader = PostProcessVS;
PixelShader  = AdaptiveSharpenP1;
}
}

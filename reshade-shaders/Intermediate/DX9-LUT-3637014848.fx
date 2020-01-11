#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\LUT.fx"
#line 57
uniform int fLUT_Selector <
ui_type = "combo";
ui_items = "GShade/Angelite\0LUT - Warm.fx\0Autumn\0ninjafada Gameplay\0ReShade 3/4\0Sleeps_Hungry\0Feli\0";
ui_label = "The LUT file to use.";
ui_tooltip = "Set this to whichever your preset requires!";
> = 0;
#line 64
uniform float fLUT_AmountChroma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT chroma amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 71
uniform float fLUT_AmountLuma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT luma amount";
ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\LUT.fx"
#line 83
texture texLUT < source = "lut_GShade.png" ; > { Width = 32*32; Height = 32; Format = RGBA8; };
sampler	SamplerLUT 	{ Texture = texLUT; };
#line 86
texture texLUTwarm < source = "lut_warm.png" ; > { Width = 64*64; Height = 64; Format = RGBA8; };
sampler	SamplerLUTwarm 	{ Texture = texLUTwarm; };
#line 89
texture texLUTautumn < source = "lut.png" ; > { Width = 32*32; Height = 32; Format = RGBA8; };
sampler	SamplerLUTautumn 	{ Texture = texLUTautumn; };
#line 92
texture texLUTNFG < source = "lut_ninjafadaGameplay.png" ; > { Width = 32*32; Height = 32; Format = RGBA8; };
sampler	SamplerLUTNFG 	{ Texture = texLUTNFG; };
#line 95
texture texLUTRS < source = "lut_ReShade.png" ; > { Width = 32*32; Height = 32; Format = RGBA8; };
sampler	SamplerLUTRS 	{ Texture = texLUTRS; };
#line 98
texture texLUTSL < source = "lut_Sleepy.png" ; > { Width = 64*64; Height = 64; Format = RGBA8; };
sampler	SamplerLUTSL 	{ Texture = texLUTSL; };
#line 101
texture texLUTFE < source = "lut_Feli.png" ; > { Width = 32*32; Height = 32; Format = RGBA8; };
sampler	SamplerLUTFE 	{ Texture = texLUTFE; };
#line 108
void PS_LUT_Apply(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
float4 color = tex2D(ReShade::BackBuffer, texcoord.xy);
#line 113
if (fLUT_Selector == 0)
{
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 118
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 122
const float3 lutcolor = lerp(tex2D(SamplerLUT, lutcoord.xy).xyz, tex2D(SamplerLUT, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 124
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 127
res.xyz = color.xyz;
res.w = 1.0;
}
#line 132
else if (fLUT_Selector == 1)
{
float2 texelsize = 1.0 / 64;
texelsize.x /= 64;
#line 137
float3 lutcoord = float3((color.xy*64-color.xy+0.5)*texelsize.xy,color.z*64-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 141
const float3 lutcolor = lerp(tex2D(SamplerLUTwarm, lutcoord.xy).xyz, tex2D(SamplerLUTwarm, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 143
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 146
res.xyz = color.xyz;
res.w = 1.0;
}
#line 151
else if (fLUT_Selector == 2)
{
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 156
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 160
const float3 lutcolor = lerp(tex2D(SamplerLUTautumn, lutcoord.xy).xyz, tex2D(SamplerLUTautumn, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 162
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 165
res.xyz = color.xyz;
res.w = 1.0;
}
#line 170
else if (fLUT_Selector == 3)
{
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 175
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 179
const float3 lutcolor = lerp(tex2D(SamplerLUTNFG, lutcoord.xy).xyz, tex2D(SamplerLUTNFG, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 181
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 184
res.xyz = color.xyz;
res.w = 1.0;
}
else if (fLUT_Selector == 4)
{
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 192
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 196
const float3 lutcolor = lerp(tex2D(SamplerLUTRS, lutcoord.xy).xyz, tex2D(SamplerLUTRS, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 198
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 201
res.xyz = color.xyz;
res.w = 1.0;
}
else if (fLUT_Selector == 5)
{
float2 texelsize = 1.0 / 64;
texelsize.x /= 64;
#line 209
float3 lutcoord = float3((color.xy*64-color.xy+0.5)*texelsize.xy,color.z*64-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 213
const float3 lutcolor = lerp(tex2D(SamplerLUTSL, lutcoord.xy).xyz, tex2D(SamplerLUTSL, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 215
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 218
res.xyz = color.xyz;
res.w = 1.0;
}
#line 222
else
{
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 227
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 231
const float3 lutcolor = lerp(tex2D(SamplerLUTFE, lutcoord.xy).xyz, tex2D(SamplerLUTFE, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);
#line 233
color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);
#line 236
res.xyz = color.xyz;
res.w = 1.0;
}
}
#line 246
technique LUT
{
pass LUT_Apply
{
VertexShader = PostProcessVS;
PixelShader = PS_LUT_Apply;
}
}

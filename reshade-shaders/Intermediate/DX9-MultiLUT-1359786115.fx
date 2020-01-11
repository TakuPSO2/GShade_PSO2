#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MultiLUT.fx"
#line 80
uniform int fLUT_MultiLUTSelector <
ui_category = "Pass 1";
ui_type = "combo";
ui_items = "GShade [Angelite-Compatible]\0ReShade 4\0ReShade 3\0Johto\0Espresso Glow\0Faeshade/Dark Veil/HQ Shade/MoogleShade\0ninjafada Gameplay\0seri14\0Yomi\0Neneko\0";
ui_label = "The MultiLUT file to use.";
ui_tooltip = "Set this to whatever build your preset was made with!";
> = 0;
#line 88
uniform int fLUT_LutSelector <
ui_category = "Pass 1";
ui_type = "combo";
ui_items = "Color0 (Usually Neutral)\0Color1\0Color2\0Color3\0Color4\0Color5\0Color6\0Color7\0Color8\0Color9\0Color10 | Colors above 10\0Color11 | may not work for\0Color12 | all MultiLUT files.\0Color13\0Color14\0Color15\0Color16\0Color17\0";
ui_label = "LUT to use. Names may not be accurate.";
ui_tooltip = "LUT to use for color transformation. ReShade 4's 'Neutral' doesn't do any color transformation.";
> = 0;
#line 96
uniform float fLUT_Intensity <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Intensity";
ui_tooltip = "Overall intensity of the LUT effect.";
> = 1.00;
#line 104
uniform float fLUT_AmountChroma <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Chroma Amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 112
uniform float fLUT_AmountLuma <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Luma Amount";
ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;
#line 120
uniform bool fLUT_MultiLUTPass2 <
ui_category = "Pass 2";
ui_label = "Enable Pass 2";
> = 0;
#line 125
uniform int fLUT_MultiLUTSelector2 <
ui_category = "Pass 2";
ui_type = "combo";
ui_items = "GShade [Angelite-Compatible]\0ReShade 4\0ReShade 3\0Johto\0Espresso Glow\0Faeshade/Dark Veil/HQ Shade/MoogleShade\0ninjafada Gameplay\0seri14\0Yomi\0Neneko\0";
ui_label = "The MultiLUT file to use.";
ui_tooltip = "The MultiLUT table to use on Pass 2.";
> = 1;
#line 133
uniform int fLUT_LutSelector2 <
ui_category = "Pass 2";
ui_type = "combo";
ui_items = "Color0 (Usually Neutral)\0Color1\0Color2\0Color3\0Color4\0Color5\0Color6\0Color7\0Color8\0Color9\0Color10 | Colors above 10\0Color11 | may not work for\0Color12 | all MultiLUT files.\0Color13\0Color14\0Color15\0Color16\0Color17\0";
ui_label = "LUT to use. Names may not be accurate.";
ui_tooltip = "LUT to use for color transformation on Pass 2. ReShade 4's 'Neutral' doesn't do any color transformation.";
> = 0;
#line 141
uniform float fLUT_Intensity2 <
ui_category = "Pass 2";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Intensity";
ui_tooltip = "Overall intensity of the LUT effect.";
> = 1.00;
#line 149
uniform float fLUT_AmountChroma2 <
ui_category = "Pass 2";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Chroma Amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 157
uniform float fLUT_AmountLuma2 <
ui_category = "Pass 2";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Luma Amount";
ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;
#line 165
uniform bool fLUT_MultiLUTPass3 <
ui_category = "Pass 3";
ui_label = "Enable Pass 3";
> = 0;
#line 170
uniform int fLUT_MultiLUTSelector3 <
ui_category = "Pass 3";
ui_type = "combo";
ui_items = "GShade [Angelite-Compatible]\0ReShade 4\0ReShade 3\0Johto\0Espresso Glow\0Faeshade/Dark Veil/HQ Shade/MoogleShade\0ninjafada Gameplay\0seri14\0Yomi\0Neneko\0";
ui_label = "The MultiLUT file to use.";
ui_tooltip = "The MultiLUT table to use on Pass 3.";
> = 1;
#line 178
uniform int fLUT_LutSelector3 <
ui_category = "Pass 3";
ui_type = "combo";
ui_items = "Color0 (Usually Neutral)\0Color1\0Color2\0Color3\0Color4\0Color5\0Color6\0Color7\0Color8\0Color9\0Color10 | Colors above 10\0Color11 | may not work for\0Color12 | all MultiLUT files.\0Color13\0Color14\0Color15\0Color16\0Color17\0";
ui_label = "LUT to use. Names may not be accurate.";
ui_tooltip = "LUT to use for color transformation on Pass 3. ReShade 4's 'Neutral' doesn't do any color transformation.";
> = 0;
#line 186
uniform float fLUT_Intensity3 <
ui_category = "Pass 3";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Intensity";
ui_tooltip = "Overall intensity of the LUT effect.";
> = 1.00;
#line 194
uniform float fLUT_AmountChroma3 <
ui_category = "Pass 3";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Chroma Amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 202
uniform float fLUT_AmountLuma3 <
ui_category = "Pass 3";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Luma Amount";
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\MultiLUT.fx"
#line 216
texture texGSMultiLUT < source = "MultiLut_GShade.png" ; > { Width = 32 * 32; Height = 32 * 17; Format = RGBA8; };
sampler SamplerGSMultiLUT { Texture = texGSMultiLUT; };
#line 219
texture texRESMultiLUT < source = "MultiLut_atlas4.png" ; > { Width = 32 * 32; Height = 32 * 17; Format = RGBA8; };
sampler SamplerRESMultiLUT { Texture = texRESMultiLUT; };
#line 222
texture texJOHMultiLUT < source = "MultiLut_Johto.png" ; > { Width = 32 * 32; Height = 32 * 18; Format = RGBA8; };
sampler SamplerJOHMultiLUT { Texture = texJOHMultiLUT; };
#line 225
texture texEGMultiLUT < source = "FFXIVLUTAtlas.png" ; > { Width = 32 * 32; Height = 32 * 17; Format = RGBA8; };
sampler SamplerEGMultiLUT { Texture = texEGMultiLUT; };
#line 228
texture texMSMultiLUT < source = "TMP_MultiLUT.png" ; > { Width = 32 * 32; Height = 32 * 12; Format = RGBA8; };
sampler SamplerMSMultiLUT { Texture = texMSMultiLUT; };
#line 231
texture texNFGMultiLUT < source = "MultiLut_ninjafadaGameplay.png" ; > { Width = 32 * 32; Height = 32 * 12; Format = RGBA8; };
sampler SamplerNFGMultiLUT { Texture = texNFGMultiLUT; };
#line 234
texture texS14MultiLUT < source = "MultiLut_seri14.png" ; > { Width = 32 * 32; Height = 32 * 11; Format = RGBA8; };
sampler SamplerS14MultiLUT { Texture = texS14MultiLUT; };
#line 237
texture texYOMMultiLUT < source = "MultiLut_Yomi.png" ; > { Width = 32 * 32; Height = 32 * 12; Format = RGBA8; };
sampler SamplerYOMMultiLUT { Texture = texYOMMultiLUT; };
#line 240
texture texNENMultiLUT < source = "MultiLut_Neneko.png" ; > { Width = 32 * 32; Height = 32 * 12; Format = RGBA8; };
sampler SamplerNENMultiLUT { Texture = texNENMultiLUT; };
#line 247
float4 apply(in const float4 color, in const int tex, in const float lut)
{
float lerpfact;
const float2 texelsize = 1.0 / float2(32 * 32, 32);
float3 lutcoord;
float4 lutcolor;
#line 254
lutcoord.xy = (color.xy * 32 - color.xy + 0.5) * texelsize;
lutcoord.z  = (color.z  * 32 - color.z);
#line 257
lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z - lerpfact) * texelsize.y;
#line 261
if (tex == 0)
{
lutcoord.y = lut / 17 + lutcoord.y / 17;
lutcolor   = lerp(tex2D(SamplerGSMultiLUT, lutcoord.xy), tex2D(SamplerGSMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 267
else if (tex == 1)
{
lutcoord.y = lut / 17 + lutcoord.y / 17;
lutcolor = lerp(tex2D(SamplerRESMultiLUT, lutcoord.xy), tex2D(SamplerRESMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 273
else if (tex == 2)
{
lutcoord.y = lut / 17 + lutcoord.y / 17;
lutcolor   = lerp(tex2D(SamplerRESMultiLUT, lutcoord.xy), tex2D(SamplerRESMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 279
else if (tex == 3)
{
lutcoord.y = lut / 18 + lutcoord.y / 18;
lutcolor   = lerp(tex2D(SamplerJOHMultiLUT, lutcoord.xy), tex2D(SamplerJOHMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 285
else if (tex == 4)
{
lutcoord.y = lut / 17 + lutcoord.y / 17;
lutcolor   = lerp(tex2D(SamplerEGMultiLUT, lutcoord.xy), tex2D(SamplerEGMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 291
else if (tex == 5)
{
lutcoord.y = lut / 12 + lutcoord.y / 12;
lutcolor   = lerp(tex2D(SamplerMSMultiLUT, lutcoord.xy), tex2D(SamplerMSMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 297
else if (tex == 6)
{
lutcoord.y = lut / 12 + lutcoord.y / 12;
lutcolor   = lerp(tex2D(SamplerNFGMultiLUT, lutcoord.xy), tex2D(SamplerNFGMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 303
else if (tex == 7)
{
lutcoord.y = lut / 11 + lutcoord.y / 11;
lutcolor   = lerp(tex2D(SamplerS14MultiLUT, lutcoord.xy), tex2D(SamplerS14MultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 309
else if (tex == 8)
{
lutcoord.y = lut / 12 + lutcoord.y / 12;
lutcolor   = lerp(tex2D(SamplerYOMMultiLUT, lutcoord.xy), tex2D(SamplerYOMMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 315
else
{
lutcoord.y = lut / 12 + lutcoord.y / 12;
lutcolor   = lerp(tex2D(SamplerNENMultiLUT, lutcoord.xy), tex2D(SamplerNENMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)), lerpfact);
}
#line 321
lutcolor.a = color.a;
return lutcolor;
}
#line 325
void PS_MultiLUT_Apply(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target)
{
const float4 color = tex2D(ReShade::BackBuffer, texcoord);
#line 333
float4 lutcolor = lerp(color, apply(color, fLUT_MultiLUTSelector, fLUT_LutSelector), fLUT_Intensity);
#line 335
res = lerp(normalize(color), normalize(lutcolor), fLUT_AmountChroma)
* lerp(   length(color),    length(lutcolor),   fLUT_AmountLuma);
#line 342
if (fLUT_MultiLUTPass2)
{
res = saturate(res);
lutcolor = lerp(res, apply(res, fLUT_MultiLUTSelector2, fLUT_LutSelector2), fLUT_Intensity2);
#line 347
res = lerp(normalize(res), normalize(lutcolor), fLUT_AmountChroma2)
* lerp(   length(res),    length(lutcolor),   fLUT_AmountLuma2);
}
#line 355
if (fLUT_MultiLUTPass3)
{
res = saturate(res);
lutcolor = lerp(res, apply(res, fLUT_MultiLUTSelector3, fLUT_LutSelector3), fLUT_Intensity3);
#line 360
res = lerp(normalize(res), normalize(lutcolor), fLUT_AmountChroma3)
* lerp(   length(res),    length(lutcolor),   fLUT_AmountLuma3);
}
}
#line 369
technique MultiLUT
{
pass MultiLUT_Apply
{
VertexShader = PostProcessVS;
PixelShader = PS_MultiLUT_Apply;
}
}

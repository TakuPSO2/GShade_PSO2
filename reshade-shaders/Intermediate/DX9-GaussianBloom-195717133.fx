#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GaussianBloom.fx"
#line 11
uniform int GaussianBloomRadius
<
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "Adjustment for the bloom radius. Values greater than 1.00 will increase the radius.";
> = 2;
#line 18
uniform float GaussianBloomOffset
<
ui_type = "slider";
ui_min = 1.00; ui_max = 10.00;
ui_tooltip = "Additional adjustment for the bloom radius. Values greater than 1.00 will increase the radius.";
ui_step = 0.20;
> = 2.00;
#line 26
uniform float Threshold
<
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_tooltip = "";
> = 0.800;
#line 33
uniform float3 BloomTint <
ui_type = "color";
> = float3(1.0,1.0,1.0);
#line 37
uniform float Exposure
<
ui_type = "slider";
ui_min = 1.000; ui_max = 20.000;
ui_tooltip = "";
> = 3.50;
#line 44
uniform float GaussianBloomSaturation
<
ui_type = "slider";
ui_min = 0.00; ui_max = 2.00;
ui_tooltip = "";
> = 0.500;
#line 51
uniform float DitherStrength
<
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "";
> = 1.00;
#line 58
uniform float GaussianBloomStrength
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect";
> = 0.30;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GaussianBloom.fx"
#line 67
texture GaussianBloomTex { Width = 1920*0.5; Height = 1080*0.5; Format = RGBA8; };
texture GaussianBloomTex2 { Width = 1920*0.5; Height = 1080*0.5; Format = RGBA8; };
#line 70
sampler GaussianBloomSampler { Texture = GaussianBloomTex; AddressW = BORDER; AddressU = BORDER; AddressV = BORDER;};
sampler GaussianBloomSampler2 { Texture = GaussianBloomTex2; AddressW = BORDER; AddressU = BORDER; AddressV = BORDER;};
#line 73
float3 GaussianBloomFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 76
float3 blur = tex2D(GaussianBloomSampler, texcoord / GaussianBloomOffset).rgb;
#line 78
blur.rgb = lerp(dot(blur.rgb,0.333333),blur.rgb,GaussianBloomSaturation);
#line 80
if(DitherStrength)
{
const float sine = sin(dot(texcoord, float2(12.9898,78.233)));
const float noise = frac(sine * 43758.5453 + texcoord.x) * 0.012 - 0.006;
blur.rgb += (float3(-noise, noise, -noise)*DitherStrength);
}
#line 87
float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
orig = lerp(orig, (1.0 - ((1.0 - orig) * (1.0 - blur))), GaussianBloomStrength);
#line 90
return saturate(orig);
}
#line 93
float3 GaussianBloomBrightPass(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 96
float3 color = tex2D( ReShade::BackBuffer, texcoord * GaussianBloomOffset).rgb;
#line 98
color.rgb *= ( 1.0f + ( color.rgb / ( Threshold * Threshold )) );
color.rgb *= Exposure;
color.rgb -= (5.0f);
#line 102
color.rgb = max( color.rgb, 0.0f );
#line 106
color.rgb *= BloomTint;
#line 108
return color;
}
#line 111
float3 GaussianBloom1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 114
float3 blur = tex2D(GaussianBloomSampler, texcoord).rgb;
#line 116
if(GaussianBloomRadius == 0)
{
float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 121
blur *= weight[0];
#line 123
[loop]
for(int i = 1; i < 4; ++i)
{
blur += tex2D(GaussianBloomSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
}
}
#line 131
if(GaussianBloomRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 136
blur *= weight[0];
#line 138
[loop]
for(int i = 1; i < 6; ++i)
{
blur += tex2D(GaussianBloomSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
}
}
#line 146
if(GaussianBloomRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 151
blur *= weight[0];
#line 153
[loop]
for(int i = 1; i < 11; ++i)
{
blur += tex2D(GaussianBloomSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
}
}
#line 161
if(GaussianBloomRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 166
blur *= weight[0];
#line 168
[loop]
for(int i = 1; i < 15; ++i)
{
blur += tex2D(GaussianBloomSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
}
}
#line 176
if(GaussianBloomRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 181
blur *= weight[0];
#line 183
[loop]
for(int i = 1; i < 18; ++i)
{
blur += tex2D(GaussianBloomSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y)).rgb * weight[i];
}
}
#line 191
return (blur);
}
#line 194
float3 GaussianBloom2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 197
float3 blur = tex2D(GaussianBloomSampler2, texcoord).rgb;
#line 199
if(GaussianBloomRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 204
blur *= weight[0];
#line 206
[loop]
for(int i = 1; i < 6; ++i)
{
blur += tex2D(GaussianBloomSampler2, texcoord + float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler2, texcoord - float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
}
}
#line 214
if(GaussianBloomRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 219
blur *= weight[0];
#line 221
[loop]
for(int i = 1; i < 11; ++i)
{
blur += tex2D(GaussianBloomSampler2, texcoord + float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler2, texcoord - float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
}
}
#line 229
if(GaussianBloomRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 234
blur *= weight[0];
#line 236
[loop]
for(int i = 1; i < 15; ++i)
{
blur += tex2D(GaussianBloomSampler2, texcoord + float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler2, texcoord - float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
}
}
#line 244
if(GaussianBloomRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 249
blur *= weight[0];
#line 251
[loop]
for(int i = 1; i < 18; ++i)
{
blur += tex2D(GaussianBloomSampler2, texcoord + float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
blur += tex2D(GaussianBloomSampler2, texcoord - float2( offset[i] * ReShade::PixelSize.x,0.0)).rgb * weight[i];
}
}
return (blur);
}
#line 261
technique GaussianBloom
{
pass BrightPass
{
VertexShader = PostProcessVS;
PixelShader = GaussianBloomBrightPass;
RenderTarget = GaussianBloomTex;
}
#line 270
pass Bloom1
{
VertexShader = PostProcessVS;
PixelShader = GaussianBloom1;
RenderTarget = GaussianBloomTex2;
}
#line 277
pass Bloom2
{
VertexShader = PostProcessVS;
PixelShader = GaussianBloom2;
RenderTarget = GaussianBloomTex;
}
#line 284
pass Bloom
{
VertexShader = PostProcessVS;
PixelShader = GaussianBloomFinal;
}
#line 290
}

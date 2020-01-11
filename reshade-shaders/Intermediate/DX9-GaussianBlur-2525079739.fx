#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GaussianBlur.fx"
#line 7
uniform int GaussianBlurRadius <
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "[0|1|2|3|4] Adjusts the blur radius. Higher values increase the radius";
> = 1;
#line 13
uniform float GaussianBlurOffset <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Additional adjustment for the blur radius. Values less than 1.00 will reduce the radius.";
> = 1.00;
#line 19
uniform float GaussianBlurStrength <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect.";
> = 0.300;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\GaussianBlur.fx"
#line 27
texture GaussianBlurTex < pooled = true; > { Width = 1920; Height = 1080; Format = RGBA8; };
sampler GaussianBlurSampler { Texture = GaussianBlurTex;};
#line 30
float3 GaussianBlurFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 33
float3 color = tex2D(GaussianBlurSampler, texcoord).rgb;
#line 35
if(GaussianBlurRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 40
color *= weight[0];
#line 42
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2D(GaussianBlurSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(GaussianBlurSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 50
if(GaussianBlurRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 55
color *= weight[0];
#line 57
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2D(GaussianBlurSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(GaussianBlurSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 65
if(GaussianBlurRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 70
color *= weight[0];
#line 72
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2D(GaussianBlurSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(GaussianBlurSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 80
if(GaussianBlurRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 85
color *= weight[0];
#line 87
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2D(GaussianBlurSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(GaussianBlurSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 95
if(GaussianBlurRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 100
color *= weight[0];
#line 102
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2D(GaussianBlurSampler, texcoord + float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(GaussianBlurSampler, texcoord - float2(0.0, offset[i] * ReShade::PixelSize.y) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 110
float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
orig = lerp(orig, color, GaussianBlurStrength);
#line 113
return saturate(orig);
}
#line 116
float3 GaussianBlur1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 119
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 121
if(GaussianBlurRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 126
color *= weight[0];
#line 128
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2D(ReShade::BackBuffer, texcoord + float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(ReShade::BackBuffer, texcoord - float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 136
if(GaussianBlurRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 141
color *= weight[0];
#line 143
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2D(ReShade::BackBuffer, texcoord + float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(ReShade::BackBuffer, texcoord - float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 151
if(GaussianBlurRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 156
color *= weight[0];
#line 158
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2D(ReShade::BackBuffer, texcoord + float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(ReShade::BackBuffer, texcoord - float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 166
if(GaussianBlurRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 171
color *= weight[0];
#line 173
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2D(ReShade::BackBuffer, texcoord + float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(ReShade::BackBuffer, texcoord - float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
}
}
#line 181
if(GaussianBlurRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 186
color *= weight[0];
#line 188
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2D(ReShade::BackBuffer, texcoord + float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
color += tex2D(ReShade::BackBuffer, texcoord - float2(offset[i] * ReShade::PixelSize.x, 0.0) * GaussianBlurOffset).rgb * weight[i];
}
}
return saturate(color);
}
#line 198
technique GaussianBlur
{
pass Blur1
{
VertexShader = PostProcessVS;
PixelShader = GaussianBlur1;
RenderTarget = GaussianBlurTex;
}
pass BlurFinal
{
VertexShader = PostProcessVS;
PixelShader = GaussianBlurFinal;
}
}

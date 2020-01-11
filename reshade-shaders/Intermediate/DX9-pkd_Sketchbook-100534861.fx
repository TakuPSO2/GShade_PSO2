#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\pkd_Sketchbook.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\pkd_Sketchbook.fx"
#line 55
uniform float fMask_Intensity <
ui_type = "slider";
ui_label = "Mask Intensity";
ui_tooltip = "How much should the paper obscure the pencil drawing.";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 64
uniform bool bDisplayMask <
ui_label = "Display Mask";
ui_tooltip =
"Display the mask texture.\n"
"Useful for checking if you replace the mask image.";
> = false;
#line 71
uniform int iMask_Select <
ui_label = "Mask Style";
ui_tooltip = "What should the edges of this sketch look like?";
ui_type = "combo";
ui_items = "Rough\0Smooth";
> = 0;
#line 84
texture tSketchMask_Backup { Width = 1920; Height = 1080; };
#line 86
texture tSketchMask_Mask <source="SketchMask.png";> { Width = 1920; Height = 1080; Format=R8; };
texture tSketchMask_Mask2 <source="SketchMask2.png";> { Width = 1920; Height = 1080; Format=R8; };
#line 89
sampler sSketchMask_Mask { Texture = tSketchMask_Mask; };
sampler sSketchMask_Mask2 { Texture = tSketchMask_Mask2; };
sampler sSketchMask_Backup { Texture = tSketchMask_Backup; };
#line 93
float4 PS_Backup(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target {
return tex2D(ReShade::BackBuffer, uv);
}
#line 97
float CalculateMask(sampler maskSampler, float2 uv)
{
#line 100
return tex2D(maskSampler, uv).r;
#line 106
}
#line 108
float4 PS_ApplyMask(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target {
#line 110
float mask = 0.0;
#line 112
if (iMask_Select == 0)
{
mask = CalculateMask(sSketchMask_Mask, uv);
}
else if (iMask_Select == 1)
{
mask = CalculateMask(sSketchMask_Mask2, uv);
}
#line 121
mask = lerp(1.0, mask, fMask_Intensity);
float3 col = lerp(tex2D(sSketchMask_Backup, uv).rgb, tex2D(ReShade::BackBuffer, uv).rgb, mask);
if (bDisplayMask)
col = mask;
#line 126
return float4(col, 1.0);
}
#line 129
technique pkd_Sketch_MaskCopy {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Backup;
RenderTarget = tSketchMask_Backup;
}
}
#line 137
technique pkd_Sketch_MaskApply {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_ApplyMask;
}
}
#line 150
uniform float Layer_PencilHatch_Blend <
ui_label = "Pencil Hatch Opacity";
ui_tooltip = "The transparency of the pencil hatching layer.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 159
uniform float Layer_PencilHatch_Scale <
ui_type = "slider";
ui_label = "Pencil Hatch Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 166
uniform float Layer_PencilHatch_PosX <
ui_type = "slider";
ui_label = "Pencil Hatch Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 173
uniform float Layer_PencilHatch_PosY <
ui_type = "slider";
ui_label = "Pencil Hatch Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 180
texture Layer_PencilHatch_texture <source="SketchPencil.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Layer_PencilHatch_sampler { Texture = Layer_PencilHatch_texture; };
#line 183
void PS_Layer_PencilHatch(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 Layer_Pos = float2(Layer_PencilHatch_PosX, Layer_PencilHatch_PosY);
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_PencilHatch_Scale);
const float4 Layer  = tex2D(Layer_PencilHatch_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_PencilHatch_Blend);
color.a = backbuffer.a;
}
#line 192
technique pkd_Sketch_Pencil {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Layer_PencilHatch;
}
}
#line 200
uniform float Layer_PaperBase_Blend <
ui_label = "Paper Base Opacity";
ui_tooltip = "The transparency of the paper base layer.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 209
uniform float Layer_PaperBase_Scale <
ui_type = "slider";
ui_label = "Paper Base Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 216
uniform float Layer_PaperBase_PosX <
ui_type = "slider";
ui_label = "Paper Base Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 223
uniform float Layer_PaperBase_PosY <
ui_type = "slider";
ui_label = "Paper Base Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 230
texture Layer_PaperBase_texture <source="SketchPaperBase.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Layer_PaperBase_sampler { Texture = Layer_PaperBase_texture; };
#line 233
void PS_Layer_PaperBase(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 Layer_Pos = float2(Layer_PaperBase_PosX, Layer_PaperBase_PosY);
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_PaperBase_Scale);
const float4 Layer  = tex2D(Layer_PaperBase_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_PaperBase_Blend);
color.a = backbuffer.a;
}
#line 242
technique pkd_Sketch_PaperBase {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Layer_PaperBase;
}
}
#line 250
uniform float Layer_PaperOverlay_Blend <
ui_label = "Paper Texture Opacity";
ui_tooltip = "The transparency of the paper texture layer.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 259
uniform float Layer_PaperOverlay_Scale <
ui_type = "slider";
ui_label = "Paper Texture Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 266
uniform float Layer_PaperOverlay_PosX <
ui_type = "slider";
ui_label = "Paper Texture Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 273
uniform float Layer_PaperOverlay_PosY <
ui_type = "slider";
ui_label = "Paper Texture Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 280
texture Layer_PaperOverlay_texture <source="SketchPaperOverlay.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Layer_PaperOverlay_sampler { Texture = Layer_PaperOverlay_texture; };
#line 283
void PS_Layer_PaperOverlay(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 Layer_Pos = float2(Layer_PaperOverlay_PosX, Layer_PaperOverlay_PosY);
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_PaperOverlay_Scale);
const float4 Layer  = tex2D(Layer_PaperOverlay_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_PaperOverlay_Blend);
color.a = backbuffer.a;
}
#line 292
technique pkd_Sketch_PaperOverlay {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Layer_PaperOverlay;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Layer.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Layer.fx"
#line 33
uniform int Layer_Select <
ui_label = "Layer Selection";
ui_tooltip = "The image/texture you'd like to use.";
ui_type = "combo";
ui_items= "Angelite Layer.png | ReShade 3/4 LensDB.png\0LensDB.png (Angelite)\0Dirt.png (Angelite)\0Dirt.png (ReShade 4)\0Dirt.jpg (ReShade 3)\0";
> = 0;
#line 40
uniform float Layer_Blend <
ui_label = "Opacity";
ui_tooltip = "The transparency of the layer.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 49
uniform float Layer_Scale <
ui_type = "slider";
ui_label = "Scale";
ui_min = 0.01; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 56
uniform float Layer_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 63
uniform float Layer_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 70
texture Layer_texture <source="LayerA.png" ;> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Layer_sampler { Texture = Layer_texture; };
#line 73
texture LensDB_angel_texture <source="LensDBA.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler LensDB_angel_sampler { Texture = LensDB_angel_texture; };
#line 76
texture Dirt_png_texture <source="DirtA.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Dirt_png_sampler { Texture = Dirt_png_texture; };
#line 79
texture Dirt_four_texture <source="Dirt4.png";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Dirt_four_sampler { Texture = Dirt_four_texture; };
#line 82
texture Dirt_jpg_texture <source="Dirt3.jpg";> { Width = 1920; Height = 1080; Format=RGBA8; };
sampler Dirt_jpg_sampler { Texture = Dirt_jpg_texture; };
#line 85
void PS_Layer(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
const float2 Layer_Pos = float2(Layer_PosX, Layer_PosY);
if (Layer_Select == 0)
{
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Scale);
const float4 Layer  = tex2D(Layer_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Blend);
}
else if (Layer_Select == 1)
{
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Scale);
const float4 Layer  = tex2D(LensDB_angel_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Blend);
}
else if (Layer_Select == 2)
{
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Scale);
const float4 Layer  = tex2D(Dirt_png_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Blend);
}
else if (Layer_Select == 3)
{
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Scale);
const float4 Layer  = tex2D(Dirt_four_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Blend);
}
else
{
const float2 scale = 1.0 / (float2(1920, 1080) / ReShade::ScreenSize * Layer_Scale);
const float4 Layer  = tex2D(Dirt_jpg_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
color = lerp(backbuffer, Layer, Layer.a * Layer_Blend);
}
color.a = backbuffer.a;
}
#line 121
technique Layer {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Layer;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Splitscreen.fx"
#line 35
uniform int splitscreen_mode <
ui_type = "combo";
ui_label = "Mode";
ui_tooltip = "Choose a mode";
#line 40
ui_items =
"Vertical 50/50 split\0"
"Vertical 25/50/25 split\0"
"Angled 50/50 split\0"
"Angled 25/50/25 split\0"
"Horizontal 50/50 split\0"
"Horizontal 25/50/25 split\0"
"Diagonal split\0"
;
> = 0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Splitscreen.fx"
#line 62
texture Before { Width = 1920; Height = 1080; };
sampler Before_sampler { Texture = Before; };
#line 70
float4 PS_Before(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D(ReShade::BackBuffer, texcoord);
}
#line 75
float4 PS_After(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color;
#line 80
[branch] if (splitscreen_mode == 0)
color = (texcoord.x < 0.5 ) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
#line 84
[branch] if (splitscreen_mode == 1)
{
#line 87
float dist = abs(texcoord.x - 0.5);
#line 90
dist = saturate(dist - 0.25);
#line 92
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 96
[branch] if (splitscreen_mode == 2)
{
#line 99
float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));
#line 102
dist = saturate(dist - 0.25);
#line 104
color = dist ? tex2D(ReShade::BackBuffer, texcoord) : tex2D(Before_sampler, texcoord);
}
#line 108
[branch] if (splitscreen_mode == 3)
{
#line 111
float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));
#line 113
dist = abs(dist - 0.25);
#line 116
dist = saturate(dist - 0.25);
#line 118
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 122
[branch] if (splitscreen_mode == 4)
color =  (texcoord.y < 0.5) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
#line 126
[branch] if (splitscreen_mode == 5)
{
#line 129
float dist = abs(texcoord.y - 0.5);
#line 132
dist = saturate(dist - 0.25);
#line 134
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 138
[branch] if (splitscreen_mode == 6)
{
#line 141
float dist = (texcoord.x + texcoord.y);
#line 146
color = (dist < 1.0) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 149
return color;
}
#line 157
technique Before
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Before;
RenderTarget = Before;
}
}
#line 167
technique After
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_After;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Pirate_FXAA.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Pirate_FXAA.fx"
#line 5
uniform float FXAA_RADIUS <
ui_label = "FXAA - Radius";
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_tooltip = "Try to keep close to 1.0.";
> = 1.0;
uniform float FXAA_STRENGTH <
ui_label = "FXAA - Strength";
ui_type = "slider";
ui_min = 0.0001; ui_max = 1.0;
ui_tooltip = "Self Explanatory.";
> = 1.0;
uniform bool FXAA_DEBUG <
ui_label = "FXAA - Debug";
ui_tooltip = "Shows which area of the screen is being blurred.";
> = false;
#line 25
float4 FastFXAA(float4 colorIN : COLOR, float2 coord : TEXCOORD) : COLOR {
const float2 tap[8] = {
float2(1.0, 0.0),
float2(-1.0, 0.0),
float2(0.0, 1.0),
float2(0.0, -1.0),
float2(-1.0, -1.0),
float2( 1.0, -1.0),
float2( 1.0,  1.0),
float2(-1.0,  1.0)
};
float4 ret;
float edge;
float3 blur = colorIN.rgb;
const float intensity = dot(blur, 0.3333);
#line 41
for(int i=0; i < 8; i++) {
ret = tex2D(ReShade::BackBuffer, coord + tap[i] * ReShade::PixelSize * FXAA_RADIUS);
float weight = abs(intensity - dot(ret.rgb, 0.33333));
blur = lerp(blur, ret.rgb, weight / 8);
edge += weight;
}
#line 48
edge /= 8;
ret.rgb = lerp(colorIN.rgb, blur, FXAA_STRENGTH);
#line 51
if (FXAA_DEBUG)	ret.rgb = edge;
#line 53
return ret;
}
#line 59
float4 PS_FXAA(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : COLOR
{
return FastFXAA(tex2D(ReShade::BackBuffer, texcoord), texcoord);
}
#line 67
technique Pirate_FXAA
{
pass FXAA_Pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_FXAA;
}
}

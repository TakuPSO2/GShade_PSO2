#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Bumpmapping.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Bumpmapping.fx"
#line 23
uniform float SMOOTHING <
ui_min = 0.0; ui_max = 1.0;
ui_type = "slider";
ui_label = "Effect Smoothing";
ui_tooltip = "Effect Smoothing";
ui_step = 0.001;
> = 0.5;
#line 31
uniform float RANGE <
ui_min = 0.5; ui_max = 2.0;
ui_type = "slider";
ui_label = "Effect Width";
ui_tooltip = "Effect Width";
ui_step = 0.001;
> = 1.0;
#line 39
uniform float EMBOSS <
ui_min = 0.0; ui_max = 2.0;
ui_type = "slider";
ui_label = "BumpMapping Strength";
ui_tooltip = "BumpMapping Strength";
ui_step = 0.001;
> = 1.0;
#line 47
uniform float CONTRAST <
ui_min = 0.0; ui_max = 0.40;
ui_type = "slider";
ui_label = "Contrast";
ui_tooltip = "Ammount of haloing etc.";
ui_step = 0.001;
> = 0.20;
#line 55
uniform float SMART <
ui_min = 0.0; ui_max = 1.0;
ui_type = "slider";
ui_label = "Smart Bumpmapping";
ui_tooltip = "Smart Bumpmapping";
ui_step = 0.001;
> = 0.75;
#line 64
texture SmoothTexture01 { Width = 1920; Height = 1080; Format = RGBA8; };
sampler Texture01S { Texture = SmoothTexture01; };
#line 68
static const float2 g10 = float2( 0.333,-1.0)*ReShade::PixelSize;
static const float2 g01 = float2(-1.0,-0.333)*ReShade::PixelSize;
static const float2 g12 = float2(-0.333, 1.0)*ReShade::PixelSize;
static const float2 g21 = float2( 1.0, 0.333)*ReShade::PixelSize;
#line 73
float3 SMOOTH (float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
const float3 c10 = tex2D(ReShade::BackBuffer, uv + g10).rgb;
const float3 c01 = tex2D(ReShade::BackBuffer, uv + g01).rgb;
const float3 c11 = tex2D(ReShade::BackBuffer, uv      ).rgb;
const float3 c21 = tex2D(ReShade::BackBuffer, uv + g21).rgb;
const float3 c12 = tex2D(ReShade::BackBuffer, uv + g12).rgb;
#line 81
const float3 b11 = (c10+c01+c12+c21+c11)*0.2;
#line 83
return lerp(c11,b11,SMOOTHING);
}
#line 87
float3 GetWeight(float3 dif1)
{
return lerp(float3(1.0,1.0,1.0), 0.7*dif1 + 0.3, SMART);
}
#line 92
float3 BUMP(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
const float3 dt = float3(1.0,1.0,1.0);
#line 97
const float2 inv_size = RANGE * ReShade::PixelSize;
#line 99
const float2 dx = float2(inv_size.x,0.0);
const float2 dy = float2(0.0, inv_size.y);
const float2 g1 = float2(inv_size.x,inv_size.y);
#line 103
const float2 pC4 = uv;
#line 106
const float3 c00 = tex2D(Texture01S,uv - g1).rgb;
const float3 c10 = tex2D(Texture01S,uv - dy).rgb;
const float3 c01 = tex2D(Texture01S,uv - dx).rgb;
const float3 c11 = 0.5*(tex2D(ReShade::BackBuffer,uv).rgb + tex2D(Texture01S,uv).rgb);
const float3 c21 = tex2D(Texture01S,uv + dx).rgb;
const float3 c12 = tex2D(Texture01S,uv + dy).rgb;
const float3 c22 = tex2D(Texture01S,uv + g1).rgb;
#line 114
const float3 w00 = GetWeight(saturate(2.25*abs(c00-c22)/(c00+c22+0.25)));
const float3 w01 = GetWeight(saturate(2.25*abs(c01-c21)/(c01+c21+0.25)));
const float3 w10 = GetWeight(saturate(2.25*abs(c10-c12)/(c10+c12+0.25)));
#line 118
const float3 b11 = (w00*(c00-c22) + w01*(c01-c21) + w10*(c10-c12)) + c11;
#line 120
return clamp(lerp(c11,b11,-EMBOSS), c11*(1.0-CONTRAST),c11*(1.0+CONTRAST));
}
#line 123
technique BUMPMAPPING
{
pass bump1
{
VertexShader = PostProcessVS;
PixelShader = SMOOTH;
RenderTarget = SmoothTexture01;
}
pass bump2
{
VertexShader = PostProcessVS;
PixelShader = BUMP;
}
}

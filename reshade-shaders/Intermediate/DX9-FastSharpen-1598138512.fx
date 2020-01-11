#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FastSharpen.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\FastSharpen.fx"
#line 23
uniform float SHARPEN <
ui_min = 0.0; ui_max = 2.0;
ui_type = "slider";
ui_label = "Sharpen";
ui_tooltip = "Sharpen intensity";
ui_step = 0.001;
> = 0.9;
#line 31
uniform float CONTRAST <
ui_min = 0.0; ui_max = 0.20;
ui_type = "slider";
ui_label = "Contrast";
ui_tooltip = "Ammount of haloing etc.";
ui_step = 0.001;
> = 0.06;
#line 39
uniform float DETAILS <
ui_min = 0.0; ui_max = 1.0;
ui_type = "slider";
ui_label = "Details";
ui_tooltip = "Ammount of Details.";
ui_step = 0.001;
> = 0.50;
#line 48
static const float2 g10 = float2( 0.3333,-1.0)*ReShade::PixelSize;
static const float2 g01 = float2(-1.0,-0.3333)*ReShade::PixelSize;
static const float2 g12 = float2(-0.3333, 1.0)*ReShade::PixelSize;
static const float2 g21 = float2( 1.0, 0.3333)*ReShade::PixelSize;
#line 53
float3 SHARP(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
#line 57
const float3 c10 = tex2D(ReShade::BackBuffer, uv + g10).rgb;
const float3 c01 = tex2D(ReShade::BackBuffer, uv + g01).rgb;
const float3 c21 = tex2D(ReShade::BackBuffer, uv + g21).rgb;
const float3 c12 = tex2D(ReShade::BackBuffer, uv + g12).rgb;
const float3 c11 = tex2D(ReShade::BackBuffer, uv      ).rgb;
const float3 b11 = (c10+c01+c12+c21)*0.25;
#line 64
float contrast = max(max(c11.r,c11.g),c11.b);
contrast = lerp(2.0*CONTRAST, CONTRAST, contrast);
#line 67
float3 mn1 = min(min(c10,c01),min(c12,c21)); mn1 = min(mn1,c11*(1.0-contrast));
float3 mx1 = max(max(c10,c01),max(c12,c21)); mx1 = max(mx1,c11*(1.0+contrast));
#line 70
const float3 dif = pow(abs(mx1-mn1), float3(0.75,0.75,0.75));
const float3 sharpen = lerp(SHARPEN*DETAILS, SHARPEN, dif);
#line 73
return clamp(lerp(c11,b11,-sharpen), mn1,mx1);
}
#line 76
technique FastSharpen
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SHARP;
}
}

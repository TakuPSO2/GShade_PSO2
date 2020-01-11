#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Emboss.fx"
#line 6
uniform float fEmbossPower <
ui_type = "slider";
ui_min = 0.01; ui_max = 2.0;
ui_label = "Emboss Power";
> = 0.150;
uniform float fEmbossOffset <
ui_type = "slider";
ui_min = 0.1; ui_max = 5.0;
ui_label = "Emboss Offset";
> = 1.00;
uniform float iEmbossAngle <
ui_type = "slider";
ui_min = 0.0; ui_max = 360.0;
ui_label = "Emboss Angle";
> = 90.00;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Emboss.fx"
#line 24
float3 EmbossPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 28
float2 offset;
sincos(radians( iEmbossAngle), offset.y, offset.x);
const float3 col1 = tex2D(ReShade::BackBuffer, texcoord - ReShade::PixelSize*fEmbossOffset*offset).rgb;
const float3 col3 = tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize*fEmbossOffset*offset).rgb;
#line 33
const float3 colEmboss = col1 * 2.0 - color - col3;
#line 35
const float colDot = max(0,dot(colEmboss, 0.333))*fEmbossPower;
#line 37
const float3 colFinal = color - colDot;
#line 39
const float luminance = dot( color, float3( 0.6, 0.2, 0.2 ) );
#line 41
return lerp( colFinal, color, luminance * luminance ).xyz;
}
#line 44
technique Emboss_Tech
{
pass Emboss
{
VertexShader = PostProcessVS;
PixelShader = EmbossPass;
}
}

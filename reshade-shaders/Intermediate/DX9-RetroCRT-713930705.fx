#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\RetroCRT.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\RetroCRT.fx"
#line 54
uniform float Timer < source = "timer"; >;
#line 56
float4 RetroCRTPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float GLTimer = Timer * 0.0001;
#line 60
const float vPos = float( ( texcoord.y + GLTimer * 0.5 ) * 272.0 );
const float line_intensity = vPos - 2.0 * floor(vPos / 2.0);
#line 64
const float2 shift = float2( line_intensity * 0.0005, 0 );
#line 67
const float2 colorShift = float2( 0.001, 0 );
#line 69
const float4 c = float4( tex2D( ReShade::BackBuffer, texcoord + colorShift + shift ).x,			
tex2D( ReShade::BackBuffer, texcoord - colorShift + shift ).y * 0.99,	
tex2D( ReShade::BackBuffer, texcoord ).z,				
1.0) * clamp( line_intensity, 0.85, 1.0 );
#line 74
return c + (sin( ( texcoord.y + GLTimer ) * 4.0 ) * 0.02);
}
#line 77
technique RetroCRT
{
pass
{
VertexShader = PostProcessVS;
PixelShader = RetroCRTPass;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Cartoon.fx"
#line 7
uniform float Power <
ui_type = "slider";
ui_min = 0.1; ui_max = 10.0;
ui_tooltip = "Amount of effect you want.";
> = 1.5;
uniform float EdgeSlope <
ui_type = "slider";
ui_min = 0.1; ui_max = 6.0;
ui_label = "Edge Slope";
ui_tooltip = "Raise this to filter out fainter edges. You might need to increase the power to compensate. Whole numbers are faster.";
> = 1.5;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Cartoon.fx"
#line 21
float3 CartoonPass(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
#line 26
float diff1 = dot(coefLuma, tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize).rgb);
diff1 = dot(float4(coefLuma, -1.0), float4(tex2D(ReShade::BackBuffer, texcoord - ReShade::PixelSize).rgb , diff1));
float diff2 = dot(coefLuma, tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize * float2(1, -1)).rgb);
diff2 = dot(float4(coefLuma, -1.0), float4(tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize * float2(-1, 1)).rgb , diff2));
#line 31
const float edge = dot(float2(diff1, diff2), float2(diff1, diff2));
#line 33
return saturate(pow(abs(edge), EdgeSlope) * -Power + color);
}
#line 36
technique Cartoon
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CartoonPass;
}
}

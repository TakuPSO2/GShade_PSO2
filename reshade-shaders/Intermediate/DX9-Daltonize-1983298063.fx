#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Daltonize.fx"
#line 8
uniform int Type <
ui_type = "combo";
ui_items = "Protanopia\0Deuteranopia\0Tritanopia\0";
> = 0;
#line 13
uniform float RedAdjust <
ui_label = "Base Red Adjustment";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.001;
ui_max = 2.0;
> = 1.0;
#line 21
uniform float GreenAdjust <
ui_label = "Base Green Adjustment";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.001;
ui_max = 2.0;
> = 1.0;
#line 29
uniform float BlueAdjust <
ui_label = "Base Blue Adjustment";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.001;
ui_max = 2.0;
> = 1.0;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Daltonize.fx"
#line 39
float3 PS_DaltonizeFXmain(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 43
input.r = input.r * RedAdjust;
#line 45
input.g = input.g * GreenAdjust;
#line 47
input.b = input.b * BlueAdjust;
#line 50
const float OnizeL = (17.8824f * input.r) + (43.5161f * input.g) + (4.11935f * input.b);
const float OnizeM = (3.45565f * input.r) + (27.1554f * input.g) + (3.86714f * input.b);
const float OnizeS = (0.0299566f * input.r) + (0.184309f * input.g) + (1.46709f * input.b);
#line 55
float Daltl, Daltm, Dalts;
#line 57
if (Type == 0) 
{
Daltl = 0.0f * OnizeL + 2.02344f * OnizeM + -2.52581f * OnizeS;
Daltm = 0.0f * OnizeL + 1.0f * OnizeM + 0.0f * OnizeS;
Dalts = 0.0f * OnizeL + 0.0f * OnizeM + 1.0f * OnizeS;
}
else if (Type == 1) 
{
Daltl = 1.0f * OnizeL + 0.0f * OnizeM + 0.0f * OnizeS;
Daltm = 0.494207f * OnizeL + 0.0f * OnizeM + 1.24827f * OnizeS;
Dalts = 0.0f * OnizeL + 0.0f * OnizeM + 1.0f * OnizeS;
}
else if (Type == 2) 
{
Daltl = 1.0f * OnizeL + 0.0f * OnizeM + 0.0f * OnizeS;
Daltm = 0.0f * OnizeL + 1.0f * OnizeM + 0.0f * OnizeS;
Dalts = -0.395913f * OnizeL + 0.801109f * OnizeM + 0.0f * OnizeS;
}
#line 78
const float3 error = input - float3((0.0809444479f * Daltl) + (-0.130504409f * Daltm) + (0.116721066f * Dalts), (-0.0102485335f * Daltl) + (0.0540193266f * Daltm) + (-0.113614708f * Dalts), (-0.000365296938f * Daltl) + (-0.00412161469f * Daltm) + (0.693511405f * Dalts));
#line 81
return input + float3(0, (error.r * 0.7) + (error.g * 1.0), (error.r * 0.7) + (error.b * 1.0));
}
#line 84
technique Daltonize
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_DaltonizeFXmain;
}
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Fisheye Horizontal.fx"
#line 9
uniform float fFisheyeZoom <
ui_type = "slider";
ui_min = 0.5; ui_max = 1.0;
ui_label = "Fish Eye Zoom";
ui_tooltip = "Lens zoom to hide bugged edges due to texcoord modification";
> = 0.55;
uniform float fFisheyeDistortion <
ui_type = "slider";
ui_min = -0.300; ui_max = 0.300;
ui_label = "Fisheye Distortion";
ui_tooltip = "Distortion of image";
> = 0.01;
uniform float fFisheyeDistortionCubic <
ui_type = "slider";
ui_min = -0.300; ui_max = 0.300;
ui_label = "Fisheye Distortion Cubic";
ui_tooltip = "Distortion of image, cube based";
> = 0.7;
uniform float fFisheyeColorshift <
ui_type = "slider";
ui_min = -0.10; ui_max = 0.10;
ui_label = "Colorshift";
ui_tooltip = "Amount of color shifting";
> = 0.002;
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Fisheye Horizontal.fx"
#line 36
float3 FISHEYE_CAPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 40
float4 coord=0.0;
coord.xy=texcoord.xy;
coord.w=0.0;
#line 44
color.rgb = 0.0;
#line 46
float3 eta = float3(1.0+fFisheyeColorshift*0.9,1.0+fFisheyeColorshift*0.6,1.0+fFisheyeColorshift*0.3);
float2 center;
center.x = coord.x-0.5;
center.y = coord.y-0.5;
float LensZoom = 1.0/fFisheyeZoom;
#line 52
float r2 = (texcoord.y-0.5) * (texcoord.y-0.5);
float f = 0;
#line 55
if( fFisheyeDistortionCubic == 0.0){
f = 1 + r2 * fFisheyeDistortion;
}else{
f = 1 + r2 * (fFisheyeDistortion + fFisheyeDistortionCubic * sqrt(r2));
};
#line 61
float x = f*LensZoom*(coord.x-0.5)+0.5;
float y = f*LensZoom*(coord.y-0.5)+0.5;
float2 rCoords = (f*eta.r)*LensZoom*(center.xy*0.5)+0.5;
float2 gCoords = (f*eta.g)*LensZoom*(center.xy*0.5)+0.5;
float2 bCoords = (f*eta.b)*LensZoom*(center.xy*0.5)+0.5;
#line 67
color.x = tex2D(ReShade::BackBuffer,rCoords).r;
color.y = tex2D(ReShade::BackBuffer,gCoords).g;
color.z = tex2D(ReShade::BackBuffer,bCoords).b;
#line 71
return color.rgb;
#line 73
}
#line 76
technique FISHEYE_CA_HORIZONTAL
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FISHEYE_CAPass;
}
}

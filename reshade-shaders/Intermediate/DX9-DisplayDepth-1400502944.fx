#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\DisplayDepth.fx"
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Reshade.fxh"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\DisplayDepth.fx"
#line 22
uniform bool bUIUsePreprocessorDefs <
ui_label = "Use global preprocessor definitions";
ui_tooltip = "Enable this to override the values from\n"
"'Depth Input Settings' with the\n"
"preprocessor definitions. If all is set\n"
"up correctly, no difference should be\n"
"noticed.";
> = false;
#line 31
uniform float fUIFarPlane <
ui_type = "slider";
ui_label = "Far Plane";
ui_tooltip = "RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=<value>\n"
"Changing this value is not necessary in most cases.";
ui_min = 0.0; ui_max = 1000.0;
ui_step = 0.1;
> = 1000.0;
#line 40
uniform int iUIUpsideDown <
ui_type = "combo";
ui_label = "";
ui_items = "RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=0\0RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=1\0";
> = 0;
#line 46
uniform int iUIReversed <
ui_type = "combo";
ui_label = "";
ui_items = "RESHADE_DEPTH_INPUT_IS_REVERSED=0\0RESHADE_DEPTH_INPUT_IS_REVERSED=1\0";
> = 1;
#line 52
uniform int iUILogarithmic <
ui_type = "combo";
ui_label = "";
ui_items = "RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=0\0RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=1\0";
ui_tooltip = "Change this setting if the displayed surface normals have stripes in them";
> = 0;
#line 59
uniform int iUIPresentType <
ui_category = "Options";
ui_type = "combo";
ui_label = "Present type";
ui_items = "Depth map\0Normal map\0Show both (Vertical 50/50)\0";
> = 2;
#line 66
float GetDepth(float2 texcoord)
{
#line 69
if(bUIUsePreprocessorDefs)
{
return ReShade::GetLinearizedDepth(texcoord);
}
#line 76
if(iUIUpsideDown)
{
texcoord.y = 1.0 - texcoord.y;
}
#line 81
float depth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord, 0, 0)).x;
#line 83
if(iUILogarithmic)
{
const float C = 0.01;
depth = (exp(depth * log(C + 1.0)) - 1.0) / C;
}
#line 89
if(iUIReversed)
{
depth = 1.0 - depth;
}
#line 94
const float N = 1.0;
return depth /= fUIFarPlane - depth * (fUIFarPlane - N);
}
#line 98
float3 NormalVector(float2 texcoord)
{
float3 offset = float3(ReShade::PixelSize.xy, 0.0);
float2 posCenter = texcoord.xy;
float2 posNorth  = posCenter - offset.zy;
float2 posEast   = posCenter + offset.xz;
#line 105
float3 vertCenter = float3(posCenter - 0.5, 1) * GetDepth(posCenter);
float3 vertNorth  = float3(posNorth - 0.5,  1) * GetDepth(posNorth);
float3 vertEast   = float3(posEast - 0.5,   1) * GetDepth(posEast);
#line 109
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 112
void PS_DisplayDepth(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float3 normal_color = NormalVector(texcoord);
#line 116
if(iUIPresentType == 1)
{
color = normal_color;
return;
}
#line 122
const float dither_bit = 8.0; 
#line 128
float grid_position = frac(dot(texcoord, (ReShade::ScreenSize * float2(1.0 / 16.0, 10.0 / 36.0)) + 0.25));
#line 131
float dither_shift = 0.25 * (1.0 / (pow(2, dither_bit) - 1.0));
#line 134
float3 dither_shift_RGB = float3(dither_shift, -dither_shift, dither_shift); 
#line 137
dither_shift_RGB = lerp(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position); 
#line 140
float3 depth_color = GetDepth(texcoord).rrr + dither_shift_RGB;
#line 142
if(iUIPresentType == 0)
{
color = depth_color;
return;
}
#line 148
color = lerp(normal_color, depth_color, step(ReShade::ScreenSize.x / 2, position.x));
}
#line 151
technique DisplayDepth <
ui_tooltip = "This shader helps finding the right\n"
"preprocessor settings for the depth\n"
"input.\n"
"By default the calculated normals\n"
"are shown and the goal is to make the\n"
"displayed surface normals look smooth.\n"
"Change the options for *_IS_REVERSED\n"
"and *_IS_LOGARITHMIC in the variable editor\n"
"until this happens.\n"
"\n"
"Change the 'Present type' to 'Depth map'\n"
"and check whether close objects are dark\n"
"and far away objects are white.\n"
"\n"
"When the right settings are found click\n"
"'Edit global preprocessor definitions'\n"
"(Variable editor in the 'Home' tab)\n"
"and put them in there.\n"
"\n"
"Switching between normal map and\n"
"depth map is possible via 'Present type'\n"
"in the Options category.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_DisplayDepth;
}
}

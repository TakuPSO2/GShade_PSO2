#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Chromakey2.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Chromakey2.fx"
#line 16
uniform float Threshold2 <
ui_label = "Threshold";
ui_type = "slider";
ui_min = 0.0; ui_max = 0.999; ui_step = 0.001;
ui_category = "Distance adjustment";
> = 0.1;
#line 23
uniform bool RadialX2 <
ui_label = "Horizontally radial depth";
ui_category = "Radial distance";
ui_category_closed = true;
> = false;
uniform bool RadialY2 <
ui_label = "Vertically radial depth";
ui_category = "Radial distance";
> = false;
#line 33
uniform float FOV2 <
ui_label = "FOV (horizontal)";
ui_type = "slider";
ui_tooltip = "Field of view in degrees";
ui_step = .01;
ui_min = 0.0; ui_max = 300.0;
ui_category = "Radial distance";
> = 90;
#line 42
uniform int CKPass2 <
ui_label = "Keying type";
ui_type = "combo";
ui_items = "Background key\0Foreground key\0";
ui_category = "Direction adjustment";
> = 0;
#line 49
uniform bool Floor2 <
ui_label = "Mask floor";
ui_category = "Floor masking (experimental)";
ui_category_closed = true;
> = false;
#line 55
uniform float FloorAngle2 <
ui_label = "Floor angle";
ui_type = "slider";
ui_category = "Floor masking (experimental)";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 62
uniform int Precision2 <
ui_label = "Floor precision";
ui_type = "slider";
ui_category = "Floor masking (experimental)";
ui_min = 2; ui_max = 9216;
> = 4;
#line 69
uniform int Color2 <
ui_label = "Keying color";
ui_tooltip = "Ultimatte(tm) Super Blue and Green are industry standard colors for chromakey";
ui_type = "combo";
ui_items = "Super Blue Ultimatte(tm)\0Green Ultimatte(tm)\0Custom\0";
ui_category = "Color settings";
ui_category_closed = true;
> = 2;
#line 78
uniform float3 CustomColor2 <
ui_type = "color";
ui_label = "Custom color";
ui_category = "Color settings";
> = float3(0.0, 1.0, 0.0);
#line 84
uniform bool AntiAliased2 <
ui_label = "Anti-aliased mask";
ui_tooltip = "Disabling this option will reduce masking gaps";
ui_category = "Additional settings";
ui_category_closed = true;
> = false;
#line 96
float MaskAA(float2 texcoord)
{
#line 99
float Depth = ReShade::GetLinearizedDepth(texcoord);
#line 102
float2 Size;
Size.x = tan(radians(FOV2*0.5));
Size.y = Size.x / ReShade::AspectRatio;
if(RadialX2) Depth *= length(float2((texcoord.x-0.5)*Size.x, 1.0));
if(RadialY2) Depth *= length(float2((texcoord.y-0.5)*Size.y, 1.0));
#line 109
if(!AntiAliased2) return step(Threshold2, Depth);
#line 112
float hPixel = fwidth(Depth)*0.5;
#line 114
return smoothstep(Threshold2-hPixel, Threshold2+hPixel, Depth);
}
#line 117
float3 GetPosition(float2 texcoord)
{
#line 120
const float theta = radians(FOV2*0.5);
#line 122
float3 position = float3( texcoord*2.0-1.0, ReShade::GetLinearizedDepth(texcoord) );
#line 124
position.xy *= position.z;
#line 126
return position;
}
#line 130
float3 GetNormal(float2 texcoord)
{
const float3 offset = float3(ReShade::PixelSize.xy, 0.0);
const float2 posCenter = texcoord.xy;
const float2 posNorth  = posCenter - offset.zy;
const float2 posEast   = posCenter + offset.xz;
#line 137
const float3 vertCenter = float3(posCenter - 0.5, 1.0) * ReShade::GetLinearizedDepth(posCenter);
const float3 vertNorth  = float3(posNorth - 0.5,  1.0) * ReShade::GetLinearizedDepth(posNorth);
const float3 vertEast   = float3(posEast - 0.5,   1.0) * ReShade::GetLinearizedDepth(posEast);
#line 141
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 148
float3 Chromakey2PS(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 151
float3 Screen;
switch(Color2)
{
case 0:{ Screen = float3(0.07, 0.18, 0.72); break; } 
case 1:{ Screen = float3(0.29, 0.84, 0.36); break; } 
case 2:{ Screen = CustomColor2;              break; } 
}
#line 160
float DepthMask = MaskAA(texcoord);
#line 162
if (Floor2)
{
#line 165
bool FloorMask = (float)round( GetNormal(texcoord).y*Precision2 )/Precision2==(float)round( FloorAngle2*Precision2 )/Precision2;
#line 167
if (FloorMask)
DepthMask = 1.0;
}
#line 171
if(bool(CKPass2)) DepthMask = 1.0-DepthMask;
#line 173
return lerp(tex2D(ReShade::BackBuffer, texcoord).rgb, Screen, DepthMask);
}
#line 181
technique Chromakey2 < ui_tooltip = "Generate green-screen wall based of depth"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = Chromakey2PS;
}
}

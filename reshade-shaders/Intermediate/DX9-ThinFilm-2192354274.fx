#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ThinFilm.fx"
#line 32
uniform int FOV <
ui_label = "Field of View (horizontal)";
ui_type = "slider";
ui_min = 1; ui_max = 170;
ui_category = "Depth settings";
ui_category_closed = true;
> = 90;
#line 40
uniform float FarPlane <
ui_label = "Far Plane adjustment";
ui_tooltip = "Adjust Normal Map strength";
ui_type = "slider";
ui_min = 0.0; ui_max = 1000.0; ui_step = 0.2;
ui_category = "Depth settings";
> = 1000.0;
#line 48
uniform bool Skip4Background <
ui_label = "Show background";
ui_tooltip = "Mask reflection for:\nDEPTH = 1.0";
ui_category = "Depth settings";
> = true;
#line 55
uniform int thick <
ui_label = "Film thickness";
ui_tooltip = "Thickness of the film, in nm";
ui_type = "slider";
ui_min = 0; ui_max = 1000; ui_step = 1;
ui_category = "Irridescence settings";
> = 350;
#line 88
uniform float nmedium <
ui_label = "Refractive index of air";
ui_type = "slider";
ui_tooltip = "Refractive index of the outer medium (typically air)";
ui_min = 1.0; ui_max = 5.0;
ui_category = "Irridescence settings";
> = 1.0;
#line 96
uniform float nfilm <
ui_label = "Refractive index of thin film layer";
ui_type = "slider";
ui_tooltip = "Refractive index of the thin film itself";
ui_min = 1.0; ui_max = 5.0;
ui_category = "Irridescence settings";
> = 1.5;
#line 104
uniform float ninternal <
ui_label = "Refractive index of the lower material";
ui_type = "slider";
ui_tooltip = "Refractive index of the material below the film";
ui_min = 1.0; ui_max = 5.0;
ui_category = "Irridescence settings";
> = 3.5;
#line 112
uniform int BlendingMode <
ui_label = "Mix mode";
ui_type = "combo";
ui_items = "Normal mode\0Multiply\0Screen\0Overlay\0Soft Light\0";
ui_category = "Blending options";
> = 2;
#line 119
uniform bool LumaBlending <
ui_label = "Luminance based mixing";
ui_category = "Blending options";
> = true;
#line 124
uniform float BlendingAmount <
ui_label = "Blend";
ui_type = "slider";
ui_tooltip = "Blend with background";
ui_min = 0.0; ui_max = 1.0;
ui_category = "Blending options";
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ThinFilm.fx"
#line 139
float3 Multiply(float3 A, float3 B){ return A*B; }
#line 141
float3 Screen(float3 A, float3 B){ return A+B-A*B; } 
#line 143
float3 Overlay(float3 A, float3 B)
{
#line 146
const float3 HL[4] = { max(A, 0.5), max(B, 0.5), min(A, 0.5), min(B, 0.5) };
return ( HL[0] + HL[1] - HL[0]*HL[1] + HL[2]*HL[3] )*2.0 - 1.5;
}
#line 150
float3 SoftLight(float3 A, float3 B)
{
const float3 A2 = A*A;
return 2.0*A*B+A2-2.0*A2*B;
}
#line 157
float LumaMask(float3 Color)
{
static const float3 Luma709 = float3(0.2126, 0.7152, 0.0722);
return dot(Luma709, Color);
}
#line 169
float GetDepth(float2 TexCoord)
{
#line 174
float Depth = tex2Dlod( ReShade::DepthBuffer, float4(TexCoord, 0, 0) ).x;
#line 184
const float N = 1.0;
Depth /= FarPlane - Depth * (FarPlane - N);
#line 187
return Depth;
}
#line 191
float3 NormalVector(float2 texcoord)
{
const float3 offset = float3(ReShade::PixelSize.xy, 0.0);
const float2 posCenter = texcoord.xy;
const float2 posNorth  = posCenter - offset.zy;
const float2 posEast   = posCenter + offset.xz;
#line 198
const float3 vertCenter = float3(posCenter - 0.5, 1.0) * GetDepth(posCenter);
const float3 vertNorth  = float3(posNorth - 0.5,  1.0) * GetDepth(posNorth);
const float3 vertEast   = float3(posEast - 0.5,   1.0) * GetDepth(posEast);
#line 202
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 206
float rs(float n1, float n2, float cosI, float cosT)
{ return (n1 * cosI - n2 * cosT) / (n1 * cosI + n2 * cosT); }
#line 210
float rp(float n1, float n2, float cosI, float cosT)
{ return (n2 * cosI - n1 * cosT) / (n1 * cosT + n2 * cosI); }
#line 214
float ts(float n1, float n2, float cosI, float cosT)
{ return 2.0 * n1 * cosI / (n1 * cosI + n2 * cosT); }
#line 218
float tp(float n1, float n2, float cosI, float cosT)
{ return 2.0 * n1 * cosI / (n1 * cosT + n2 * cosI); }
#line 224
float thinFilmReflectance(float cos0, float lambda, float thickness, float n0, float n1, float n2) {
const float PI = radians(180.0);
#line 228
float d10 = 0.0;
if (n1 < n0)
d10 = PI;
float d12 = 0.0;
if (n1 < n2)
d12 = PI;
const float delta = d10 + d12;
#line 237
const float sin1 = ((n0 / n1) * (n0 / n1)) * (1.0 - (cos0 * cos0));
if(sin1 > 1.0) return 1.0; 
const float cos1 = sqrt(1.0 - sin1);
#line 243
const float sin2 = ((n0 / n2) * (n0 / n2)) * (1.0 - (cos0 * cos0));
if(sin2 > 1.0) return 1.0; 
const float cos2 = sqrt(1.0 - sin2);
#line 248
const float alpha_s = rs(n1, n0, cos1, cos0) * rs(n1, n2, cos1, cos2); 
const float alpha_p = rp(n1, n0, cos1, cos0) * rp(n1, n2, cos1, cos2); 
#line 251
const float beta_s = ts(n0, n1, cos0, cos1) * ts(n1, n2, cos1, cos2); 
const float beta_p = tp(n0, n1, cos0, cos1) * tp(n1, n2, cos1, cos2); 
#line 255
const float phi = (2.0 * PI / lambda) * (2.0 * n1 * thickness * cos1) + delta;
#line 258
const float ts = (beta_s * beta_s) / ((alpha_s * alpha_s) - 2.0 * alpha_s * cos(phi) + 1.0);
const float tp = (beta_p * beta_p) / ((alpha_p * alpha_p) - 2.0 * alpha_p * cos(phi) + 1.0);
#line 262
const float beamRatio = (n2 * cos2) / (n0 * cos0);
#line 266
const float t = beamRatio * (ts + tp) * 0.5;
#line 269
return 1.0 - t;
}
#line 273
float GetReflectionCosine(float2 TexCoord)
{
#line 276
const float Aspect = ReShade::AspectRatio;
#line 279
float3 Normal = NormalVector(TexCoord);
#line 281
Normal.xy = Normal.xy * 2.0 - 1.0;
#line 284
float3 CameraRay;
CameraRay.xy = TexCoord * 2.0 - 1.0;
CameraRay.y /= Aspect; 
CameraRay.z = 1.0 / tan(radians(FOV*0.5)); 
#line 290
return abs( dot(CameraRay, Normal) );
}
#line 293
float3 ThinFilmPS(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
if(Skip4Background) if( GetDepth(texcoord)==1.0 ) return tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 297
const float3 Display = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 Irridescence;
#line 300
const float cos0 = GetReflectionCosine(texcoord);
#line 303
Irridescence.r = thinFilmReflectance(cos0, 650.0, thick, nmedium, nfilm, ninternal); 
Irridescence.g = thinFilmReflectance(cos0, 510.0, thick, nmedium, nfilm, ninternal); 
Irridescence.b = thinFilmReflectance(cos0, 475.0, thick, nmedium, nfilm, ninternal); 
#line 307
Irridescence = saturate(Irridescence);
#line 309
if(BlendingAmount == 1.0 && !bool(BlendingMode) && !LumaBlending) return Irridescence;
#line 311
switch(BlendingMode)
{
case 1:{ Irridescence = Multiply(Irridescence, Display); break; } 
case 2:{ Irridescence = Screen(Irridescence, Display); break; } 
case 3:{ Irridescence = Overlay(Irridescence, Display); break; } 
case 4:{ Irridescence = SoftLight(Irridescence, Display); break; } 
}
#line 319
if(BlendingAmount == 1.0 && !LumaBlending) return Irridescence;
else if(LumaBlending) return lerp(Display, Irridescence, LumaMask(Display) * BlendingAmount);
return lerp(Display, Irridescence, BlendingAmount);
}
#line 329
technique ThinFilm < ui_label = "Thin-film (iridescence)";
ui_tooltip = "Apply thin-film interference (iridescence) 'holographic' effect..."; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ThinFilmPS;
}
}

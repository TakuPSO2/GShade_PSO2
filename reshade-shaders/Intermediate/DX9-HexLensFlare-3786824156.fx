#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\HexLensFlare.fx"
#line 45
static const float cAspectRatio = 1920 * (1.0 / 1080);
static const float2 cPixelSize = float2((1.0 / 1920), (1.0 / 1080));
static const float2 cScreenSize = float2(1920, 1080);
#line 50
static const float c2PI = 3.14159 * 2.0;
#line 56
uniform float uIntensity <
ui_label = "Intensity";
ui_category = "Lens Flare";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.0;
#line 66
uniform float uThreshold <
ui_label = "Threshold";
ui_category = "Lens Flare";
ui_tooltip = "Default: 0.99";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.95;
#line 76
uniform float uScale <
ui_label = "Scale";
ui_category = "Lens Flare";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.001;
> = 1.0;
#line 86
uniform float3 uColor0 <
ui_label = "#1";
ui_category = "Colors";
ui_tooltip = "Default: R:147 G:255 B:0";
ui_type = "color";
> = float3(147, 255, 0) / 255.0;
#line 93
uniform float3 uColor1 <
ui_label = "#2";
ui_category = "Colors";
ui_tooltip = "Default: R:66 G:151 B:255";
ui_type = "color";
> = float3(66, 151, 255) / 255.0;
#line 100
uniform float3 uColor2 <
ui_label = "#3";
ui_category = "Colors";
ui_tooltip = "Default: R:255 G:147 B:0";
ui_type = "color";
> = float3(255, 147, 0) / 255.0;
#line 107
uniform float3 uColor3 <
ui_label = "#4";
ui_category = "Colors";
ui_tooltip = "Default: R:100 G:236 B:255";
ui_type = "color";
> = float3(100, 236, 255) / 255.0;
#line 130
texture2D tHexLensFlare_Color : COLOR;
sampler2D sColor {
Texture = tHexLensFlare_Color;
#line 134
SRGBTexture = true;
#line 136
AddressU = BORDER;
AddressV = BORDER;
};
#line 140
texture2D tHexLensFlare_Prepare {
Width = 1920 / 4;
Height = 1080 / 4;
Format = RGBA16F;
};
sampler2D sPrepare {
Texture = tHexLensFlare_Prepare;
};
#line 149
texture2D tHexLensFlare_VerticalBlur {
Width = 1920 / 4;
Height = 1080 / 4;
Format = RGBA16F;
};
sampler2D sVerticalBlur {
Texture = tHexLensFlare_VerticalBlur;
};
#line 158
texture2D tHexLensFlare_DiagonalBlur {
Width = 1920 / 4;
Height = 1080 / 4;
Format = RGBA16F;
};
sampler2D sDiagonalBlur {
Texture = tHexLensFlare_DiagonalBlur;
};
#line 167
texture2D tHexLensFlare_RhomboidBlur {
Width = 1920 / 4;
Height = 1080 / 4;
Format = RGBA16F;
};
sampler2D sRhomboidBlur {
Texture = tHexLensFlare_RhomboidBlur;
};
#line 184
float2 scale(float2 uv, float2 s, float2 c) {
return (uv - c) * s + c;
}
#line 188
float2 scale(float2 uv, float2 s) {
return scale(uv, s, 0.5);
}
#line 192
float3 blur(sampler2D sp, float2 uv, float2 dir) {
float4 color = 0.0;
#line 195
dir *= 4 * uScale;
uv += dir * 0.5;
#line 198
[loop]
for (int i = 0; i < 16; ++i)
color += float4(tex2D(sp, uv + dir * i).rgb, 1.0);
#line 202
return color.rgb / color.a;
}
#line 205
float get_light(sampler2D sp, float2 uv, float t) {
return step(t, dot(tex2D(sp, uv).rgb, 0.333));
}
#line 213
void VS_PostProcess(
uint id : SV_VERTEXID,
out float4 position : SV_POSITION,
out float2 uv : TEXCOORD
) {
if (id == 2)
uv.x = 2.0;
else
uv.x = 0.0;
if (id == 1)
uv.y = 2.0;
else
uv.y = 0.0;
position = float4(
uv * float2(2.0, -2.0) + float2(-1.0, 1.0),
0.0,
1.0
);
}
#line 233
float4 PS_Prepare(
float4 position : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
uv = 1.0 - uv;
#line 239
float3 color = 0.0;
color += get_light(sColor, uv, uThreshold) * uColor0;
color += get_light(sColor, scale(uv, 3.0), uThreshold) * uColor1;
color += get_light(sColor, scale(uv, 9.0), uThreshold) * uColor2;
color += get_light(sColor, scale(1.0 - uv, 0.666), uThreshold) * uColor3;
#line 245
return float4(color, 1.0);
}
#line 248
float4 PS_VerticalBlur(
float4 position : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
const float2 dir = cPixelSize * float2(cos(c2PI / 2), sin(c2PI / 2));
#line 254
return float4(blur(sPrepare, uv, dir), 1.0);
}
#line 257
float4 PS_DiagonalBlur(
float4 position : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
const float2 dir = cPixelSize * float2(cos(-c2PI / 6), sin(-c2PI / 6));
float3 color = blur(sPrepare, uv, dir);
color += tex2D(sVerticalBlur, uv).rgb;
#line 265
return float4(color, 1.0);
}
#line 268
float4 PS_RhomboidBlur(
float4 position : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
const float2 dir1 = cPixelSize * float2(cos(-c2PI / 6), sin(-c2PI / 6));
const float3 color1 = blur(sVerticalBlur, uv, dir1);
#line 275
const float2 dir2 = cPixelSize * float2(cos(-5 * c2PI / 6), sin(-5 * c2PI / 6));
const float3 color2 = blur(sDiagonalBlur, uv, dir2);
#line 278
return float4((color1 + color2) * 0.5, 1.0);
}
#line 281
float4 PS_Blend(
float4 position : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET {
float3 color = tex2D(sColor, uv).rgb;
const float3 result = tex2D(sRhomboidBlur, uv).rgb;
#line 288
color = 1.0 - (1.0 - color) * (1.0 - result * uIntensity);
#line 297
return float4(color, 1.0);
}
#line 304
technique HexLensFlare {
pass Prepare {
VertexShader = VS_PostProcess;
PixelShader = PS_Prepare;
RenderTarget = tHexLensFlare_Prepare;
}
pass VerticalBlur {
VertexShader = VS_PostProcess;
PixelShader = PS_VerticalBlur;
RenderTarget = tHexLensFlare_VerticalBlur;
}
pass DiagonalBlur {
VertexShader = VS_PostProcess;
PixelShader = PS_DiagonalBlur;
RenderTarget = tHexLensFlare_DiagonalBlur;
}
pass RhomboidBlur {
VertexShader = VS_PostProcess;
PixelShader = PS_RhomboidBlur;
RenderTarget = tHexLensFlare_RhomboidBlur;
}
pass Blend {
VertexShader = VS_PostProcess;
PixelShader = PS_Blend;
#line 330
SRGBWriteEnable = true;
#line 332
}
}

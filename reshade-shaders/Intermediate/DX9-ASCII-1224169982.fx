#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ASCII.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\ASCII.fx"
#line 68
uniform int Ascii_spacing <
ui_type = "slider";
ui_min = 0;
ui_max = 5;
ui_label = "Character Spacing";
ui_tooltip = "Determines the spacing between characters. I feel 1 to 3 looks best.";
ui_category = "Font style";
> = 1;
#line 88
uniform int Ascii_font <
ui_type = "combo";
ui_label = "Font Size";
ui_tooltip = "Choose font size";
ui_category = "Font style";
ui_items =
"Smaller 3x5 font\0"
"Normal 5x5 font\0"
;
> = 1;
#line 100
uniform int Ascii_font_color_mode <
ui_type = "slider";
ui_min = 0;
ui_max = 2;
ui_label = "Font Color Mode";
ui_tooltip = "0 = Foreground color on background color, 1 = Colorized grayscale, 2 = Full color";
ui_category = "Color options";
> = 1;
#line 109
uniform float3 Ascii_font_color <
ui_type = "color";
ui_label = "Font Color";
ui_tooltip = "Choose a font color";
ui_category = "Color options";
> = float3(1.0, 1.0, 1.0);
#line 116
uniform float3 Ascii_background_color <
ui_type = "color";
ui_label = "Background Color";
ui_tooltip = "Choose a background color";
ui_category = "Color options";
> = float3(0.0, 0.0, 0.0);
#line 123
uniform bool Ascii_swap_colors <
ui_label = "Swap Colors";
ui_tooltip = "Swaps the font and background color when you are too lazy to edit the settings above (I know I am)";
ui_category = "Color options";
> = 0;
#line 129
uniform bool Ascii_invert_brightness <
ui_label = "Invert Brightness";
ui_category = "Color options";
> = 0;
#line 134
uniform bool Ascii_dithering <
ui_label = "Dithering";
ui_category = "Dithering";
> = 1;
#line 139
uniform float Ascii_dithering_intensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 4.0;
ui_label = "Dither shift intensity";
ui_tooltip = "For debugging purposes";
ui_category = "Debugging";
> = 2.0;
#line 148
uniform bool Ascii_dithering_debug_gradient <
ui_label = "Dither debug gradient";
ui_category = "Debugging";
> = 0;
#line 159
uniform float timer < source = "timer"; >;
uniform float framecount < source = "framecount"; >;
#line 166
float3 AsciiPass( float2 tex )
{
#line 174
float2 Ascii_font_size = float2(3.0,5.0); 
float num_of_chars = 14. ;
#line 177
if (Ascii_font == 1)
{
Ascii_font_size = float2(5.0,5.0); 
num_of_chars = 17.;
}
#line 183
float quant = 1.0/(num_of_chars-1.0); 
#line 185
float2 Ascii_block = Ascii_font_size + float(Ascii_spacing);
float2 cursor_position = trunc((ReShade::ScreenSize / Ascii_block) * tex) * (Ascii_block / ReShade::ScreenSize);
#line 191
float3 color = tex2D(ReShade::BackBuffer, cursor_position + float2( 1.5, 1.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 1.5, 3.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 1.5, 5.5) * ReShade::PixelSize).rgb;
#line 195
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 3.5, 1.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 3.5, 3.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 3.5, 5.5) * ReShade::PixelSize).rgb;
#line 199
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 5.5, 1.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 5.5, 3.5) * ReShade::PixelSize).rgb;
color += tex2D(ReShade::BackBuffer, cursor_position + float2( 5.5, 5.5) * ReShade::PixelSize).rgb;
#line 208
color /= 9.0;
#line 219
float luma = dot(color,float3(0.2126, 0.7152, 0.0722));
#line 221
float gray = luma;
#line 223
if (Ascii_invert_brightness)
gray = 1.0 - gray;
#line 231
if (Ascii_dithering_debug_gradient)
{
#line 236
gray = cursor_position.x; 
#line 238
}
#line 243
float2 p = frac((ReShade::ScreenSize / Ascii_block) * tex);  
#line 245
p = trunc(p * Ascii_block);
#line 248
float x = (Ascii_font_size.x * p.y + p.x); 
#line 256
if (Ascii_dithering != 0)
{
#line 260
float seed = dot(cursor_position, float2(12.9898,78.233)); 
float sine = sin(seed); 
float noise = frac(sine * 43758.5453 + cursor_position.y);
#line 264
float dither_shift = (quant * Ascii_dithering_intensity); 
#line 266
float dither_shift_half = (dither_shift * 0.5); 
dither_shift = dither_shift * noise - dither_shift_half; 
#line 270
gray += dither_shift; 
}
#line 277
float n = 0;
#line 279
if (Ascii_font == 1)
{
#line 288
float n12   = (gray < (2. * quant))  ? 4194304.  : 131200.  ; 
float n34   = (gray < (4. * quant))  ? 324.      : 330.     ; 
float n56   = (gray < (6. * quant))  ? 283712.   : 12650880.; 
float n78   = (gray < (8. * quant))  ? 4532768.  : 13191552.; 
float n910  = (gray < (10. * quant)) ? 10648704. : 11195936.; 
float n1112 = (gray < (12. * quant)) ? 15218734. : 15255086.; 
float n1314 = (gray < (14. * quant)) ? 15252014. : 32294446.; 
float n1516 = (gray < (16. * quant)) ? 15324974. : 11512810.; 
#line 297
float n1234     = (gray < (3. * quant))  ? n12   : n34;
float n5678     = (gray < (7. * quant))  ? n56   : n78;
float n9101112  = (gray < (11. * quant)) ? n910  : n1112;
float n13141516 = (gray < (15. * quant)) ? n1314 : n1516;
#line 302
float n12345678 = (gray < (5. * quant)) ? n1234 : n5678;
float n910111213141516 = (gray < (13. * quant)) ? n9101112 : n13141516;
#line 305
n = (gray < (9. * quant)) ? n12345678 : n910111213141516;
}
else 
{
#line 344
float n12   = (gray < (2. * quant))  ? 4096.	: 1040.	; 
float n34   = (gray < (4. * quant))  ? 5136.	: 5200.	; 
float n56   = (gray < (6. * quant))  ? 2728.	: 11088.; 
float n78   = (gray < (8. * quant))  ? 14478.	: 11114.; 
float n910  = (gray < (10. * quant)) ? 23213.	: 15211.; 
float n1112 = (gray < (12. * quant)) ? 23533.	: 31599.; 
float n13 = 31727.; 
#line 352
float n1234     = (gray < (3. * quant))  ? n12		: n34;
float n5678     = (gray < (7. * quant))  ? n56		: n78;
float n9101112  = (gray < (11. * quant)) ? n910	: n1112;
#line 356
float n12345678 =  (gray < (5. * quant))	? n1234		: n5678;
float n910111213 = (gray < (13. * quant))	? n9101112	: n13;
#line 359
n = (gray < (9. * quant)) ? n12345678 : n910111213;
}
#line 367
float character = 0.0;
#line 372
float lit = (gray <= (1. * quant))	
? 0.0								
: 1.0 ;								
#line 376
float signbit = (n < 0.0) 
? lit
: 0.0 ;
#line 380
signbit = (x > 23.5)	
? signbit			
: 0.0 ;				
#line 385
character = ( frac( abs( n*exp2(-x-1.0))) >= 0.5) ? lit : signbit; 	
#line 391
if (clamp(p.x, 0.0, Ascii_font_size.x - 1.0) != p.x || clamp(p.y, 0.0, Ascii_font_size.y - 1.0) != p.y) 
character = 0.0; 																					
#line 399
if (Ascii_swap_colors)
{
if (Ascii_font_color_mode  == 2)
{
color = (character) ? character * color : Ascii_font_color;
}
else if (Ascii_font_color_mode  == 1)
{
color = (character) ? Ascii_background_color * gray : Ascii_font_color;
}
else 
{
color = (character) ? Ascii_background_color : Ascii_font_color;
}
}
else
{
if (Ascii_font_color_mode  == 2)
{
color = (character) ? character * color : Ascii_background_color;
}
else if (Ascii_font_color_mode  == 1)
{
color = (character) ? Ascii_font_color * gray : Ascii_background_color;
}
else 
{
color = (character) ? Ascii_font_color : Ascii_background_color;
}
}
#line 435
return saturate(color);
}
#line 439
float3 PS_Ascii(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 color = AsciiPass(texcoord);
return color.rgb;
}
#line 446
technique ASCII
{
pass ASCII
{
VertexShader=PostProcessVS;
PixelShader=PS_Ascii;
}
}

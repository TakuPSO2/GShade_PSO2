/*------------------.
| :: Description :: |
'-------------------/

	Layer (version 0.2)

	Author: CeeJay.dk
	License: MIT

	About:
	Blends an image with the game.
    The idea is to give users with graphics skills the ability to create effects using a layer just like in an image editor.
    Maybe they could use this to create custom CRT effects, custom vignettes, logos, custom hud elements, toggable help screens and crafting tables or something I haven't thought of.

	Ideas for future improvement:
    * More blend modes
    * Texture size, placement and tiling control
    * A default Layer texture with something useful in it

	History:
	(*) Feature (+) Improvement (x) Bugfix (-) Information (!) Compatibility
	
	Version 0.2 by seri14 & Marot Satil
    * Added the ability to scale and move the layer around on an x, y axis. 
*/

#include "ReShade.fxh"

#ifndef LayerTex
#define LayerTex "LayerA.png" // Add your own image file to \reshade-shaders\Textures\ and provide the new file name in quotes to change the image displayed!
#endif

uniform int cLayer_v_Select <
    ui_label = "Layer Selection";
    ui_tooltip = "The image/texture you'd like to use.";
    ui_type = "combo";
    ui_items= "PSO2 logo\0PSO2 copyright\0GShade\0GShade_White\0Eurostyle Left\0Eurostyle Right\0Futura Center\0Futura Triangle White\0Futura Triangle Black\0Rockwell Nova White\0Rockwell Nova Black\0Swiss911 Condenced\0Swiss721 Square White\0Swiss721 Square Black\0";
> = 0;

uniform float cLayer_Blend <
    ui_label = "Opacity";
    ui_tooltip = "The transparency of the copyright notice.";
    ui_type = "slider";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
> = 1.0;

uniform float cLayer_Scale <
  ui_type = "slider";
	ui_label = "Scale";
	ui_min = 0.01; ui_max = 5.0;
	ui_step = 0.001;
> = 1.000;

uniform float cLayer_PosX <
  ui_type = "slider";
	ui_label = "Position X";
	ui_min = -2.0; ui_max = 2.0;
	ui_step = 0.001;
> = 0.5;

uniform float cLayer_PosY <
  ui_type = "slider";
	ui_label = "Position Y";
	ui_min = -2.0; ui_max = 2.0;
	ui_step = 0.001;
> = 0.5;

texture PSO2_logo_v_texture <source="PSO2_logo_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler PSO2_logo_v_sampler { Texture = PSO2_logo_v_texture; };

texture PSO2_copyright_v_texture <source="copyright_PSO2_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler PSO2_copyright_v_sampler { Texture = PSO2_copyright_v_texture; };

texture GShade_v_texture <source="copyright_by_gshade_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler GShade_v_sampler { Texture =GShade_v_texture; };

texture GShade_White_v_texture <source="copyright_by_gshade_w_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler GShade_White_v_sampler { Texture =GShade_White_v_texture; };

texture Eurostyle_left_v_texture <source="copyright_Eurostyle_left_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Eurostyle_left_v_sampler { Texture = Eurostyle_left_v_texture; };

texture Eurostyle_right_v_texture <source="copyright_Eurostyle_right_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Eurostyle_right_v_sampler { Texture = Eurostyle_right_v_texture; };

texture Futura_center_v_texture <source="copyright_futura_center_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_center_v_sampler { Texture = Futura_center_v_texture; };

texture Futura_Triangle_White_v_texture <source="copyright_futura_tri_w_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_Triangle_White_v_sampler { Texture = Futura_Triangle_White_v_texture; };

texture Futura_Triangle_Black_v_texture <source="copyright_futura_tri_b_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_Triangle_Black_v_sampler { Texture = Futura_Triangle_Black_v_texture; };

texture Rockwell_Nova_White_v_texture <source="copyright_Rockwell_nova_w_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Rockwell_Nova_White_v_sampler { Texture = Rockwell_Nova_White_v_texture; };

texture Rockwell_Nova_Black_v_texture <source="copyright_Rockwell_nova_b_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Rockwell_Nova_Black_v_sampler { Texture = Rockwell_Nova_Black_v_texture; };

texture Swiss911_Condenced_v_texture <source="copyright_Swiss911_UCm_BT_Cn_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swiss911_Condenced_v_sampler { Texture = Swiss911_Condenced_v_texture; };

texture Swis721_Square_White_v_texture <source="copyright_Swis721_square_w_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swis721_Square_White_v_sampler { Texture = Swis721_Square_White_v_texture; };

texture Swis721_Square_Black_v_texture <source="copyright_Swis721_square_b_v.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swis721_Square_Black_v_sampler { Texture = Swis721_Square_Black_v_texture; };
    
void PS_cLayer(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
    const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
    const float2 cLayer_Pos = float2(cLayer_PosX, cLayer_PosY);
    
    if (cLayer_v_Select == 0)
    {
      const float2 scale = 1.0 / (float2(164.0, 684.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(PSO2_logo_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    if (cLayer_v_Select == 1)
    {
      const float2 scale = 1.0 / (float2(31.0, 435.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(PSO2_copyright_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 2)
    {
      const float2 scale = 1.0 / (float2(60.0, 810.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(GShade_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 3)
    {
      const float2 scale = 1.0 / (float2(60.0, 810.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(GShade_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 4)
    {
      const float2 scale = 1.0 / (float2(183.0, 800.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Eurostyle_left_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 5)
    {
      const float2 scale = 1.0 / (float2(183.0, 800.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Eurostyle_right_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 6)
    {
      const float2 scale = 1.0 / (float2(134.0, 535.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_center_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 7)
    {
      const float2 scale = 1.0 / (float2(432.0, 319.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_Triangle_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 8)
    {
      const float2 scale = 1.0 / (float2(432.0, 319.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_Triangle_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 9)
    {
      const float2 scale = 1.0 / (float2(122.0, 471.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Rockwell_Nova_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 10)
    {
      const float2 scale = 1.0 / (float2(122.0, 471.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Rockwell_Nova_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 11)
    {
      const float2 scale = 1.0 / (float2(54.0, 540.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swiss911_Condenced_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 12)
    {
      const float2 scale = 1.0 / (float2(285.0, 261.0 ) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swis721_Square_White_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_v_Select == 13)
    {
      const float2 scale = 1.0 / (float2(285.0, 261.0 ) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swis721_Square_Black_v_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    color.a = backbuffer.a;
}

technique PSO2Copyright_Vertical {
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_cLayer;
    }
}
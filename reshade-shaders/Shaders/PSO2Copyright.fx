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

uniform int cLayer_Select <
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

texture PSO2_logo_texture <source="PSO2_logo.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler PSO2_logo_sampler { Texture = PSO2_logo_texture; };

texture PSO2_copyright_texture <source="copyright_PSO2.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler PSO2_copyright_sampler { Texture = PSO2_copyright_texture; };

texture GShade_texture <source="copyright_by_gshade.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler GShade_sampler { Texture =GShade_texture; };

texture GShade_White_texture <source="copyright_by_gshade_w.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler GShade_White_sampler { Texture =GShade_White_texture; };

texture Eurostyle_left_texture <source="copyright_Eurostyle_left.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Eurostyle_left_sampler { Texture = Eurostyle_left_texture; };

texture Eurostyle_right_texture <source="copyright_Eurostyle_right.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Eurostyle_right_sampler { Texture = Eurostyle_right_texture; };

texture Futura_center_texture <source="copyright_futura_center.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_center_sampler { Texture = Futura_center_texture; };

texture Futura_Triangle_White_texture <source="copyright_futura_tri_w.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_Triangle_White_sampler { Texture = Futura_Triangle_White_texture; };

texture Futura_Triangle_Black_texture <source="copyright_futura_tri_b.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Futura_Triangle_Black_sampler { Texture = Futura_Triangle_Black_texture; };

texture Rockwell_Nova_White_texture <source="copyright_Rockwell_nova_w.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Rockwell_Nova_White_sampler { Texture = Rockwell_Nova_White_texture; };

texture Rockwell_Nova_Black_texture <source="copyright_Rockwell_nova_b.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Rockwell_Nova_Black_sampler { Texture = Rockwell_Nova_Black_texture; };

texture Swiss911_Condenced_texture <source="copyright_Swiss911_UCm_BT_Cn.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swiss911_Condenced_sampler { Texture = Swiss911_Condenced_texture; };

texture Swis721_Square_White_texture <source="copyright_Swis721_square_w.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swis721_Square_White_sampler { Texture = Swis721_Square_White_texture; };

texture Swis721_Square_Black_texture <source="copyright_Swis721_square_b.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Swis721_Square_Black_sampler { Texture = Swis721_Square_Black_texture; };

void PS_cLayer(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
    const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
    const float2 cLayer_Pos = float2(cLayer_PosX, cLayer_PosY);
    
    if (cLayer_Select == 0)
    {
      const float2 scale = 1.0 / (float2(684.0, 164.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(PSO2_logo_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    if (cLayer_Select == 1)
    {
      const float2 scale = 1.0 / (float2(435.0, 31.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(PSO2_copyright_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 2)
    {
      const float2 scale = 1.0 / (float2(810.0, 60.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(GShade_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 3)
    {
      const float2 scale = 1.0 / (float2(810.0, 60.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(GShade_White_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 4)
    {
      const float2 scale = 1.0 / (float2(800.0, 183.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Eurostyle_left_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 5)
    {
      const float2 scale = 1.0 / (float2(800.0, 183.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Eurostyle_right_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 6)
    {
      const float2 scale = 1.0 / (float2(535.0, 134.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_center_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 7)
    {
      const float2 scale = 1.0 / (float2(319.0, 432.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_Triangle_White_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 8)
    {
      const float2 scale = 1.0 / (float2(319.0, 432.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Futura_Triangle_Black_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 9)
    {
      const float2 scale = 1.0 / (float2(471.0, 122.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Rockwell_Nova_White_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 10)
    {
      const float2 scale = 1.0 / (float2(471.0, 122.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Rockwell_Nova_Black_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 11)
    {
      const float2 scale = 1.0 / (float2(540.0, 54.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swiss911_Condenced_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 12)
    {
      const float2 scale = 1.0 / (float2(261.0, 285.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swis721_Square_White_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    else if (cLayer_Select == 13)
    {
      const float2 scale = 1.0 / (float2(261.0, 285.0) / ReShade::ScreenSize * cLayer_Scale);
      const float4 cLayer  = tex2D(Swis721_Square_Black_sampler, texcoord * scale + (1.0 - scale) * cLayer_Pos);
  	  color = lerp(backbuffer, cLayer, cLayer.a * cLayer_Blend);
    }
    color.a = backbuffer.a;
}

technique PSO2Copyright {
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_cLayer;
    }
}
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

#ifndef Layer2Tex
#define Layer2Tex "Layer2.png" // Add your own image file to \reshade-shaders\Textures\ and provide the new file name in quotes to change the image displayed!
#endif

uniform float Layer_Two_Blend <
    ui_label = "Opacity";
    ui_tooltip = "The transparency of the layer.";
    ui_type = "slider";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
> = 1.0;

uniform float Layer_Two_Scale <
  ui_type = "slider";
	ui_label = "Scale";
	ui_min = 0.01; ui_max = 5.0;
	ui_step = 0.001;
> = 1.001;

uniform float Layer_Two_PosX <
  ui_type = "slider";
	ui_label = "Position X";
	ui_min = -2.0; ui_max = 2.0;
	ui_step = 0.001;
> = 0.5;

uniform float Layer_Two_PosY <
  ui_type = "slider";
	ui_label = "Position Y";
	ui_min = -2.0; ui_max = 2.0;
	ui_step = 0.001;
> = 0.5;

texture Layer_Two_texture <source=Layer2Tex;> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format=RGBA8; };
sampler Layer_Two_sampler { Texture = Layer_Two_texture; };

void PS_Layer_Two(in float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target) {
    const float4 backbuffer = tex2D(ReShade::BackBuffer, texcoord);
    const float2 Layer_Pos = float2(Layer_Two_PosX, Layer_Two_PosY);
    const float2 scale = 1.0 / (float2(BUFFER_WIDTH, BUFFER_HEIGHT) / ReShade::ScreenSize * Layer_Two_Scale);
    const float4 Layer  = tex2D(Layer_Two_sampler, texcoord * scale + (1.0 - scale) * Layer_Pos);
  	color = lerp(backbuffer, Layer, Layer.a * Layer_Two_Blend);
  	color.a = backbuffer.a;
}

technique Layer2 {
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_Layer_Two;
    }
}
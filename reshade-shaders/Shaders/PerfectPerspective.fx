/*
Copyright (c) 2018 Jacob Maximilian Fober

This work is licensed under the Creative Commons 
Attribution-NonCommercial-NoDerivatives 4.0 International License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-nc-nd/4.0/ 

For inquiries please contact jakub.m.fober@pm.me
*/

// Perfect Perspective PS ver. 2.7.1


	  ////////////
	 /// MENU ///
	////////////


uniform int Projection <
	ui_tooltip = "Stereographic projection (shape) preserves angles and proportions,\n"
	             "best for navigation through tight space.\n\n"
	             "Equisolid projection (distance) preserves size relations,\n"
	             "best for navigation in open areas.\n\n"
	             "Equidistant (speed) maintains angular speed of motion,\n"
	             "best for chasing fast targets.";
	ui_label = "Type of projection";
	ui_type = "radio";
	ui_items = "Stereographic projection (shape)\0Equisolid projection (distance)\0Equidistant projection (speed)\0";
	ui_category = "Distortion Correction";
> = 0;

uniform int FOV <
	ui_label = "Corrected Field of View";
	ui_tooltip = "This setting should match your in-game Field of View";
	ui_type = "slider";
	ui_step = 0.2;
	ui_min = 0; ui_max = 170;
	ui_category = "Distortion Correction";
> = 90;

uniform float Vertical <
	ui_label = "Vertical Curviness Amount";
	ui_tooltip = "0.0 - cylindrical projection\n"
		"1.0 - spherical projection";
		ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
	ui_category = "Distortion Correction";
> = 0.5;

uniform float VerticalScale <
	ui_type = "slider";
	ui_label = "Vertical Proportions Scale";
	ui_tooltip = "Adjust proportions for cylindrical Panini projection";
	ui_min = 0.8; ui_max = 1.0;
	ui_category = "Distortion Correction";
> = 0.95;

uniform int Type <
	ui_label = "Type of FOV (Field of View)";
	ui_tooltip = "...in stereographic mode\n\n"
		"If image bulges in movement (too high FOV),\n"
		"change it to 'Diagonal'.\n"
		"When proportions are distorted at the periphery\n"
		"(too low FOV), choose 'Vertical'.";
	ui_type = "combo";
	ui_items = "Horizontal FOV\0Diagonal FOV\0Vertical FOV\0";
	ui_category = "Distortion Correction";
> = 0;

uniform float Zooming <
	ui_label = "Borders Scale";
	ui_tooltip = "Adjust image scale and cropped area";
	ui_type = "slider";
	ui_min = 0.5; ui_max = 2.0; ui_step = 0.001;
	ui_category = "Borders Settings";
> = 1.0;

uniform float4 BorderColor <
	ui_label = "Color of Borders";
	ui_tooltip = "Use Alpha to change transparency";
	ui_type = "color";
	ui_category = "Borders Settings";
> = float4(0.027, 0.027, 0.027, 0.0);

uniform bool MirrorBorders <
	ui_label = "Mirrored Borders";
	ui_tooltip = "Choose original or mirrored image at the borders";
	ui_category = "Borders Settings";
> = true;

uniform bool DebugPreview <
	ui_label = "Display Resolution Scale Map";
	ui_tooltip = "Color map of the Resolution Scale:\n\n"
		" Red   - undersampling\n"
		" Green - supersampling\n"
		" Blue  - neutral sampling";
	ui_category = "Debug Tools";
> = false;

uniform int2 ResScale <
	ui_label = "Super Resolution Scale";
	ui_tooltip = "Simulates application running beyond\n"
		"native screen resolution (using VSR or DSR)\n\n"
		" First value  - screen resolution\n"
		" Second value - virtual super resolution";
	ui_type = "slider";
	ui_min = 16; ui_max = 16384; ui_step = 0.2;
	ui_category = "Debug Tools";
> = int2(1920, 1920);


	  //////////////
	 /// SHADER ///
	//////////////

#include "ReShade.fxh"

// Define screen texture with mirror tiles
sampler SamplerColor
{
	Texture = ReShade::BackBufferTex;
	AddressU = MIRROR;
	AddressV = MIRROR;
};

// Convert RGB to grayscale
float Grayscale(float3 Color)
{ return max(max(Color.r,Color.g),Color.b); }

// Perspective lookup functions by Jacob Max Fober
// Input data:
	// FOV >> Camera Field of View in degrees
	// Coordinates >> UV coordinates (from -1, to 1), where (0,0) is at the center of the screen
// Stereographic
float Stereographic(float2 Coordinates)
{
	if(FOV==0.0) return 1.0; // Bypass
	// Convert 1/4 FOV to radians and calc tangent squared
	const float SqrTanFOVq = pow(tan(radians(FOV * 0.25)),2.0);
	const float R2 = dot(Coordinates, Coordinates);
	return (1.0 - SqrTanFOVq) / (1.0 - SqrTanFOVq * R2);
}
// Equisolid
float Equisolid(float2 Coordinates)
{
	if(FOV==0.0) return 1.0; // Bypass
	const float rFOV = radians(FOV);
	const float R = length(Coordinates);
	return tan(asin(sin(rFOV*0.25)*R)*2.0)/(tan(rFOV*0.5)*R);
}
// Equidistant
float Equidistant(float2 Coordinates)
{
	if(FOV==0.0) return 1.0; // Bypass
	const float rFOVh = radians(FOV*0.5);
	const float R = length(Coordinates);
	return tan(R*rFOVh)/(tan(rFOVh)*R);
}


// Shader pass
float3 PerfectPerspectivePS(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	// Get Aspect Ratio
	const float AspectR = 1.0 / ReShade::AspectRatio;
	// Get Screen Pixel Size
	const float2 ScrPixelSize = ReShade::PixelSize;

	// Convert FOV type..
	float FovType; switch(Type)
	{
		case 0:{ FovType = 1.0; break; } // Horizontal
		case 1:{ FovType = sqrt(AspectR * AspectR + 1.0); break; } // Diagonal
		case 2:{ FovType = AspectR; break; } // Vertical
	}

	// Convert UV to Radial Coordinates
	float2 SphCoord = texcoord * 2.0 - 1.0;
	// Aspect Ratio correction
	SphCoord.y *= AspectR;
	// Zoom in image and adjust FOV type (pass 1 of 2)
	// SphCoord *= Zooming / FovType;
	SphCoord *= clamp(Zooming, 0.5, 2.0) / FovType; // Anti-cheat

	// Perspective lookup, vertical distortion amount and FOV type (pass 2 of 2)
	switch(Projection)
	{
		case 0:{ SphCoord *= Stereographic(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } // Conformal
		case 1:{ SphCoord *= Equisolid(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } // Equal area
		case 2:{ SphCoord *= Equidistant(float2(SphCoord.x, sqrt(Vertical) * SphCoord.y)) * FovType; break; } // Linear scaled
	}

	// Aspect Ratio back to square
	SphCoord.y /= AspectR;

	// vertical proportions adjust
	if(VerticalScale != 1.0) SphCoord.y /= lerp(VerticalScale, 1.0, Vertical);

	// Get Pixel Size in stereographic coordinates
	const float2 PixelSize = fwidth(SphCoord);

	// Outside borders check with Anti-Aliasing
	const float2 AtBorders = smoothstep( 1.0 - PixelSize, 1.0 + PixelSize, abs(SphCoord) );

	// Back to UV Coordinates
	SphCoord = SphCoord * 0.5 + 0.5;

	// Sample display image
	float3 Display = tex2D(SamplerColor, SphCoord).rgb;

	// Mask outside-border pixels or mirror
	if (MirrorBorders)
		Display = lerp(
			Display,
			lerp(
				Display, 
				BorderColor.rgb, 
				BorderColor.a
			), 
			max(AtBorders.x, AtBorders.y)
		);
	else
		Display = lerp(
			Display,
			lerp(		
				tex2D(SamplerColor, texcoord).rgb, 
				BorderColor.rgb, 
				BorderColor.a
			), 
			max(AtBorders.x, AtBorders.y)
		);

	// Output type choice
	if(DebugPreview)
	{
		// Calculate radial screen coordinates before and after perspective transformation
		float4 RadialCoord = float4(texcoord, SphCoord) * 2.0 - 1.0;
		// Correct vertical aspect ratio
		RadialCoord.yw *= AspectR;

		// Define Mapping color
		static const float3 UnderSmpl = float3(1.0, 0.0, 0.2); // Red
		static const float3 SuperSmpl = float3(0.0, 1.0, 0.5); // Green
		static const float3 NeutralSmpl = float3(0.0, 0.5, 1.0); // Blue

		// Calculate Pixel Size difference...
		float PixelScaleMap = fwidth( length(RadialCoord.xy) );
		// ...and simulate Dynamic Super Resolution (DSR) scalar
		PixelScaleMap *= ResScale.x / (fwidth( length(RadialCoord.zw) ) * ResScale.y);
		PixelScaleMap -= 1.0;

		// Generate supersampled-undersampled color map
		float3 ResMap = lerp(
			SuperSmpl,
			UnderSmpl,
			step(0.0, PixelScaleMap)
		);

		// Create black-white gradient mask of scale-neutral pixels
		PixelScaleMap = 1.0 - abs(PixelScaleMap);
		PixelScaleMap = saturate(PixelScaleMap * 4.0 - 3.0); // Clamp to more representative values

		// Color neutral scale pixels
		ResMap = lerp(ResMap, NeutralSmpl, PixelScaleMap);

		// Blend color map with display image
		Display = normalize(ResMap) * (0.8 * Grayscale(Display) + 0.2);
	}

	return Display;
}


	  //////////////
	 /// OUTPUT ///
	//////////////

technique PerfectPerspective < ui_label = "Perfect Perspective"; ui_tooltip = "Correct fisheye distortion"; >
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PerfectPerspectivePS;
	}
}

/*
	PandaFX version 2.2.1 for ReShade 4
	by Jukka Korhonen aka Loadus ~ twitter.com/thatbonsaipanda
	November 2018
	jukka.korhonen@gmail.com
	
	Modified by Marot Satil for ReShade 4.0 compatibility and lightly optimized for the GShade project.
	
	Applies cinematic lens effects and color grading.
	Free licence to copy, modify, tweak and publish but
	if you can, give credit. Thanks. o/
	
	- jP
 */

#include "ReShade.fxh"

// ------------------------------------

uniform float Blend_Amount <
	ui_label = "Blend Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Blend the effect with the original image.";
> = 1.0;

// ------------------------------------

uniform bool Enable_Diffusion <
	ui_label = "Enable the lens diffusion effect";
	ui_tooltip = "Enable a light diffusion that emulates the glare of a camera lens.";
> = true;

uniform bool Enable_Bleach_Bypass <
	ui_label = "Enable the 'Bleach Bypass' effect";
	ui_tooltip = "Enable a cinematic contrast effect that emulates a bleach bypass on film. Used a lot in war movies and gives the image a grittier feel.";
> = true;

uniform bool Enable_Dither <
	ui_label = "Dither";
	ui_tooltip = "Dither the final result.";
> = true;


// ------------------------------------

uniform float Contrast_R <
    ui_label = "Contrast (Red)";
	ui_type = "slider";
	ui_min = 0.00001;
	ui_max = 20.0;
	ui_tooltip = "Apply contrast to red.";
> = 2.2;

uniform float Contrast_G <
    ui_label = "Contrast (Green)";
	ui_type = "slider";
	ui_min = 0.00001;
	ui_max = 20.0;
	ui_tooltip = "Apply contrast to green.";
> = 2.0;

uniform float Contrast_B <
    ui_label = "Contrast (Blue)";
	ui_type = "slider";
	ui_min = 0.00001;
	ui_max = 20.0;
	ui_tooltip = "Apply contrast to blue.";
> = 2.0;

uniform float Gamma_R <
    ui_label = "Gamma (Red)";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to red.";
> = 1.0;

uniform float Gamma_G <
    ui_label = "Gamma (Green)";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to green.";
> = 1.0;

uniform float Gamma_B <
    ui_label = "Gamma (Blue)";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to blue.";
> = 1.0;

// ------------------------------------

uniform float Diffusion_1_Amount <
    ui_label = "Diffusion 1 Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the amount of the first diffusion layer.";
> = 0.5;

uniform float Diffusion_2_Amount <
    ui_label = "Diffusion 2 Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the amount of the second diffusion layer.";
> = 0.5;

uniform float Diffusion_3_Amount <
    ui_label = "Diffusion 3 Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the amount of the third diffusion layer.";
> = 0.5;

uniform int Diffusion_1_Radius <
	ui_label = "Diffusion 1 Radius";
	ui_type = "slider";
	ui_min = 5;
	ui_max = 20;
	ui_tooltip = "Set the radius of the first diffusion layer.";
> = 8;

uniform int Diffusion_2_Radius <
	ui_label = "Diffusion 2 Radius";
	ui_type = "slider";
	ui_min = 5;
	ui_max = 20;
	ui_tooltip = "Set the radius of the second diffusion layer.";
> = 8;

uniform int Diffusion_3_Radius <
	ui_label = "Diffusion 3 Radius";
	ui_type = "slider";
	ui_min = 5;
	ui_max = 20;
	ui_tooltip = "Set the radius of the third diffusion layer.";
> = 8;

uniform float Diffusion_1_Gamma <
    ui_label = "Diffusion 1 Gamma";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to first diffusion layer.";
> = 2.2;

uniform float Diffusion_2_Gamma <
    ui_label = "Diffusion 2 Gamma";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to second diffusion layer.";
> = 1.3;

uniform float Diffusion_3_Gamma <
    ui_label = "Diffusion 3 Gamma";
	ui_type = "slider";
	ui_min = 0.02;
	ui_max = 5.0;
	ui_tooltip = "Apply Gamma to third diffusion layer.";
> = 1.0;

// ------------------------------------

uniform float Bleach_Bypass_Amount <
	ui_label = "Bleach Bypass Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the amount of the third diffusion layer.";
> = 0.5;

// ------------------------------------

uniform float Dither_Amount <
    ui_label = "Dither Amount";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the amount of the dither on the diffusion layers (to smooth out banding).";
> = 0.15;

// ------------------------------------

uniform float Diffusion_1_Desaturate <
    ui_label = "Diffusion 1 desaturation";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the saturation of the first diffusion layer.";
> = 0.0;

uniform float Diffusion_2_Desaturate <
    ui_label = "Diffusion 2 desaturation";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the saturation of the second diffusion layer.";
> = 0.5;

uniform float Diffusion_3_Desaturate <
    ui_label = "Diffusion 3 desaturation";
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Adjust the saturation of the third diffusion layer.";
> = 0.75;

// ------------------------------------

uniform float Diffusion_1_Quality <
	ui_label = "Diffusion 1 sampling quality";
	// ui_type = "slider";
	// ui_min = 1;
	// ui_max = 64;
	ui_tooltip = "Set the quality of the first diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 2;

uniform float Diffusion_2_Quality <
	ui_label = "Diffusion 2 sampling quality";
	// ui_type = "slider";
	// ui_min = 1;
	// ui_max = 64;
	ui_tooltip = "Set the quality of the second diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 16;

uniform float Diffusion_3_Quality <
	ui_label = "Diffusion 3 sampling quality";
	// ui_type = "slider";
	// ui_min = 1;
	// ui_max = 64;
	ui_tooltip = "Set the quality of the third diffusion layer. Number is the divider of how many times the texture size is divided in half. Lower number = higher quality, but more processing needed. (No need to adjust this.)";
> = 64;

// ------------------------------------



// Provide a noise texture, basically a gray surface with grain:
texture NoiseTex <source = "hd_noise.png"; > { Width = 1920; Height = 1080; Format = RGBA8; };
sampler NoiseSampler { Texture = NoiseTex; };

texture prePassLayer { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

texture blurLayerHorizontal { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
texture blurLayerVertical { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
texture blurLayerHorizontalMedRes { Width = BUFFER_WIDTH / 16; Height = BUFFER_HEIGHT / 16; Format = RGBA8; };
texture blurLayerVerticalMedRes { Width = BUFFER_WIDTH / 16; Height = BUFFER_HEIGHT / 16; Format = RGBA8; };
texture blurLayerHorizontalLoRes { Width = BUFFER_WIDTH / 64; Height = BUFFER_HEIGHT / 64; Format = RGBA8; };
texture blurLayerVerticalLoRes { Width = BUFFER_WIDTH / 64; Height = BUFFER_HEIGHT / 64; Format = RGBA8; };

uniform float framecount < source = "framecount"; >;

sampler2D PFX_PrePassLayer { Texture = prePassLayer; };

// ------- samplers for large radius blur
sampler2D PFX_blurHorizontalLayer {	Texture = blurLayerHorizontal; };
sampler2D PFX_blurVerticalLayer { Texture = blurLayerVertical; };
sampler2D PFX_blurHorizontalLayerMedRes { Texture = blurLayerHorizontalMedRes; };
sampler2D PFX_blurVerticalLayerMedRes {	Texture = blurLayerVerticalMedRes; };
sampler2D PFX_blurHorizontalLayerLoRes { Texture = blurLayerHorizontalLoRes; };
sampler2D PFX_blurVerticalLayerLoRes { Texture = blurLayerVerticalLoRes; };


float AdjustableSigmoidCurve (float value, float amount) {

	float curve = 1.0; 

    if (value < 0.5)
    {
        curve = pow(value, amount) * pow(2.0, amount) * 0.5; 
    }
        
    else
    { 	
    	curve = 1.0 - pow(abs(1.0 - value), amount) * pow(2.0, amount) * 0.5; 
    }

    return curve;
}

float Randomize (float2 coord) {
	return clamp((frac(sin(dot(coord, float2(12.9898, 78.233))) * 43758.5453)), 0.0, 1.0);
}

float SigmoidCurve (float value) {
	const value = value * 2.0 - 1.0;
	return -value * abs(value) * 0.5 + value + 0.5;	
}

float SoftLightBlend (float A, float B) {
	
	if (A > 0.5)
	{
		return (2 * A - 1) * (sqrt(B) - B) + B; 
	}

	else
	{
		return (2 * A - 1) * (B - (B * 2)) + B; 
	}	

	return 0;
}

float4 BlurH (sampler input, float2 uv, float radius, float sampling) {


	float2 coordinate = float2(0.0, 0.0);
	float4 A = float4(0.0, 0.0, 0.0, 1.0); 
	float4 C = float4(0.0, 0.0, 0.0, 1.0);
	float weight = 1.0; 
	const float width = 1.0 / BUFFER_WIDTH * sampling;					
	float divisor = 0.000001; 

		for (float x = -radius; x <= radius; x++)
		{
			coordinate = uv + float2(x * width, 0.0);
			coordinate = clamp(coordinate, 0.0, 1.0); 
			A = tex2Dlod(input, float4(coordinate, 0.0, 0.0));		
				weight = SigmoidCurve(1.0 - (abs(x) / radius));		
				C += A * weight; 		
			divisor += weight;
		}
	
	return C / divisor; 
}

float4 BlurV (sampler input, float2 uv, float radius, float sampling) {

	float2 coordinate = float2(0.0, 0.0);
	float4 A = float4(0.0, 0.0, 0.0, 1.0); 
	float4 C = float4(0.0, 0.0, 0.0, 1.0); 
	float weight = 1.0; 	
	const float height = 1.0 / BUFFER_HEIGHT * sampling;					
	float divisor = 0.000001; 

		for (float y = -radius; y <= radius; y++)
		{
			coordinate = uv + float2(0.0, y * height);
			coordinate = clamp(coordinate, 0.0, 1.0);		
			A = tex2Dlod(input, float4(coordinate, 0.0, 0.0));	
				weight = SigmoidCurve(1.0 - (abs(y) / radius)); 		
				C += A * weight; 		
			divisor += weight;
		}

	return C / divisor; 
}


void PS_PrePass (float4 pos : SV_Position, 
				 float2 uv : TEXCOORD, 
				 out float4 result : SV_Target) 
{

	float4 A = tex2D(ReShade::BackBuffer, uv);
		   A.r = pow(abs(A.r), Gamma_R);
		   A.g = pow(abs(A.g), Gamma_G);
		   A.b = pow(abs(A.b), Gamma_B);
		   A.r = AdjustableSigmoidCurve(A.r, Contrast_R);
		   A.g = AdjustableSigmoidCurve(A.g, Contrast_G);
		   A.b = AdjustableSigmoidCurve(A.b, Contrast_B);
	
	// ------- Change color weights of the final render, similar to a printed film

		A.g = A.g * 0.8 + A.b * 0.2;

		float red = A.r - A.g - A.b;
		float green = A.g - A.r - A.b;
		float blue = A.b - A.r - A.g;

		red = clamp(red, 0.0, 1.0);
		green = clamp(green, 0.0, 1.0);
		blue = clamp(blue, 0.0, 1.0);

		A = A * (1.0 - red * 0.6);
		A = A * (1.0 - green * 0.8);	
		A = A * (1.0 - blue * 0.3);
		
		// A.r = AdjustableSigmoidCurve(A.r, 1.4);
		// A.r = pow(A.r, 1.1);	
		
		result = A;
}


void PS_HorizontalPass (float4 pos : SV_Position, 
						float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurH(PFX_PrePassLayer, uv, Diffusion_1_Radius, Diffusion_1_Quality);
	// result = BlurH(ReShade::BackBuffer, uv, Diffusion_1_Radius, Diffusion_1_Quality);
}

void PS_VerticalPass (float4 pos : SV_Position, 
					  float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurV(PFX_blurHorizontalLayer, uv, Diffusion_1_Radius, Diffusion_1_Quality);
}

void PS_HorizontalPassMedRes (float4 pos : SV_Position, 
						float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurH(PFX_blurVerticalLayer, uv, Diffusion_2_Radius, Diffusion_2_Quality);
}

void PS_VerticalPassMedRes (float4 pos : SV_Position, 
					  float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurV(PFX_blurHorizontalLayerMedRes, uv, Diffusion_2_Radius, Diffusion_2_Quality);
}

void PS_HorizontalPassLoRes (float4 pos : SV_Position, 
						float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurH(PFX_blurVerticalLayerMedRes, uv, Diffusion_3_Radius, Diffusion_3_Quality);
}

void PS_VerticalPassLoRes (float4 pos : SV_Position, 
					  float2 uv : TEXCOORD, out float4 result : SV_Target) 
{
	result = BlurV(PFX_blurHorizontalLayerLoRes, uv, Diffusion_3_Radius, Diffusion_3_Quality);
}




float4 PandaComposition (float4 vpos : SV_Position, 
						 float2 uv : TEXCOORD) : SV_Target 
{
	// ------- Create blurred layers for lens diffusion

		float4 blurLayer;
		float4 blurLayerMedRes;
		float4 blurLayerLoRes;
	
	if (Enable_Diffusion)
	{
		// TODO enable/disable for performance >>
		blurLayer = tex2D(PFX_blurVerticalLayer, uv);
		blurLayerMedRes = tex2D(PFX_blurVerticalLayerMedRes, uv);
		blurLayerLoRes = tex2D(PFX_blurVerticalLayerLoRes, uv);
		

			// ------- Blur layer colors

				const float4 blurLayerGray = dot(0.3333, blurLayer.rgb);
				blurLayer = lerp(blurLayer, blurLayerGray, Diffusion_2_Desaturate);

				const float4 blurLayerMedResGray = dot(0.3333, blurLayerMedRes.rgb);
				blurLayerMedRes = lerp(blurLayerMedRes, blurLayerMedResGray, Diffusion_2_Desaturate);

				const float4 blurLayerLoResGray = dot(0.3333, blurLayerLoRes.rgb);
				blurLayerLoRes = lerp(blurLayerLoRes, blurLayerLoResGray, Diffusion_3_Desaturate);

				// blurLayerMedRes.g *= 0.75;
				// blurLayerMedRes.b *= 0.5;

				// blurLayerLoRes.g *= 0.75;
				// blurLayerLoRes.r *= 0.5;


			// ------- Set blur layer weights

				blurLayer *= Diffusion_1_Amount;
				blurLayerMedRes *= Diffusion_2_Amount;
				blurLayerLoRes *= Diffusion_3_Amount;
			
				blurLayer = pow(abs(blurLayer), Diffusion_1_Gamma);
				blurLayerMedRes = pow(abs(blurLayerMedRes), Diffusion_2_Gamma);
				blurLayerLoRes = pow(abs(blurLayerLoRes), Diffusion_3_Gamma);
	}


	// ------- Read original image

		float4 A = tex2D(PFX_PrePassLayer, uv);
		const float4 O = tex2D(ReShade::BackBuffer, uv);

	// ------- Screen blend the blur layers to create lens diffusion

		if (Enable_Diffusion) 
		{
			blurLayer = clamp(blurLayer, 0.0, 1.0);
			blurLayerMedRes = clamp(blurLayerMedRes, 0.0, 1.0);
			blurLayerLoRes = clamp(blurLayerLoRes, 0.0, 1.0);

	 		A.rgb = 1.0 - (1.0 - blurLayer.rgb) * (1.0 - A.rgb);
			A.rgb = 1.0 - (1.0 - blurLayerMedRes.rgb) * (1.0 - A.rgb);
			A.rgb = 1.0 - (1.0 - blurLayerLoRes.rgb) * (1.0 - A.rgb);
		}


	// ------ Compress contrast using Hard Light blending ------
		
		if (Enable_Bleach_Bypass)
		{
			float Ag = dot(float3(0.3333, 0.3333, 0.3333), A.rgb);
			float4 B = A;
			float4 C = 0;

			if (Ag > 0.5)
			{
				C = 1 - 2 * (1 - Ag) * (1 - B);
			}

			else
			{
				C = 2 * Ag * B;
			}

			C = pow(abs(C), 0.6);
			A = lerp(A, C, Bleach_Bypass_Amount);
		}


	// ------- Dither the composition to eliminate banding

		if (Enable_Dither)
		{
			float4 rndSample = tex2D(NoiseSampler, uv);
			float uvRnd = Randomize(rndSample.xy * framecount);
			float uvRnd2 = Randomize(-rndSample.xy * framecount);

			float4 Nt = tex2D(NoiseSampler, uv * uvRnd);
			float4 Nt2 = tex2D(NoiseSampler, uv * uvRnd2);
			float4 Nt3 = tex2D(NoiseSampler, -uv * uvRnd);

			float3 noise = float3(Nt.x, Nt2.x, Nt3.x);

			float4 B = A;

			B.r = SoftLightBlend(noise.r, A.r);
			B.g = SoftLightBlend(noise.g, A.g);
			B.b = SoftLightBlend(noise.b, A.b);

			A = lerp(A, B, Dither_Amount);
		}

	// ------ Compress to TV levels if needed ------
		
		// A = A * 0.9373 + 0.0627;

	return lerp(O, A, Blend_Amount);
}

technique PandaFX 
{
		pass PreProcess	
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_PrePass;
			RenderTarget = prePassLayer;
		}

		pass HorizontalPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_HorizontalPass;
			RenderTarget = blurLayerHorizontal;
		}

		pass VerticalPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_VerticalPass;
			RenderTarget = blurLayerVertical;
		}

		pass HorizontalPassMedRes
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_HorizontalPassMedRes;
			RenderTarget = blurLayerHorizontalMedRes;
		}

		pass VerticalPassMedRes
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_VerticalPassMedRes;
			RenderTarget = blurLayerVerticalMedRes;
		}

		pass HorizontalPassLoRes
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_HorizontalPassLoRes;
			RenderTarget = blurLayerHorizontalLoRes;
		}

		pass VerticalPassLoRes
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_VerticalPassLoRes;
			RenderTarget = blurLayerVerticalLoRes;
		}

	pass CustomPass
	{
		VertexShader = PostProcessVS;
		PixelShader = PandaComposition ;
	}
}
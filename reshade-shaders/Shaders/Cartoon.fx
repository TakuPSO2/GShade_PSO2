/**
 * Cartoon
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 */
 // Lightly optimized by Marot Satil for the GShade project.

uniform float Power <
	ui_type = "slider";
	ui_min = 0.1; ui_max = 10.0;
	ui_tooltip = "Amount of effect you want.";
> = 1.5;
uniform float EdgeSlope <
	ui_type = "slider";
	ui_min = 0.1; ui_max = 6.0;
	ui_label = "Edge Slope";
	ui_tooltip = "Raise this to filter out fainter edges. You might need to increase the power to compensate. Whole numbers are faster.";
> = 1.5;

#include "ReShade.fxh"

float3 CartoonPass(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);

	float diff1 = dot(coefLuma, tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize).rgb);
	diff1 = dot(float4(coefLuma, -1.0), float4(tex2D(ReShade::BackBuffer, texcoord - ReShade::PixelSize).rgb , diff1));
	float diff2 = dot(coefLuma, tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize * float2(1, -1)).rgb);
	diff2 = dot(float4(coefLuma, -1.0), float4(tex2D(ReShade::BackBuffer, texcoord + ReShade::PixelSize * float2(-1, 1)).rgb , diff2));

	const float edge = dot(float2(diff1, diff2), float2(diff1, diff2));

	return saturate(pow(abs(edge), EdgeSlope) * -Power + color);
}

technique Cartoon
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CartoonPass;
	}
}

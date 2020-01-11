#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\Common.fx"
#line 17
namespace MartyMcFly
{
#line 20
texture2D texNoise      < source = "mcnoise.png"; > {Width = 1920;Height = 1080;Format = RGBA8;};
#line 23
sampler2D SamplerNoise
{
Texture = texNoise;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Wrap;
AddressV = Wrap;
};
}

#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\VHSPro.fx"
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
#line 1 "C:\Program Files (x86)\SEGA\PHANTASYSTARONLINE2\pso2_bin\reshade-shaders\Shaders\VHSPro.fx"
#line 11
uniform float screenLinesNum <
ui_type = "slider";
ui_min = "1.0";
ui_max = "(float)BUFFER_HEIGHT";
ui_label = "Screen Resolution [VHSPro]";
ui_tooltip = "Screen Resolution (in lines).\nChange screenLinesRes in Preprocessor Definitions to have the same value as this.";
> = (float)1080;
#line 19
uniform bool VHS_Bleed <
ui_label = "Bleeding [VHSPro]";
ui_tooltip = "Enables beam screen bleeding (makes the image blurry).";
> = true;
#line 24
uniform int VHS_BleedMode <
ui_type = "combo";
ui_items = "Three Phase\0Old Three Phase\0Two Phase (slow)\0Three-Phase (RetroArch)\0Two Phase (RetroArch)\0";
ui_label = "Bleeding Mode [VHSPro]";
ui_tooltip = "Toggles between different bleeding modes.";
> = 0;
#line 31
uniform float bleedAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "15.0";
ui_label = "Bleed Stretch [VHSPro]";
ui_tooltip = "Length of the bleeding.";
> = 1.0;
#line 39
uniform bool VHS_FishEye <
ui_label = "Fisheye [VHSPro]";
ui_tooltip = "Enables a CRT Curvature.";
> = true;
#line 44
uniform bool VHS_FishEye_Hyperspace <
ui_label = "Fisheye Hyperspace [VHSPro]";
ui_tooltip = "Changes the curvature to look like some sort of hyperspace warping.";
> = false;
#line 49
uniform float fisheyeBend <
ui_type = "slider";
ui_min = "0.0";
ui_max = "50.0";
ui_label = "Fisheye Bend [VHSPro]";
ui_tooltip = "Curvature of the CRT.";
> = 2.0;
#line 57
uniform float cutoffX <
ui_type = "slider";
ui_min = "0.0";
ui_max = "50.0";
ui_label = "Fisheye Cutoff X [VHSPro]";
ui_tooltip = "Cutoff of the Horizontal Borders.";
> = 2.0;
#line 65
uniform float cutoffY <
ui_type = "slider";
ui_min = "0.0";
ui_max = "50.0";
ui_label = "Fisheye Cutoff Y [VHSPro]";
ui_tooltip = "Cutoff of the Vertical Borders.";
> = 3.0;
#line 73
uniform float cutoffFadeX <
ui_type = "slider";
ui_min = "0.0";
ui_max = "50.0";
ui_label = "Fisheye Cutoff Fade X [VHSPro]";
ui_tooltip = "Size of the Horizontal gradient cutoff.";
> = 25.0;
#line 81
uniform float cutoffFadeY <
ui_type = "slider";
ui_min = "0.0";
ui_max = "50.0";
ui_label = "Fisheye Cutoff Fade Y [VHSPro]";
ui_tooltip = "Size of the Vertical gradient cutoff.";
> = 25.0;
#line 89
uniform bool VHS_Vignette <
ui_type = "bool";
ui_label = "Vignette [VHSPro]";
ui_tooltip = "Enables screen vignetting";
> = false;
#line 95
uniform float vignetteAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Vignette Amount [VHSPro]";
ui_tooltip = "Strength of the vignette.";
> = 1.0;
#line 103
uniform float vignetteSpeed <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Vignette Pulse Speed [VHSPro]";
ui_tooltip = "Speed of the vignette pulsing. (Setting it to 0 makes it stop pulsing)";
> = 1.0;
#line 111
uniform float noiseLinesNum <
ui_type = "slider";
ui_min = "1.0";
ui_max = "(float)BUFFER_HEIGHT";
ui_label = "Vertical Resolution [VHSPro]";
ui_tooltip = "Noise Resolution (in lines).\nChange noiseLinesRes in Preprocessor Definitions to have the same value as this.";
> = 240.0;
#line 119
uniform float noiseQuantizeX <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.0";
ui_label = "Quantize Noise X [VHSPro]";
ui_tooltip = "Makes the noise longer or shorter.";
> = 0.0;
#line 127
uniform bool VHS_FilmGrain <
ui_label = "Film Grain [VHSPro]";
ui_tooltip = "Enables a Film Grain on the screen.";
> = false;
#line 132
uniform float filmGrainAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "0.1";
ui_label = "Film Grain Alpha [VHSPro]";
ui_tooltip = "Intensity of the Film Grain.";
> = 0.016;
#line 140
uniform bool VHS_YIQNoise <
ui_label = "Signal Noise [VHSPro]";
ui_tooltip = "Adds noise to the YIQ Signal, causing a Pink (or green) noise.";
> = true;
#line 145
uniform int signalNoiseType <
ui_type = "combo";
ui_items = "Type 1\0Type 2\0Type 3\0";
ui_label = "Signal Noise Type [VHS Pro]";
> = 0;
#line 151
uniform float signalNoiseAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.0";
ui_label = "Signal Noise Amount [VHSPro]";
ui_tooltip = "Amount of the signal noise.";
> = 0.15;
#line 159
uniform float signalNoisePower <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.0";
ui_label = "Signal Noise Power [VHSPro]";
ui_tooltip = "Power of the signal noise. Higher values will make it green, lower values will make it more pink.";
> =  0.83;
#line 167
uniform bool VHS_LineNoise <
ui_label = "Line Noise [VHSPro]";
ui_tooltip = "Enables blinking line noise in the image.";
> = true;
#line 172
uniform float lineNoiseAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "10.0";
ui_label = "Line Noise Amount [VHSPro]";
ui_tooltip = "Intensity of the line noise.";
> = 1.0;
#line 180
uniform float lineNoiseSpeed <
ui_type = "slider";
ui_min = "0.0";
ui_max = "10.0";
ui_label = "Line Noise Speed [VHSPro]";
ui_tooltip = "Speed of the line noise blinking delay.";
> = 5.0;
#line 188
uniform bool VHS_TapeNoise <
ui_label = "Tape Noise [VHSPro]";
ui_tooltip = "Adds scrolling noise like in old VHS Tapes.";
> = true;
#line 193
uniform float tapeNoiseTH <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.5";
ui_label = "Tape Noise Amount [VHSPro]";
ui_tooltip = "Intensity of Tape Noise in the image.";
> = 0.63;
#line 201
uniform float tapeNoiseAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.5";
ui_label = "Tape Noise Alpha [VHSPro]";
ui_tooltip = "Amount of Tape Noise in the image.";
> = 1.0;
#line 209
uniform float tapeNoiseSpeed <
ui_type = "slider";
ui_min = "-1.5";
ui_max = "1.5";
ui_label = "Tape Noise Speed [VHSPro]";
ui_tooltip = "Scrolling speed of the Tape Noise.";
> = 1.0;
#line 217
uniform bool VHS_ScanLines <
ui_label = "Scanlines [VHSPro]";
ui_tooltip = "Enables TV/CRT Scanlines";
> = false;
#line 222
uniform float scanLineWidth <
ui_type = "slider";
ui_min = "0.0";
ui_max = "20.0";
ui_label = "Scanlines Width [VHSPro]";
ui_tooltip = "Width of the Scanlines";
> = 10.0;
#line 230
uniform bool VHS_LinesFloat	<
ui_label = "Lines Float [VHSPro]";
ui_tooltip = "Makes the lines of the screen floats up or down. Works best with low Screen Lines resolutions.";
> = false;
#line 235
uniform float linesFloatSpeed <
ui_type = "slider";
ui_min = "-3.0";
ui_max = "3.0";
ui_label = "Lines Float Speed [VHSPro]";
ui_tooltip = "Speed (and direction) of the floating lines.";
> = 1.0;
#line 243
uniform bool VHS_Stretch <
ui_label = "Stretch Noise [VHSPro]";
ui_tooltip = "Enables a stretching noise that scrolls up and down on the Image, simulating magnetic interference of VHS tapes.";
> = true;
#line 248
uniform bool VHS_Jitter_H <
ui_type = "bool";
ui_label = "Interlacing [VHSPro]";
ui_tooltip = "Enables Interlacing.";
> = true;
#line 254
uniform float jitterHAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Interlacing Amount [VHSPro]";
ui_tooltip = "Strength of the Interlacing.";
> = 0.5;
#line 262
uniform bool VHS_Jitter_V <
ui_label = "Jitter [VHSPro]";
ui_tooltip = "Adds vertical jittering noise.";
> = false;
#line 267
uniform float jitterVAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "15.0";
ui_label = "Jitter Amount [VHSPro]";
ui_tooltip = "Amount of the vertical jittering noise.";
> = 1.0;
#line 275
uniform float jitterVSpeed <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Jitter Speed [VHSPro]";
ui_tooltip = "Speed of the vertical jittering noise.";
> = 1.0;
#line 283
uniform bool VHS_Twitch_H <
ui_label = "Horizontal Twitch [VHSPro]";
ui_tooltip = "Makes the image twitches horizontally in certain timed intervals.";
> = false;
#line 288
uniform float twitchHFreq <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Horizontal Twitch Frequency [VHSPro]";
ui_tooltip = "Frequency of time in which the image twitches horizontally.";
> = 1.0;
#line 296
uniform bool VHS_Twitch_V <
ui_label = "Vertical Twitch [VHSPro]";
ui_tooltip = "Makes the image twitches vertically in certain timed intervals.";
> = false;
#line 301
uniform float twitchVFreq <
ui_type = "slider";
ui_min = "0.0";
ui_max = "5.0";
ui_label = "Vertical Twitch Frequency [VHSPro]";
ui_tooltip = "Frequency of time in which the image twitches vertically.";
> = 1.0;
#line 309
uniform bool VHS_SignalTweak <
ui_label = "Signal Tweak [VHSPro]";
ui_tooltip = "Tweak the values of the YIQ signal.";
> = false;
#line 314
uniform float signalAdjustY <
ui_type = "slider";
ui_min = "-0.25";
ui_max = "0.25";
ui_label = "Signal Shift Y [VHSPro]";
ui_tooltip = "Shifts/Tweaks the Luma part of the signal.";
> = 0.0;
uniform float signalAdjustI <
ui_type = "slider";
ui_min = "-0.25";
ui_max = "0.25";
ui_label = "Signal Shift I [VHSPro]";
ui_tooltip = "Shifts/Tweaks the Chroma part of the signal.";
> = 0.0;
#line 329
uniform float signalAdjustQ <
ui_type = "slider";
ui_min = "-0.25";
ui_max = "0.25";
ui_label = "Signal Shift Q [VHSPro]";
ui_tooltip = "Shifts/Tweaks the Chroma part of the signal.";
> = 0.0;
#line 337
uniform float signalShiftY <
ui_type = "slider";
ui_min = "-2.0";
ui_max = "2.0";
ui_label = "Signal Adjust Y [VHSPro]";
ui_tooltip = "Adjusts the Luma part of the signal.";
> = 1.0;
#line 345
uniform float signalShiftI <
ui_type = "slider";
ui_min = "-2.0";
ui_max = "2.0";
ui_label = "Signal Adjust I [VHSPro]";
ui_tooltip = "Adjusts the Chroma part of the signal.";
> = 1.0;
#line 353
uniform float signalShiftQ <
ui_type = "slider";
ui_min = "-2.0";
ui_max = "2.0";
ui_label = "Signal Adjust Q [VHSPro]";
ui_tooltip = "Adjusts the Chroma part of the signal.";
> = 1.0;
#line 361
uniform float gammaCorection <
ui_type = "slider";
ui_min = "0.0";
ui_max = "2.0";
ui_label = "Signal Gamma Correction [VHSPro]";
ui_tooltip = "Gamma corrects the image.";
> = 1.0;
#line 369
uniform bool VHS_Feedback <
ui_label = "Phosphor Trails [VHSPro]";
ui_tooltip = "Enables phosphor-trails from old CRT monitors.";
> = false;
#line 374
uniform float feedbackAmount <
ui_type = "slider";
ui_min = "0.0";
ui_max = "3.0";
ui_label = "Input Amount [VHSPro]";
ui_tooltip = "Amount of Phosphor Trails.";
> = 2.0;
#line 382
uniform float feedbackFade <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.0";
ui_label = "Phosphor Fade [VHSPro]";
ui_tooltip = "Fade-time of the phosphor-trails.";
> = 0.82;
#line 390
uniform float feedbackThresh <
ui_type = "slider";
ui_min = "0.0";
ui_max = "1.0";
ui_label = "Input Cutoff [VHSPro]";
ui_tooltip = "Cutoff of the trail.";
> = 0.1;
#line 398
uniform float3 feedbackColor <
ui_type = "color";
ui_label = "Phosphor Trail Color [VHSPro]";
ui_tooltip = "Color of the trail.";
> = float3(1.0,0.5,0.0);
#line 404
uniform bool feedbackDebug <
ui_type = "bool";
ui_label = "Debug Trail [VHS Pro]";
ui_tooltip = "Enables the visualization of the phosphor-trails only.";
> = false;
#line 410
uniform int VHS_Filter <
ui_type = "slider";
ui_min ="0.0";
ui_max ="0.0";
ui_label = "Linear Filtering [VHSPro]";
ui_tooltip = "Filters the image linearly, increasing quality.\nDefine VHSLINEARFILTER in Preprocessor Definitions to take effect, this is only here as a reminder.";
> = 0.0;
#line 433
static const float fisheyeSize = 1.2; 					
static const float filmGrainPower = 1.0;				
static const float feedbackAmp = 1.0; 					
#line 439
uniform float  Timer < source = "timer"; >;
#line 441
static const float Pi2 = 6.283185307;
#line 446
texture2D VHS_InputTexA    { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D VHS_InputTexB    { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D VHS_FeedbackTexA { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D VHS_FeedbackTexB { Width = 1920; Height = 1080; Format = RGBA8; };
texture2D _TapeTex { Width = int(((float)int(240.0	)*(float)1920/(float)1080)); Height = int(240.0	); Format = RGBA8; };
#line 452
sampler2D SamplerColorVHS
{
Texture = ReShade::BackBufferTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU = Clamp;
AddressV = Clamp;
};
#line 462
sampler2D SamplerTape
{
Texture = _TapeTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU = Clamp;
AddressV = Clamp;
};
#line 472
sampler2D VHS_InputA    { Texture = VHS_InputTexA; MinFilter = POINT;  MagFilter = POINT;  MipFilter = POINT; };
sampler2D VHS_InputB    { Texture = VHS_InputTexB; MinFilter = POINT;  MagFilter = POINT;  MipFilter = POINT; };
sampler2D VHS_FeedbackA { Texture = VHS_FeedbackTexA; MinFilter = POINT;  MagFilter = POINT;  MipFilter = POINT; };
sampler2D _FeedbackTex { Texture = VHS_FeedbackTexB; MinFilter = POINT;  MagFilter = POINT;  MipFilter = POINT; };
#line 480
static const float3 MOD3 = float3(443.8975, 397.2973, 491.1871);
#line 482
float fmod(float a, float b) {
const float c = frac(abs(a / b)) * abs(b);
if (a < 0)
return -c;
else
return c;
}
#line 490
float3 bms(float3 c1, float3 c2){ return 1.0- (1.0-c1)*(1.0-c2); }
#line 493
float onOff(float a, float b, float c, float t)
{
return step(c, sin(t + a*cos(t*b)));
}
#line 498
float hash( float n ){ return frac(sin(n)*43758.5453123); }
#line 500
float hash12(float2 p){
float3 p3  = frac(float3(p.xyx) * MOD3);
p3 += dot(p3, p3.yzx + 19.19);
return frac(p3.x * p3.z * p3.y);
}
#line 506
float2 hash22(float2 p) {
float3 p3 = frac(float3(p.xyx) * MOD3);
p3 += dot(p3.zxy, p3.yzx+19.19);
return frac(float2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}
#line 513
float4 hash42(float2 p)
{
float4 p4 = frac(float4(p.xyxy) * float4(443.8975,397.2973, 491.1871, 470.7827));
p4 += dot(p4.wzxy, p4 + 19.19);
return frac(float4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}
#line 520
float niq( in float3 x ){
const float3 p = floor(x);
float3 f = frac(x);
f = f*f*(3.0-2.0*f);
const float n = p.x + p.y*57.0 + 113.0*p.z;
return lerp(lerp(		lerp( hash(n+  0.0), hash(n+  1.0),f.x),
lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
lerp( lerp( hash(n+113.0), hash(n+114.0),f.x),
lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}
#line 531
float filmGrain(float2 uv, float t, float c )
{
#line 534
return pow(hash12( uv + 0.07*frac( t ) ), 3);
}
#line 537
float2 n4rand_bw( float2 p, float t, float c )
{
t = frac( t );
float2 nrnd0 = hash22( p + 0.07*t );
c = 1.0 / (10.0*c); 
return pow(nrnd0, c); 
}
#line 545
float scanLines(float2 p, float t)
{
#line 553
float t_sl = 0.0;
#line 555
if (VHS_LinesFloat) {
t_sl = t*linesFloatSpeed;
}
#line 560
float scans = 0.5*(cos( (p.y*screenLinesNum+t_sl)*2.0*3.14159265359) + 1.0);
scans = pow(scans, scanLineWidth);
return 1.0 - scans;
}
#line 565
float gcos(float2 uv, float s, float p)
{
return (cos( uv.y * 3.14159265359 * 2.0 * s + p)+1.0)*0.5;
}
#line 574
float2 stretch(float2 uv, float t, float mw, float wcs, float lfs, float lfp){
#line 576
const float SLN = screenLinesNum; 
#line 578
const float tt = t*wcs; 
const float t2 = tt-fmod(tt, 0.5);
#line 582
float w = gcos(uv, 2.0*(1.0-frac(t2)), 3.14159265359-t2) * clamp( gcos(uv, frac(t2), t2) , 0.5, 1.0);
#line 584
w = floor(w*mw)/mw;
w *= mw;
#line 587
float ln = (1.0-frac(t*lfs + lfp)) *screenLinesNum;
ln = ln - frac(ln);
#line 597
const float oy = 1.0/SLN; 
const float sh2 =  1.0 - fmod(ln, w)/w; 
#line 609
const float slb = SLN / w; 
#line 619
if(uv.y<oy*ln && uv.y>oy*(ln-w)) 
uv.y = floor( uv.y*slb +sh2 )/slb - (sh2-1.0)/slb ;
#line 624
return uv;
}
#line 627
float rnd_rd(float2 co)
{
return frac(sin(fmod(dot(co.xy ,float2(12.9898,78.233)),3.14)) * 43758.5453);
}
#line 633
float3 rgb2yiq(float3 c)
{
return float3(
0.2989*c.x + 0.5959*c.y + 0.2115*c.z,
0.5870*c.x - 0.2744*c.y - 0.5229*c.z,
0.1140*c.x - 0.3216*c.y + 0.3114*c.z);
};
#line 641
float3 yiq2rgb(float3 c)
{
return float3(
1.0*c.x +1.0*c.y +1.0*c.z,
0.956*c.x - 0.2720*c.y - 1.1060*c.z,
0.6210*c.x - 0.6474*c.y + 1.7046*c.z);
};
#line 650
float3 rgbDistortion(float2 uv,  float magnitude, float t)
{
magnitude *= 0.0001; 
float3 offsetX = float3( uv.x, uv.x, uv.x );
offsetX.r += rnd_rd(float2(t*0.03,uv.y*0.42)) * 0.001 + sin(rnd_rd(float2(t*0.2, uv.y)))*magnitude;
offsetX.g += rnd_rd(float2(t*0.004,uv.y*0.002)) * 0.004 + sin(t*9.0)*magnitude;
#line 659
float3 col = float3(0.0, 0.0, 0.0);
#line 661
col.x = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.r, uv.y) ).rgb ).x;
col.y = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.g, uv.y) ).rgb ).y;
col.z = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.b, uv.y) ).rgb ).z;
#line 665
col = yiq2rgb(col);
return col;
}
#line 669
float rndln(float2 p, float t)
{
float sample_ln = rnd_rd(float2(1.0,2.0*cos(t))*t*8.0 + p*1.0).x;
sample_ln *= sample_ln;
return sample_ln;
}
#line 676
float lineNoise(float2 p, float t)
{
float n = rndln(p* float2(0.5,1.0) + float2(1.0,3.0), t)*20.0;
#line 680
float freq = abs(sin(t));  
float c = n*smoothstep(fmod(p.y*4.0 + t/2.0+sin(t + sin(t*0.63)),freq), 0.0,0.95);
#line 683
return c;
}
#line 688
float n( in float3 x )
{
const float3 p = floor(x);
float3 f = frac(x);
f = f*f*(3.0-2.0*f);
const float n = p.x + p.y*57.0 + 113.0*p.z;
return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
lerp( lerp( hash(n+113.0), hash(n+114.0),f.x),
lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}
#line 700
float tapeNoiseLines(float2 p, float t){
#line 706
const float y = p.y*float2(1920, 1080).y;
const float s = t*2.0;
return  	(niq( float3(y*0.01 +s, 			1.0, 1.0) ) + 0.0)
*(niq( float3(y*0.011+1000.0+s,	1.0, 1.0) ) + 0.0)
*(niq( float3(y*0.51+421.0+s, 	1.0, 1.0) ) + 0.0)
;
}
#line 715
float tapeNoise(float nl, float2 p, float t){
#line 723
float nm = 	hash12( frac(p+t*float2(0.234,0.637)) )
#line 726
;
nm = pow(nm, 4) +0.3; 
#line 730
nl*= nm; 
#line 733
if(nl<tapeNoiseTH) nl = 0.0; else nl =1.0;  
return nl;
}
#line 737
float2 twitchVertical(float freq, float2 uv, float t){
#line 739
float vShift = 0.4*onOff(freq,3.0,0.9, t);
vShift*=(sin(t)*sin(t*20.0) + (0.5 + 0.1*sin(t*200.0)*cos(t)));
uv.y = fmod(uv.y + vShift, 1.0);
return uv;
}
#line 745
float2 twitchHorizonal(float freq, float2 uv, float t){
#line 747
uv.x += sin(uv.y*10.0 + t)/50.0*onOff(freq,4.0,0.3, t)*(1.0+cos(t*80.0))*(1.0/(1.0+20.0*(uv.y-fmod(t/4.0,1.0))*(uv.y-fmod(t/4.0, 1.0))));
return uv;
}
#line 757
float2 fishEye(float2 uv, float size, float bend)
{
if (!VHS_FishEye_Hyperspace){
uv -= float2(0.5,0.5);
uv *= size*(1.0/size+bend*uv.x*uv.x*uv.y*uv.y);
uv += float2(0.5,0.5);
}
#line 765
if (VHS_FishEye_Hyperspace){
#line 769
const float prop = float2(1920, 1080).x / float2(1920, 1080).y;
const float2 m = float2(0.5, 0.5 / prop);
const float2 d = (uv*float2(1920, 1080).xy) /float2(1920, 1080).x - m;
const float r = sqrt(dot(d, d));
float bind;
#line 775
float power = ( 2.0 * 3.141592 / (2.0 * sqrt(dot(m, m))) ) *
(bend/50.0 - 0.5); 
#line 778
if (power > 0.0) bind = sqrt(dot(m, m));
else {if (prop < 1.0) bind = m.x; else bind = m.x;}
#line 781
if (power > 0.0) 
uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
else if (power < 0.0) 
uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
else uv = (uv*float2(1920, 1080).xy) /float2(1920, 1080).x;
#line 787
uv.y *=  prop;
}
#line 795
return uv;
}
#line 799
float vignette(float2 uv, float t)
{
const float vigAmt = 2.5+0.1*sin(t + 5.0*cos(t*5.0));
float c = (1.0-vigAmt*(uv.y-0.5)*(uv.y-0.5))*(1.0-vigAmt*(uv.x-0.5)*(uv.x-0.5));
c = pow(abs(c), vignetteAmount); 
return c;
}
#line 807
float3 t2d(float2 p)
{
return rgb2yiq( tex2D (SamplerColorVHS, p ).rgb );
}
#line 812
float3 yiqDist(float2 uv, float m, float t)
{
m *= 0.0001; 
float3 offsetX = float3( uv.x, uv.x, uv.x );
#line 817
offsetX.r += rnd_rd(float2(t*0.03, uv.y*0.42)) * 0.001 + sin(rnd_rd(float2(t*0.2, uv.y)))*m;
offsetX.g += rnd_rd(float2(t*0.004,uv.y*0.002)) * 0.004 + sin(t*9.0)*m;
#line 822
float3 signal = float3(0.0, 0.0, 0.0);
#line 824
signal.x = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.r, uv.y) ).rgb ).x;
signal.y = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.g, uv.y) ).rgb ).y;
signal.z = rgb2yiq( tex2D( SamplerColorVHS, float2(offsetX.b, uv.y) ).rgb ).z;
#line 829
return signal;
}
#line 838
float4 PS_VHS1(float4 pos : SV_Position, float2 txcoord : TEXCOORD) : SV_Target
{
const float t = Timer.x * 0.001;
float2 p = txcoord.xy;
#line 843
float SLN = screenLinesNum; 
float SLN_Noise = noiseLinesNum; 
float ONE_X = 0.0;
float ONE_Y = 0.0;
#line 850
SLN = screenLinesNum; 
SLN_Noise = noiseLinesNum; 
if(SLN==0.0) SLN = float2(1920, 1080).y;
#line 854
if(SLN_Noise==0 || SLN_Noise>SLN) SLN_Noise = SLN;
#line 856
ONE_X = 1.0/float2(1920, 1080).x; 
ONE_Y = 1.0/float2(1920, 1080).y;
#line 860
if (VHS_Twitch_V){
p = twitchVertical(0.5*twitchVFreq, p, t);
}
#line 864
if (VHS_Twitch_H){
p = twitchHorizonal(0.1*twitchHFreq, p, t);
}
#line 869
if(VHS_LinesFloat){
float sh = frac(-t*linesFloatSpeed); 
#line 872
p.y = -floor( -p.y * SLN + sh )/SLN + sh/SLN;  
#line 874
} else {
#line 876
p.y = -floor( -p.y * SLN )/SLN;  
#line 878
}
#line 880
if (VHS_Stretch){
p = stretch(p, t, 15.0, 1.0, 0.5, 0.0);
p = stretch(p, t, 8.0, 1.2, 0.45, 0.5);
p = stretch(p, t, 11.0, 0.5, -0.35, 0.25); 
}
#line 886
if (VHS_Jitter_H){
if( fmod( p.y * SLN, 2.0)<1.0)
p.x += ONE_X*sin(t*13000.0)*jitterHAmount;
}
#line 892
float3 col = float3(0.0,0.0,0.0);
float3 signal = float3(0.0,0.0,0.0);
#line 899
float2 pn = p;
if(SLN!=SLN_Noise){
if(VHS_LineNoise){
const float sh = frac(t); 
pn.y = floor( pn.y * SLN_Noise + sh )/SLN_Noise - sh/SLN_Noise;
} else  {
pn.y = floor( pn.y * SLN_Noise )/SLN_Noise;
}
}
#line 910
const float ScreenLinesNumX = SLN_Noise * float2(1920, 1080).x / float2(1920, 1080).y;
const float SLN_X = noiseQuantizeX*(float2(1920, 1080).x - ScreenLinesNumX) + ScreenLinesNumX;
pn.x = floor( pn.x * SLN_X )/SLN_X;
#line 914
const float2 pn_ = pn*float2(1920, 1080).xy;
#line 917
const float ONEXN = 1.0/SLN_X;
#line 920
float distShift = 0; 
#line 922
if (VHS_TapeNoise) {
#line 925
distShift = 0; 
for (int ii = 0; ii < 20 % 1023; ii++){
#line 930
const float tnl = tex2Dlod(SamplerTape, float4(0.0,pn.y-ONEXN*ii, 0.0, 0.0)).y;
#line 935
if(tnl>0.55) {
#line 937
const float sh = sin( 1.0*3.14159265359*(float(ii)/float(20))) ; 
p.x -= float(int(sh)*4.0*ONEXN); 
distShift += sh ; 
#line 942
}
}
}
#line 949
if (VHS_Jitter_V){
signal = yiqDist(p, jitterVAmount, t*jitterVSpeed);
} else {
col = tex2D(SamplerColorVHS, p).rgb;
#line 954
signal = rgb2yiq(col);
}
#line 958
if (VHS_LineNoise || VHS_FilmGrain){
signal.x += tex2D(SamplerTape, pn).z;
}
#line 963
if (VHS_YIQNoise){
if (signalNoiseType == 0) {
#line 967
const float2 noise = n4rand_bw( pn_,t,1.0-signalNoisePower ) ;
signal.y += (noise.x*2.0-1.0)*signalNoiseAmount*signal.x;
signal.z += (noise.y*2.0-1.0)*signalNoiseAmount*signal.x;
} else if (signalNoiseType == 1){
#line 972
const float2 noise = n4rand_bw( pn_,t, 1.0-signalNoisePower ) ;
signal.y += (noise.x*2.0-1.0)*signalNoiseAmount;
signal.z += (noise.y*2.0-1.0)*signalNoiseAmount;
} else {
#line 977
const float2 noise = n4rand_bw( pn_,t, 1.0-signalNoisePower )*signalNoiseAmount ;
signal.y *= noise.x;
signal.z *= noise.y;
signal.x += (noise.x*2.0-1.0)*0.05;
}
}
#line 985
if (VHS_TapeNoise){
#line 988
float tn = tex2D(SamplerTape, pn).x;
signal.x = bms(signal.x, tn*tapeNoiseAmount ).x;
#line 993
const int tailLength=10; 
#line 995
for(int j = 0; j < tailLength % 1023; j++){
#line 997
const float jj = float(j);
const float2 d = float2(pn.x-ONEXN*jj,pn.y);
tn = tex2Dlod(SamplerTape, float4(d,0.0,0.0) ).x;
#line 1003
float fadediff = 0.0;
#line 1006
if(36864 == 0x0A100 || 36864 == 0x0B000) {
fadediff = tex2Dlod(SamplerTape, float4(d,0.0,0.0)).a; 
}
#line 1010
if(36864 == 0x09300 || 36864 >= 0x10000) {
fadediff = tex2D(SamplerTape, d).a; 
}
#line 1014
if( tn > 0.8 ){
float nsx =  0.0; 
const float newlength = float(tailLength)*(1.0-fadediff); 
if( jj <= newlength ) nsx = 1.0-( jj/ newlength ); 
signal.x = bms(signal.x, nsx*tapeNoiseAmount).x;
}
}
#line 1023
if(distShift>0.4){
#line 1025
const float tnl = tex2D(SamplerTape, pn).y;
signal.y *= 1.0/distShift;
signal.z *= 1.0/distShift;
#line 1029
}
}
#line 1034
col = yiq2rgb(signal);
#line 1037
if (VHS_ScanLines){
col *= scanLines(txcoord.xy, t);
}
#line 1043
if (VHS_FishEye){
#line 1045
p = txcoord.xy;
#line 1047
float far;
const float2 hco = float2(ONE_X*cutoffX, ONE_Y*cutoffY); 
const float2 sco = float2(ONE_X*cutoffFadeX, ONE_Y*cutoffFadeY); 
#line 1052
if( p.x<=(0.0+hco.x) || p.x>=(1.0-hco.x) || p.y<=(0.0+hco.y) || p.y>=(1.0-hco.y) ){
col = float3(0.0,0.0,0.0);
} else {
#line 1057
if( 
(p.x>(0.0+hco.x) && p.x<(0.0+(sco.x+hco.x) )) || (p.x>(1.0-(sco.x+hco.x)) && p.x<(1.0-hco.x))
){
if(p.x<0.5)	far = (0.0-hco.x+p.x)/(sco.x);
else
far = (1.0-hco.x-p.x)/(sco.x);
#line 1064
col *= float(far).xxx;
};
#line 1067
if( 
(p.y>(0.0+hco.y) 			 && p.y<(0.0+(sco.y+hco.y) )) || (p.y>(1.0-(sco.y+hco.y)) && p.y<(1.0-hco.y))
){
if(p.y<0.5)	far = (0.0-hco.y+p.y)/(sco.y);
else
far = (1.0-hco.y-p.y)/(sco.y);
#line 1074
col *= float(far).xxx;
}
}
}
#line 1081
return float4(col, 1.0);
#line 1083
}
#line 1085
float4 PS_VHS2(float4 pos : SV_Position, float2 txcoord : TEXCOORD) : SV_Target
{
const float t = Timer.x * 0.001;
float2 p = txcoord.xy;
float SLN = screenLinesNum; 
#line 1092
if(SLN==0.0) SLN = float2(1920, 1080).y;
#line 1098
float ONE_X = 1.0 / float2(1920, 1080).x;  
ONE_X *= bleedAmount; 
#line 1102
if (VHS_FishEye){
p = fishEye(p, fisheyeSize, fisheyeBend); 
#line 1105
}
#line 1107
int bleedLength = 21;
#line 1109
if((VHS_BleedMode == 0 || VHS_BleedMode == 1 || VHS_BleedMode == 3))
{
bleedLength = 25;
}
#line 1114
if((VHS_BleedMode == 2 || VHS_BleedMode == 4))
{
bleedLength = 32;
}
#line 1119
float luma_filter[33] = {
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000
};
#line 1155
float chroma_filter[33] = {
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000,
0.000000000
};
#line 1191
if (VHS_BleedMode == 0 || VHS_BleedMode == 3){ 
luma_filter[0] =	-0.000012020;
luma_filter[1] =	-0.000022146;
luma_filter[2] =	-0.000013155;
luma_filter[3] =	-0.000012020;
luma_filter[4] =	-0.000049979;
luma_filter[5] =	-0.000113940;
luma_filter[6] =	-0.000122150;
luma_filter[7] =	-0.000005612;
luma_filter[8] =	0.000170516;
luma_filter[9] =	0.000237199;
luma_filter[10] =	0.000169640;
luma_filter[11] =	0.000285688;
luma_filter[12] =	0.000984574;
luma_filter[13] =	0.002018683;
luma_filter[14] =	0.002002275;
luma_filter[15] =	-0.000909882;
luma_filter[16] =	-0.007049081;
luma_filter[17] =	-0.013222860;
luma_filter[18] =	-0.012606931;
luma_filter[19] =	0.002460860;
luma_filter[20] =	0.035868225;
luma_filter[21] =	0.084016453;
luma_filter[22] =	0.135563500;
luma_filter[23] =	0.175261268;
luma_filter[24] =	0.190176552;
#line 1218
chroma_filter[0] =	-0.000118847;
chroma_filter[1] =	-0.000271306;
chroma_filter[2] =	-0.000502642;
chroma_filter[3] =	-0.000930833;
chroma_filter[4] =	-0.001451013;
chroma_filter[5] =	-0.002064744;
chroma_filter[6] =	-0.002700432;
chroma_filter[7] =	-0.003241276;
chroma_filter[8] =	-0.003524948;
chroma_filter[9] =	-0.003350284;
chroma_filter[10] =	-0.002491729;
chroma_filter[11] =	-0.000721149;
chroma_filter[12] =	0.002164659;
chroma_filter[13] =	0.006313635;
chroma_filter[14] =	0.011789103;
chroma_filter[15] =	0.018545660;
chroma_filter[16] =	0.026414396;
chroma_filter[17] =	0.035100710;
chroma_filter[18] =	0.044196567;
chroma_filter[19] =	0.053207202;
chroma_filter[20] =	0.061590275;
chroma_filter[21] =	0.068803602;
chroma_filter[22] =	0.074356193;
chroma_filter[23] =	0.077856564;
chroma_filter[24] =	0.079052396;
}
#line 1245
else if (VHS_BleedMode == 1) { 
luma_filter[0] = -0.000071070;
luma_filter[1] = -0.000032816;
luma_filter[2] = 0.000128784;
luma_filter[3] = 0.000134711;
luma_filter[4] = -0.000226705;
luma_filter[5] = -0.000777988;
luma_filter[6] = -0.000997809;
luma_filter[7] = -0.000522802;
luma_filter[8] = 0.000344691;
luma_filter[9] = 0.000768930;
luma_filter[10] = 0.000275591;
luma_filter[11] = -0.000373434;
luma_filter[12] = 0.000522796;
luma_filter[13] = 0.003813817;
luma_filter[14] = 0.007502825;
luma_filter[15] = 0.006786001;
luma_filter[16] = -0.002636726;
luma_filter[17] = -0.019461182;
luma_filter[18] = -0.033792479;
luma_filter[19] = -0.029921972;
luma_filter[20] = 0.005032552;
luma_filter[21] = 0.071226466;
luma_filter[22] = 0.151755921;
luma_filter[23] = 0.218166470;
luma_filter[24] = 0.243902439;
#line 1272
chroma_filter[0] = 0.001845562;
chroma_filter[1] = 0.002381606;
chroma_filter[2] = 0.003040177;
chroma_filter[3] = 0.003838976;
chroma_filter[4] = 0.004795341;
chroma_filter[5] = 0.005925312;
chroma_filter[6] = 0.007242534;
chroma_filter[7] = 0.008757043;
chroma_filter[8] = 0.010473987;
chroma_filter[9] = 0.012392365;
chroma_filter[10] = 0.014503872;
chroma_filter[11] = 0.016791957;
chroma_filter[12] = 0.019231195;
chroma_filter[13] = 0.021787070;
chroma_filter[14] = 0.024416251;
chroma_filter[15] = 0.027067414;
chroma_filter[16] = 0.029682613;
chroma_filter[17] = 0.032199202;
chroma_filter[18] = 0.034552198;
chroma_filter[19] = 0.036677005;
chroma_filter[20] = 0.038512317;
chroma_filter[21] = 0.040003044;
chroma_filter[22] = 0.041103048;
chroma_filter[23] = 0.041777517;
chroma_filter[24] = 0.042004791;
}
#line 1299
else if (VHS_BleedMode == 2) { 
luma_filter[0] =	-0.000205844;
luma_filter[1] =	-0.000149453;
luma_filter[2] =	-0.000051693;
luma_filter[3] =	0.000000000;
luma_filter[4] =	-0.000066171;
luma_filter[5] =	-0.000245058;
luma_filter[6] =	-0.000432928;
luma_filter[7] =	-0.000472644;
luma_filter[8] =	-0.000252236;
luma_filter[9] =	0.000198929;
luma_filter[10] =	0.000687058;
luma_filter[11] =	0.000944112;
luma_filter[12] =	0.000803467;
luma_filter[13] =	0.000363199;
luma_filter[14] =	0.000013422;
luma_filter[15] =	0.000253402;
luma_filter[16] =	0.001339461;
luma_filter[17] =	0.002932972;
luma_filter[18] =	0.003983485;
luma_filter[19] =	0.003026683;
luma_filter[20] =	-0.001102056;
luma_filter[21] =	-0.008373026;
luma_filter[22] =	-0.016897700;
luma_filter[23] =	-0.022914480;
luma_filter[24] =	-0.021642347;
luma_filter[25] =	-0.008863273;
luma_filter[26] =	0.017271957;
luma_filter[27] =	0.054921920;
luma_filter[28] =	0.098342579;
luma_filter[29] =	0.139044281;
luma_filter[30] =	0.168055832;
luma_filter[31] =	0.178571429;
#line 1333
chroma_filter[0] =	0.001384762;
chroma_filter[1] =	0.001678312;
chroma_filter[2] =	0.002021715;
chroma_filter[3] =	0.002420562;
chroma_filter[4] =	0.002880460;
chroma_filter[5] =	0.003406879;
chroma_filter[6] =	0.004004985;
chroma_filter[7] =	0.004679445;
chroma_filter[8] =	0.005434218;
chroma_filter[9] =	0.006272332;
chroma_filter[10] =	0.007195654;
chroma_filter[11] =	0.008204665;
chroma_filter[12] =	0.009298238;
chroma_filter[13] =	0.010473450;
chroma_filter[14] =	0.011725413;
chroma_filter[15] =	0.013047155;
chroma_filter[16] =	0.014429548;
chroma_filter[17] =	0.015861306;
chroma_filter[18] =	0.017329037;
chroma_filter[19] =	0.018817382;
chroma_filter[20] =	0.020309220;
chroma_filter[21] =	0.021785952;
chroma_filter[22] =	0.023227857;
chroma_filter[23] =	0.024614500;
chroma_filter[24] =	0.025925203;
chroma_filter[25] =	0.027139546;
chroma_filter[26] =	0.028237893;
chroma_filter[27] =	0.029201910;
chroma_filter[28] =	0.030015081;
chroma_filter[29] =	0.030663170;
chroma_filter[30] =	0.031134640;
chroma_filter[31] =	0.031420995;
chroma_filter[32] =	0.031517031;
}
#line 1368
else if (VHS_BleedMode == 4) { 
luma_filter[0] =  -0.000174844;
luma_filter[1] =  -0.000205844;
luma_filter[2] =  -0.000149453;
luma_filter[3] =  -0.000051693;
luma_filter[4] = 0.000000000;
luma_filter[5] =  -0.000066171;
luma_filter[6] =  -0.000245058;
luma_filter[7] =  -0.000432928;
luma_filter[8] =  -0.000472644;
luma_filter[9] =  -0.000252236;
luma_filter[10] =  0.000198929;
luma_filter[11] =  0.000687058;
luma_filter[12] =  0.000944112;
luma_filter[13] =  0.000803467;
luma_filter[14] =  0.000363199;
luma_filter[15] =  0.000013422;
luma_filter[16] =  0.000253402;
luma_filter[17] =  0.001339461;
luma_filter[18] =  0.002932972;
luma_filter[19] =  0.003983485;
luma_filter[20] =  0.003026683;
luma_filter[21] =  -0.001102056;
luma_filter[22] =  -0.008373026;
luma_filter[23] =  -0.016897700;
luma_filter[24] =  -0.022914480;
luma_filter[25] =  -0.021642347;
luma_filter[26] =  -0.008863273;
luma_filter[27] =  0.017271957;
luma_filter[28] =  0.054921920;
luma_filter[29] =  0.098342579;
luma_filter[30] =  0.139044281;
luma_filter[31] =  0.168055832;
luma_filter[32] =  0.178571429;
#line 1403
chroma_filter[0] =   0.001384762;
chroma_filter[1] =   0.001678312;
chroma_filter[2] =   0.002021715;
chroma_filter[3] =   0.002420562;
chroma_filter[4] =   0.002880460;
chroma_filter[5] =   0.003406879;
chroma_filter[6] =   0.004004985;
chroma_filter[7] =   0.004679445;
chroma_filter[8] =   0.005434218;
chroma_filter[9] =   0.006272332;
chroma_filter[10] =   0.007195654;
chroma_filter[11] =   0.008204665;
chroma_filter[12] =   0.009298238;
chroma_filter[13] =   0.010473450;
chroma_filter[14] =   0.011725413;
chroma_filter[15] =   0.013047155;
chroma_filter[16] =   0.014429548;
chroma_filter[17] =   0.015861306;
chroma_filter[18] =   0.017329037;
chroma_filter[19] =   0.018817382;
chroma_filter[20] =   0.020309220;
chroma_filter[21] =   0.021785952;
chroma_filter[22] =   0.023227857;
chroma_filter[23] =   0.024614500;
chroma_filter[24] =   0.025925203;
chroma_filter[25] =   0.027139546;
chroma_filter[26] =   0.028237893;
chroma_filter[27] =   0.029201910;
chroma_filter[28] =   0.030015081;
chroma_filter[29] =   0.030663170;
chroma_filter[30] =   0.031134640;
chroma_filter[31] =   0.031420995;
chroma_filter[32] =   0.031517031;
}
#line 1440
float3 signal = float3(0.0,0.0,0.0);
#line 1442
if (VHS_Bleed){
#line 1444
float3 norm = 	float3(0.0,0.0,0.0);
float3 adj = 	float3(0.0,0.0,0.0);
#line 1447
const int taps = bleedLength-4;
#line 1450
for (int ii = 0; float(ii) < float(taps) % 1023; ii++){
#line 1452
const float offset = float(ii);
const float3 sums = 	t2d((p - float2( 0.5 * float2((1.0 / 1920), (1.0 / 1080)).x, .0)) + float2( (offset-float(taps)) * (ONE_X), 0.0)); +
t2d((p - float2( 0.5 * float2((1.0 / 1920), (1.0 / 1080)).x, .0)) + float2( (float(taps)-offset) * (ONE_X), 0.0)); ;
#line 1456
adj = float3(luma_filter[ii+3], chroma_filter[ii], chroma_filter[ii]);
#line 1459
signal += sums * adj;
norm += adj;
#line 1462
}
#line 1464
adj = float3(luma_filter[taps], chroma_filter[taps], chroma_filter[taps]);
#line 1466
signal += t2d((p - float2( 0.5 * float2((1.0 / 1920), (1.0 / 1080)).x, .0))) * adj;
norm += adj;
signal = signal / norm;
} else {
#line 1471
signal = t2d(p);
}
#line 1475
if (VHS_SignalTweak){
#line 1478
signal.x += signalAdjustY;
signal.y += signalAdjustI;
signal.z += signalAdjustQ;
#line 1483
signal.x *= signalShiftY;
signal.y *= signalShiftI;
signal.z *= signalShiftQ;
#line 1502
}
#line 1504
float3 rgb = yiq2rgb(signal);
#line 1506
if (VHS_SignalTweak){
if(gammaCorection!=1.0) rgb = pow(abs(rgb), gammaCorection); 
}
#line 1516
if (VHS_Vignette){
rgb *= vignette(p, t*vignetteSpeed); 
}
#line 1520
return float4(rgb, 1.0);
}
#line 1525
float3 bm_screen(float3 a, float3 b){ 	return 1.0- (1.0-a)*(1.0-b); }
#line 1527
void PS_VHS3(float4 vpos     : SV_Position, out float4 feedbackoutput   : SV_Target0,
float2 texcoord : TEXCOORD,    out float4 feedback : SV_Target1 )
{
float2 p = texcoord.xy;
const float one_x = 1.0/float2(1920, 1080).x;
float3 fc = tex2D( SamplerColorVHS, texcoord).rgb;    
#line 1535
const float3 fl = tex2D( VHS_InputB, texcoord).rgb;    
float  diff = abs(fl.x-fc.x + fl.y-fc.y + fl.z-fc.z)/3.0; 
if(diff<feedbackThresh) diff = 0.0;
float3 fbn = fc*diff*feedbackAmount; 
#line 1542
float3 fbb = ( 
tex2D( _FeedbackTex, texcoord).rgb +
tex2D( _FeedbackTex, texcoord + float2(one_x, 0.0)).rgb +
tex2D( _FeedbackTex, texcoord - float2(one_x, 0.0)).rgb
) / 3.0;
fbb *= feedbackFade;
#line 1550
fc = bm_screen(fc, fbb);
fbn = bm_screen(fbn, fbb); 
feedbackoutput = float4(fc, 1.0);
feedback = float4(fbn * feedbackColor, 1.0);
}
#line 1556
void PS_VHS_Lastframe(float4 vpos     : SV_Position, out float4 feedbackoutput   : SV_Target0,
float2 texcoord : TEXCOORD,    out float4 feedback : SV_Target1)
{
feedbackoutput   = tex2D( VHS_InputA,    texcoord);
feedback = tex2D( VHS_FeedbackA, texcoord);
}
#line 1563
float4 PS_VHS4(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 1566
float3 col = tex2D( SamplerColorVHS, texcoord).rgb; 
const float3 fbb = tex2D( _FeedbackTex, texcoord).rgb; 
#line 1569
if (VHS_Feedback){
col = bm_screen(col, fbb*feedbackAmp);
if (feedbackDebug){
col = fbb;
}
}
#line 1576
return float4(col, 1.0);
}
#line 1579
float4 PS_VHSTape(float4 pos : SV_Position, float2 txcoord : TEXCOORD) : SV_Target
{
const float t = Timer.x * 0.001;
float2 p = txcoord.xy;
#line 1584
p.y=1-p.y;
#line 1586
const float2 p_ = p*float2(1920, 1080);
#line 1588
float ns = 0.0; 
float nt = 0.0; 
float nl = 0.0; 
float ntail = 0.0; 
#line 1593
if (VHS_TapeNoise) {
#line 1596
nl = tapeNoiseLines(p, t*tapeNoiseSpeed)*1.0;
nt = tapeNoise(nl, p, t*tapeNoiseSpeed)*1.0;
ntail = hash12(p+ float2(0.01,0.02) );
}
#line 1601
if (VHS_LineNoise) {
ns += lineNoise(p_, t*lineNoiseSpeed)*lineNoiseAmount;
#line 1604
}
#line 1607
if (VHS_FilmGrain) {
#line 1609
ns += filmGrain((p_-0.5*float2(1920, 1080).xy)*0.5, t, filmGrainPower ) * filmGrainAmount;
}
#line 1612
return float4(nt,nl,ns,ntail);
}
#line 1615
float4 PS_VHSClear(float4 pos : SV_Position, float2 txcoord : TEXCOORD) : SV_Target
{
return float4(tex2D(SamplerColorVHS, txcoord).rgb, 1.0);  
}
#line 1623
technique VHS_Pro
{
pass VHSPro_First
{
VertexShader = PostProcessVS;
PixelShader = PS_VHS1;
}
pass VHSPro_Second
{
VertexShader = PostProcessVS;
PixelShader = PS_VHS2;
}
pass VHSPro_Third
{
VertexShader  = PostProcessVS;
PixelShader   = PS_VHS3;
RenderTarget0 = VHS_InputTexA;
RenderTarget1 = VHS_FeedbackTexA;
}
pass VHSPro_LastFrame
{
VertexShader  = PostProcessVS;
PixelShader   = PS_VHS_Lastframe;
RenderTarget0 = VHS_InputTexB;
RenderTarget1 = VHS_FeedbackTexB;
}
pass VHSPro_Forth
{
VertexShader  = PostProcessVS;
PixelShader   = PS_VHS4;
}
pass VHSPro_Tape
{
VertexShader = PostProcessVS;
PixelShader = PS_VHSTape;
RenderTarget = _TapeTex;
}
pass VHSPro_Clear
{
VertexShader  = PostProcessVS;
PixelShader   = PS_VHSClear;
}
}

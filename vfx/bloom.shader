extern number threshold = 1.0;

extern number canvas_w = 800;
extern number canvas_h = 600;
         
const number offset_1 = 1.5;
const number offset_2 = 3.5;

const number alpha_0 = 0.23;
const number alpha_1 = 0.32;
const number alpha_2 = 0.07;

float luminance(vec3 color)
{
   // numbers make 'true grey' on most monitors, apparently
   return ((0.212671 * color.r) + (0.715160 * color.g) + (0.072169 * color.b));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
   vec4 texcolor = Texel(texture, texture_coords);

   // Vertical blur
   vec3 tc_v = texcolor.rgb * alpha_0;
   
   tc_v += Texel(texture, texture_coords + vec2(0.0, offset_1)/canvas_h).rgb * alpha_1;
   tc_v += Texel(texture, texture_coords - vec2(0.0, offset_1)/canvas_h).rgb * alpha_1;
   
   tc_v += Texel(texture, texture_coords + vec2(0.0, offset_2)/canvas_h).rgb * alpha_2;
   tc_v += Texel(texture, texture_coords - vec2(0.0, offset_2)/canvas_h).rgb * alpha_2;
   
   // Horizontal blur
   vec3 tc_h = texcolor.rgb * alpha_0;

   tc_h += Texel(texture, texture_coords + vec2(offset_1, 0.0)/canvas_w).rgb * alpha_1;
   tc_h += Texel(texture, texture_coords - vec2(offset_1, 0.0)/canvas_w).rgb * alpha_1;
   
   tc_h += Texel(texture, texture_coords + vec2(offset_2, 0.0)/canvas_w).rgb * alpha_2;
   tc_h += Texel(texture, texture_coords - vec2(offset_2, 0.0)/canvas_w).rgb * alpha_2;
   
   // Smooth
   vec3 extract = smoothstep(threshold * 0.7, threshold, luminance(texcolor.rgb)) * texcolor.rgb;
   return vec4(extract + tc_v * 0.8 + tc_h * 0.8, 1.0);
}

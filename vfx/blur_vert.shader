extern number canvas_h = 600;
         
const number offset_1 = 1.3846153846;
const number offset_2 = 3.2307692308;

const number weight_0 = 0.2270270270;
const number weight_1 = 0.3162162162;
const number weight_2 = 0.0702702703;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
   vec4 texcolor = Texel(texture, texture_coords);
   vec3 tc = texcolor.rgb * weight_0;
   
   tc += Texel(texture, texture_coords + vec2(0.0, offset_1)/canvas_h).rgb * weight_1;
   tc += Texel(texture, texture_coords - vec2(0.0, offset_1)/canvas_h).rgb * weight_1;
   
   tc += Texel(texture, texture_coords + vec2(0.0, offset_2)/canvas_h).rgb * weight_2;
   tc += Texel(texture, texture_coords - vec2(0.0, offset_2)/canvas_h).rgb * weight_2;
   
   return color * vec4(tc, 1.0);
}

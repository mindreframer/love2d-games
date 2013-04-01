extern Image bloomtex;

extern number basesaturation = 1.0;
extern number bloomsaturation = 1.0;

extern number baseintensity = 1.0;
extern number bloomintensity = 1.0;

vec3 AdjustSaturation(vec3 color, number saturation)
{
    vec3 grey = vec3(dot(color, vec3(0.212671, 0.715160, 0.072169)));
    return mix(grey, color, saturation);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
   vec4 basecolor = Texel(texture, texture_coords);
   vec4 bloomcolor = Texel(bloomtex, texture_coords);
   
   bloomcolor.rgb = AdjustSaturation(bloomcolor.rgb, bloomsaturation) * bloomintensity;
   basecolor.rgb = AdjustSaturation(basecolor.rgb, basesaturation) * baseintensity;
   
   basecolor.rgb *= (1.0 - clamp(bloomcolor.rgb, 0.0, 1.0));
   
   bloomcolor.a = 0.0;
   
   return clamp(basecolor + bloomcolor, 0.0, 1.0);
}
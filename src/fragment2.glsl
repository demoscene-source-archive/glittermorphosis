uniform sampler3D volume;
float time=gl_TexCoord[0].x;

vec2 v2f_coord=gl_FragCoord.xy/vec2(1920.,1080.)*2.-vec2(1.);

float seed = (int(time*60.)^int(gl_FragCoord.x)*19349663^int(gl_FragCoord.y)*83492791)%38069;
float rand() { return fract(sin(seed++)*43758.545); }

mat2 rotation(float ang)
{
	return mat2(cos(ang),sin(ang),-sin(ang),cos(ang));
}

		float t=0;
		vec3 rp;
		vec4 s=vec4(0);
		vec3 c=vec3(0);
		float alpha=1;

	 float dith=rand(),dof=3;
float fogamount=.015;	 
vec3 fogcol=vec3(0.5,0.5,1.0)/2.;
float focplan=6;

   vec3 ro = vec3(0.0, 0.0, 0), rd = normalize(vec3(v2f_coord * vec2(1., 1080./1920.), -2.5));

void march(float t0,float t1)
{
    for(int i = 0; i < 48; i += 1)
    {
		 t=mix(t0,t1,(float(i)+dith) / 48.);
      rp = ro + rd * t;
		float pp=.5+.5*cos(time*6+rp.x*2+rp.z*3);
		rp.x+=mod(floor(rp.z/2.+.5),2.0);
		rp.y+=cos(rp.x/2.+.5)*sin(rp.z/2.+.5)/3.;
		rp.xz=(rotation(cos(floor(rp.x/2.+.5)*3)*sin(floor(rp.z/2.+.5)*7))*(fract(rp.xz*.5+vec2(.5))-vec2(.5)))*2;
		s = textureLod(volume,rp*.5+vec3(.5),log2(dof*abs(t-focplan)));
		s.rgb=s.r*vec3(.5,1.,.5)+s.g*vec3(4.)+s.b*vec3(2,2,1)*pp*16.;
		s.rgb = mix(fogcol, s.rgb, exp(-t*fogamount));
		c += s.rgb * s.a * alpha;
		alpha *= 1.0 - s.a;
		if(s.a>.99)
			break;
    }
}
	
void main()
{
	ro.z+=6.5;
	ro.yz*=rotation(.3);
	rd.yz*=rotation(.3);
	  
	ro.x+=time/3.;
	ro.z-=time/6.;
	ro.y+=.5;
			 
	march(3.,6.5);
	march(6.5,9.5);
	march(9.5,20.);
	
	gl_FragColor.rgb=(c+vec3(.5,.65,.8)/4.*alpha*step(rd.y,0))*(1.- dot(v2f_coord*v2f_coord,v2f_coord*v2f_coord)*.2);
    gl_FragColor.rgb=(gl_FragColor.rgb/(gl_FragColor.rgb+vec3(.4)))*1.4;
}

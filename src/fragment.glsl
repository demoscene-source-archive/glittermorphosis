#version 130

// need to re-declare the use built-in blocks (gl_PerVertex) to comply with spec and probably to work on AMD
in vec4 gl_TexCoord[2];

uniform sampler2D A;
uniform sampler3D B;
float seed = ((int(gl_TexCoord[0].z)*73856093)^int(gl_FragCoord.x)*19349663^int(gl_FragCoord.y)*83492791)%38069;
float rand() { return fract(sin(seed++)*43758.545); }

float hex(vec2 p)
{
	p*=pow(dot(p,p),.1);
	//p*=pow(length(p),.2);
	p.x*=.8;	
	float p2x=p.x*1.414;
	p=pow(abs(vec2(p.x+p.y,p.x-p.y)-p2x/6),vec2(16));
	return exp((-p.x-p.y-pow(p2x*p2x,8))*8);
}
void main()
{
	gl_FragColor=vec4(0);
	float jitter=rand(),x,r;

	if(gl_TexCoord[0].w==3)
	{
		gl_FragColor=texelFetch(A,ivec2(gl_FragCoord.xy),0);
		// post-processing

		// spikes
		for(int i=-31;i<32;++i)
			for(int k=0;k<3;++k)
				x=jitter+i,
				gl_FragColor+=texelFetch(A,ivec2(gl_FragCoord.xy+x*3*normalize(vec2(1,-2+k*2)))/2,1)*pow(1.-abs(x)/48,2)/56;

		// bloom
		for(int i=-6;i<7;++i)
			for(int j=-6;j<7;++j)
				gl_FragColor+=textureLod(A,(gl_FragCoord.xy+vec2(i,j)*64)/vec2(1280,720),6)/16*max(0.,1.-length(vec2(i,j)/8));

		gl_FragColor*=mat4(vec2(1,.5).rrgg,vec2(.5,.7).rrgg,vec2(.3,1).rrgg,vec4(0));
		gl_FragColor/=gl_FragColor*.56+.45;
	}
	else if(gl_TexCoord[0].w==2)
	{
		// hexagon bake
		
		for(int i=-3;i<4;++i)
			for(int j=-3;j<4;++j)
			{
				x=gl_TexCoord[0].x-128;
				vec2 coord=(vec2(i,j)/6+gl_FragCoord.xy)/(abs(x)+2);
				r=exp(-length(coord));

				gl_FragColor.rg += (x < 0 ? vec2(hex(coord)*1.75, .5*r*r*r)*r*r : vec2(hex(coord), (hex(coord) - hex(coord+normalize(coord)*2/(abs(x)+2)))/4))/49;
			}
			
	}
	else
	{
		// particle
		vec2 p=gl_FragCoord.xy-vec2(1280/2,720/2);
		vec2 v0=gl_TexCoord[1].xy;
		vec2 v1=gl_TexCoord[1].zw-v0;
		r=gl_TexCoord[0].y; // this is the diameter of the particle
		
		if(abs(dot(p-v0,normalize(v1).yx*vec2(1,-1)))>abs(r)/2+4)
			discard;
		
		for(int i=0;i<16;++i)
			gl_FragColor.rg+=texelFetch(B,ivec3(abs(v0+v1*(jitter+i)/16-p)+vec2(rand(),rand())-.5,r/2+128),0).rg;
		
		r=abs(r)+4;
		
		gl_FragColor=(gl_TexCoord[0].x > 0 ? gl_FragColor.rrgg : gl_FragColor.ggrr)/(r*r)*8*abs(gl_TexCoord[0].x);
	}
	
	gl_FragColor+=(vec4(rand(),rand(),rand(),rand())-.5)/255;
}

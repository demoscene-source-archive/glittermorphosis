// music3/4klang.obj, no filtersweep
// 	4086
// 	4074
//		4073
//		4072
//		4065
//

// music5/4klang.obj, no filtersweep
//		4129

// music5/4klang.obj, including filtersweep
//		4284
//		4265
//		4246

//		4091

// fountain, nearly all blue
// galaxy
// planet
// squid? probably something else fits better, 'story'-wise
// heart, nearly all orange, some big blurry blue in the background
// heart is swept away a bit, starts to disintegrate, becomes defocused and then fade to black

// -------

// A Passion For Space (hmm no, still call it Glittermorphosis)
// blue fountain
// blue hanging particles
// they swirl around to make a blue galaxy
// they morph into a blue planet with red bits and red saturn rings
// this morphs into a red heart which beats and glows, causing bright streaks when it beats
// the particles of the heart are falling away and bounce off the floor
// defocus and fade to black

// 3D rounded star shapes with star-emitting wooshes going past (behind)

// -------> http://www.pouet.net/prod.php?which=62464 < ------
//    but in space, and in 4k. and with disco music.


// 00:00 - particle fountain starts
// 00:30 - fountain spins around and becomes a star which turns to the viewer
// 00:40 - other, smaller stars fly in and start to orbit around the bigger star
// 00:50 - smaller stars orbit faster and bigger star starts to spin and they all transform in to the planet
// 01:00 - ring of planet rotates to align with viewer and moves towards viewer, followed behind by other rings, to form a tunnel (like that bit in Arte, also alternating colors like that)
//				the tunnel rings morph in to different shapes, triangle etc. (triangular tunnel trend reference)
// 01:20 - a heart comes through the tunnel and stops in front of viewer, heart is beating and dripping etc.
// 01:30 - heart disintegrates
// 01:40 - the end


// 00:00 - particle fountain starts
// 00:30 - fountain spins around and becomes a star which turns to the viewer
// 00:40 - other, smaller stars fly in and start to orbit around the bigger star
// 00:50 - smaller stars orbit faster and bigger star starts to spin and they all transform in to the planet
// 01:00 - ring of planet rotates and expands like a pulse, and the pulse repeats
// 01:20 - morph in to the dripping heart
// 01:30 - heart disintegrates
// 01:40 - the end

// bigscreen message = 
// particles, depth-of-field, abberations (non-chromatic), bloom, lens flare, motion blur, tonemapping, and SPACEY MUSIC.
// what more do you want?...
//
// p.s. who needs FBOs anyway?

#version 130

// note: the minifier doesn't accept this. need to insert it manually into the minified shader code
//out vec4 gl_Position;
//out float gl_PointSize;
out vec4 gl_TexCoord[2];


float seed;
float pi2=6.283;
float rand() { return fract(sin(seed++)*43758.545); }

//#define R(a) mat2(cos(a), sin(a), -sin(a), cos(a))
mat2 R(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }

vec4 mainParticle(float t)
{	
	float i,j,a,r,w;
	
	vec4 pos0,pos1,pos2,pos3;

	seed = (int(gl_Vertex.x)*73856093)%38069;
		
	t-=clamp(t-30,0,.5)*2;
	t-=clamp(t-30,0,.5)*2-2;

	// fountain
	// vec4 particle3(float x,float t)

	a=rand()*pi2;
	r=sqrt(rand());	
	w=t/50+t/6.7*smoothstep(5,70,t)+(rand() * 2 - 1);
	i=fract(w);
	
	vec3 pos = normalize(vec3(cos(a)*r,1.5,sin(a)*r))*(5.+rand());
//	pos.y+=rand()*3;
	pos.y+=rand()*3-16*i;
	pos*=i;
	//pos.y-=16*i*i;
	
	pos.xz = R(pow(max(0,(t-40+rand()*8)/8.5),4)) * (pos.xz + (vec2(rand(),rand())-.5)*.03);
						
	pos0 = vec4(pos+vec3(0,-.2,.8),(step(i,.9) + step(i,.02) * 2) * step(1,w-i));
					

	// star
	// vec4 particle2(float t)
	w=t-49;
	i=rand();
	j=rand();
	a=i*pi2+cos((i-.15)*pi2*5)*.07;

	pos=vec3(rand(),rand(),rand())*2-1;
	pos.xz*=R(w/10);
	pos1 = vec4(pos,1);

	if(rand()<.8)
	{
		pos=mix(vec3(sin(a),-cos(a),0)*(.9-pow(.1-.1*cos(a*5),.65)),vec3(0,0,float(rand()<.5)*.08-.04),j*j);
		pos.z=sqrt(abs(pos.z))*sign(pos.z); // identical to heart
	
		pos.xy*=R(-(w/7+w*3.8571/exp(w/50)));
		pos.xz*=R(-pi2/4/exp(max(0,w-4)/7));

		pos1 = vec4(pos.yxz*(.6+.4/exp(w/10)),smoothstep(.0,.4,length(pos.xy)));
		pos1.z += .7;
	}


	
	
	// planet
	// particle4
	j=rand();
	a=-asin(1-2*rand());
	w=1;
	
	pos=vec3(rand(),rand(),rand())*2-1;
	pos.xz*=R(t/10);
	pos2 = vec4(pos,.5);

	if(rand()<.4)
	{
		pos=vec3(cos(a),sin(a),0);
		pos.xz*=R(j*pi2);

		if(rand()<.5)
		{
			a=rand()*pi2;
			pos=vec3(cos(a),sin(a),0)*(1.1+.3*j);
			w=-1;
		}

		pos.xy*=R(t+smoothstep(78,83,t)*9);
//		pos.xy*=R(t);
		pos.xz*=R(.5);
		pos.yz*=R(-1.3);
//		pos.xz+=vec2(cos(t),sin(t))/2*sin((t-70)*.39);
		
		pos2 = vec4(pos/2,w);
		pos2.z += 1.25;
	}

	
	
	
	// heart
	// particle(float t)
	t-=87;
	a=.02*pi2+.96*pi2*rand();
	w=1;

	pos=vec3(rand(),rand(),rand())*2-1;
	pos.xz*=R(mix(t/10,2.9,smoothstep(24,33,t)));
	pos3 = vec4(pos,.2-.2*clamp((t-24)/30,0,1));

	if(rand()<.5)
	{
		pos=mix(vec3(-sin(a)*sqrt(cos(a)+1.05),cos(a),0)*sin(a/2), vec3(0,-.3,float(rand()<.5)*.08-.04), .98*pow(rand(),2));
		pos.z=sqrt(abs(pos.z))*sign(pos.z); // identical to star

		pos.xz*=R(cos(t/4)/8);
		a=mod(t+rand()*20,20)-15;
		
		if(a<0&&t>8&&t<24)
		{
			a=fract(t/2-.25);
			pos*=1+.07*sin(a*50)/exp(a*4);
		}
		else
			pos.y-=pow(max(0,a),2.5)/4;
		
		if(t>24.)
		{
			pos.xyz+=normalize(vec3(rand(),rand(),rand())-.5)*(t/24-1);
			w=1-clamp(t/24-1,0,1);
		}

		pos3 = vec4(pos+vec3(0,.3,1),w);
	}
	t+=87;




	a=pow(1.-fract(t),4)*.005;
	i = .04*(.6+.4*cos(gl_Vertex.x)) + pow(.5+.5*cos(gl_Vertex.x*7.+t/4),512);
	
	pos0.w*=-i;
	
	pos1.w*=sign(cos(gl_Vertex.x*3))*i;
	pos1.w+=sign(pos1.w)*a;
	
	pos2.w*=-i;
	pos2.w+=sign(pos2.w)*a;

	pos3.w *= i * 1.5;
	
	return mix(mix(mix(pos0,pos1,smoothstep(0,5,pow(t-45,.7)/1.3)), pos2, smoothstep(0,5,(t-71)/1.3)), pos3, smoothstep(0,5,(t-87)/1.3));
//	return mix(mix(mix(pos0,pos1,smoothstep(0,5,pow(t-45,.7)/1.3)), pos2, smoothstep(0,5,(t-71)/1.3)), pos3, smoothstep(0,5,(t-96)/1.3));
}

void main()
{	
	vec4 v0=mainParticle(gl_MultiTexCoord0.x-.042), v1=mainParticle(gl_MultiTexCoord0.x);
		
	v0.xy*=400/v0.z;
	v1.xy*=400/v1.z;	

	float focalLength = .15 + .07 * smoothstep(1.5,23,gl_MultiTexCoord0.x);
	
	//float objectDistance = (v0.z + v1.z) / 2;
	//float sharpFocusDistance = objectDistance * focalLength / (objectDistance - focalLength);

	float sharpFocusDistance = focalLength / (1 - 2 * focalLength / (v0.z + v1.z));

	//float sharpFocusDistance = 1. / (1. / (.15 + .07 * smoothstep(-.5,15,gl_MultiTexCoord0.x)) - 2. / (v0.z + v1.z));
	
	float r = clamp((.3 - sharpFocusDistance) / sharpFocusDistance * 128, -128, +127); // this is the diameter of the particle

	gl_TexCoord[0]=vec4(v0.w,r,gl_Vertex.x+gl_MultiTexCoord0.x*100,1);	
	gl_TexCoord[1]=vec4(v0.xy,v1.xy);
	
	gl_PointSize=ceil(max(abs(v1.x-v0.x),abs(v1.y-v0.y))+abs(r))+4; // width of the point. this is measured in pixels
	gl_Position=vec4((v0.xy+v1.xy)/vec2(1280,720),0,1);
	
	if(v0.z<0||v1.z<0||abs(v0.w)<2e-3)
		gl_PointSize=0;
}

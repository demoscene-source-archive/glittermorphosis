
#pragma warning( disable : 4730 )
#pragma warning( disable : 4799 )

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <mmsystem.h>
#include <mmreg.h>
#include "../config.h"
#include <GL/gl.h>
#include "../glext.h"
#include "../shader_code.h"
#include "../4klang.h"

// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
HWAVEOUT	hWaveOut;

#pragma data_seg(".wavefmt")
WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
    2, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
    sizeof(SAMPLE_TYPE)*2, // block alignment;
    sizeof(SAMPLE_TYPE)*8, // bits per sample
    0 // extension not needed
};

#pragma data_seg(".wavehdr")
WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};



static const PIXELFORMATDESCRIPTOR pfd = {
    sizeof(PIXELFORMATDESCRIPTOR), 1, PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER, PFD_TYPE_RGBA,
    32, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 32, 0, 0, PFD_MAIN_PLANE, 0, 0, 0, 0 };

static DEVMODE screenSettings = { {0},
    #if _MSC_VER < 1400
    0,0,148,0,0x001c0000,{0},0,0,0,0,0,0,0,0,0,{0},0,32,XRES,YRES,0,0,      // Visual C++ 6.0
    #else
    0,0,156,0,0x001c0000,{0},0,0,0,0,0,{0},0,32,XRES,YRES,{0}, 0,           // Visuatl Studio 2005
    #endif
    #if(WINVER >= 0x0400)
    0,0,0,0,0,0,
    #if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
    0,0
    #endif
    #endif
    };

#ifdef __cplusplus
extern "C" 
{
#endif
int  _fltused = 1;
#ifdef __cplusplus
}
#endif

//----------------------------------------------------------------------------

static const char *strs[] = {
	"glCreateShaderProgramv",
	"glGenProgramPipelines",
	"glUseProgramStages",
	"glBindProgramPipeline",
	"glTexStorage3D",
	"glCopyTexSubImage3D",
	"glUseProgram",
	"glGetUniformLocation",
	"glUniform1i",
	"glActiveTexture",
	"glGenerateMipmap",
    };

#define NUMFUNCIONES (sizeof(strs)/sizeof(strs[0]))

#define oglCreateShaderProgramv	      ((PFNGLCREATESHADERPROGRAMVPROC)myglfunc[0])
#define oglGenProgramPipelines        ((PFNGLGENPROGRAMPIPELINESPROC)myglfunc[1])
#define oglUseProgramStages						((PFNGLUSEPROGRAMSTAGESPROC)myglfunc[2])
#define oglBindProgramPipeline	      ((PFNGLBINDPROGRAMPIPELINEPROC)myglfunc[3])
#define oglTexStorage3D								((PFNGLTEXSTORAGE3DPROC)myglfunc[4])
#define oglCopyTexSubImage3D		      ((PFNGLCOPYTEXSUBIMAGE3DPROC)myglfunc[5])
#define oglUseProgram									((PFNGLUSEPROGRAMPROC)myglfunc[6])
#define oglGetUniformLocation					((PFNGLGETUNIFORMLOCATIONPROC)myglfunc[7])
#define oglUniform1i									((PFNGLUNIFORM1IPROC)myglfunc[8])
#define oglActiveTexture							((PFNGLACTIVETEXTUREPROC)myglfunc[9])
#define oglGenerateMipmap							((PFNGLGENERATEMIPMAPPROC)myglfunc[10])

#define USE_SOUND_THREAD

//#pragma code_seg(".initsnd")
void  InitSound()
{
#ifdef USE_SOUND_THREAD
	// thx to xTr1m/blu-flame for providing a smarter and smaller way to create the thread :)
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#else
	_4klang_render(lpSoundBuffer);
#endif

// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
//SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  

/*
	for(long i=0;i<MAX_SAMPLES;++i)
	{
		lpSoundBuffer[i*2+0]=(float(i%200)/100.f-1.f)*.125f;
		lpSoundBuffer[i*2+1]=0;
	}
*/


#if 0
#define BOOBS (SAMPLE_RATE * 40)
#define SAMPT float

for(int j=0;j<2;++j)
{
	//SAMPT buf1=0,buf2=0,buf3=0,buf4=0;
	for(long i=4;i<BOOBS;++i)
	{
		SAMPT c=SAMPT(i)/SAMPT(BOOBS);
#define res SAMPT(0.3)


	SAMPT resoclip = lpSoundBuffer[(i-4)*2+j];

   if(resoclip > SAMPT(1))
      resoclip = SAMPT(1);

	lpSoundBuffer[i*2+j] -= resoclip * res;

	for(int z=1;z<5;++z)
		lpSoundBuffer[(i-z)*2+j] += (lpSoundBuffer[(i-z+1)*2+j] - lpSoundBuffer[(i-z)*2+j]) * c;


/*
	SAMPT in = lpSoundBuffer[i*2+j];

   SAMPT resoclip = buf4;

   if(resoclip > 1.0)
      resoclip = 1.0;

   in -= resoclip * res;

   buf1 += (in - buf1) * c;
   buf2 += (buf1 - buf2) * c;
   buf3 += (buf2 - buf3) * c;
   buf4 += (buf3 - buf4) * c;


		lpSoundBuffer[i*2+j]=(float)buf4;
*/

	}

	//for(long i=0;i<MAX_SAMPLES;++i)
	//{
	//	lpSoundBuffer[i*2+j]=0;//(float)buf4;
	//}
}
#undef res
#undef SAMPT
#endif

	waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	
}

void entrypoint( void )
{
    // full screen
    //if( ChangeDisplaySettings(&screenSettings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL) return;
    ChangeDisplaySettings(&screenSettings,CDS_FULLSCREEN);
    ShowCursor( 0 );
    // create window
    HWND hWnd = CreateWindow( "edit",0,WS_POPUP|WS_VISIBLE,0,0,XRES,YRES,0,0,0,0);
//    if( !hWnd ) return;
    HDC hDC = GetDC(hWnd);
    // initalize opengl
    SetPixelFormat(hDC,ChoosePixelFormat(hDC,&pfd),&pfd);
    //if( !SetPixelFormat(hDC,ChoosePixelFormat(hDC,&pfd),&pfd) ) return;
    wglMakeCurrent(hDC,wglCreateContext(hDC));

	void *myglfunc[NUMFUNCIONES];

    for( int i=0; i<NUMFUNCIONES; i++ )
    {
        #ifdef WIN32
        myglfunc[i] = wglGetProcAddress( strs[i] );
        #endif
        #ifdef LINUX
        myglfunc[i] = glXGetProcAddress( (const unsigned char *)strs[i] );
        #endif
    }


	GLuint pipeline;

	oglGenProgramPipelines(1, &pipeline);
	oglBindProgramPipeline(pipeline);
	oglUseProgramStages(pipeline, GL_VERTEX_SHADER_BIT, oglCreateShaderProgramv(GL_VERTEX_SHADER, 1, &vertex));
	GLuint fragprog = oglCreateShaderProgramv(GL_FRAGMENT_SHADER, 1, &fragment);
	oglUseProgramStages(pipeline, GL_FRAGMENT_SHADER_BIT, fragprog);

	glBindTexture(GL_TEXTURE_3D, 1);
	oglTexStorage3D(GL_TEXTURE_3D, 1, GL_RG8, 128, 128, 256);

	oglUseProgram(fragprog);
	oglUniform1i(oglGetUniformLocation(fragprog,"A"),1);
	oglUniform1i(oglGetUniformLocation(fragprog,"B"),0);
  for(int i = 0; i < 256; ++i)
	{
		glTexCoord4s(i, 0, 0, 2);
		glRects(-1,-1,+1,+1);
		oglCopyTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, i, 0, 0, 128, 128);
	}

	glEnable(GL_PROGRAM_POINT_SIZE);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE);

		oglActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, 2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);


		glFinish();
	// Clinkster_GenerateMusic();

	InitSound();
	// Clinkster_StartMusic();



    do 
    {
//static int frame=0;
//const float time=Clinkster_GetPosition() / Clinkster_TicksPerSecond;
//const float time=float(frame++)/8.f;

		// get sample position for timing
		waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));

		long t = MMTime.u.sample;
		float time = float(t) / SAMPLE_RATE;

		oglUseProgram(0);

		glClear(GL_COLOR_BUFFER_BIT);

		glBegin(GL_POINTS);
		glTexCoord1f(time);
		for(short i=0;i<16384;++i)
			glVertex2s(i, i);
		glEnd();

		glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, XRES, YRES, 0);
		oglGenerateMipmap(GL_TEXTURE_2D);

		oglUseProgram(fragprog);
		glTexCoord4s(0, 0, 0, 3);
		glClear(GL_COLOR_BUFFER_BIT);
		glRects(-1,-1,+1,+1);

		glFinish();

//        SwapBuffers( hDC );
        wglSwapLayerBuffers( hDC, WGL_SWAP_MAIN_PLANE ); //SwapBuffers( hDC );

		PeekMessageA(0, 0, 0, 0, PM_REMOVE); // <-- "fake" message handling.

 //   }while ( !GetAsyncKeyState(VK_ESCAPE) );
    //}while ( !GetAsyncKeyState(VK_ESCAPE) && t<(MZK_DURATION*1000) );
	} while (MMTime.u.sample < MAX_SAMPLES && !GetAsyncKeyState(VK_ESCAPE));

    #ifdef CLEANDESTROY
    sndPlaySound(0,0);
    ChangeDisplaySettings( 0, 0 );
    ShowCursor(1);
    #endif

    ExitProcess(0);
}

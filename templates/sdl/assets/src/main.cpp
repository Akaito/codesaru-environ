// NOTE: Much of the SDL code here is taken from Lazy Foo's SDL tutorials at
// http://lazyfoo.net/tutorials/SDL/

#include <cstdlib>
#include <cstdio>
#include <ctime>

#ifdef WIN32
#	include <SDL.h>
#	undef main
#else
#	include <SDL2/SDL.h>
#endif

//=====================================================================
//
// Constants and helpers
//
//=====================================================================
//
//=====================================================================
static SDL_Window *   g_window       = nullptr;
static SDL_Renderer * g_renderer     = nullptr;

//=====================================================================
static bool init () {

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		std::fprintf(
			stderr,
			"SDL failed to initialize.  %s\n",
			SDL_GetError()
		);
		return false;
	}

	// Create main window.
	g_window = SDL_CreateWindow(
		"csaru-sdl-starter",
		SDL_WINDOWPOS_CENTERED,
		SDL_WINDOWPOS_CENTERED,
		800,
		600,
		SDL_WINDOW_SHOWN
	);
	if (!g_window) {
		std::fprintf(
			stderr,
			"SDL failed to create a window.  %s\n",
			SDL_GetError()
		);
		return false;
	}

	// Create renderer for main window.
	g_renderer = SDL_CreateRenderer(
		g_window,
		-1 /* rendering driver index; -1 means first available */,
		SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
	);
	if (!g_renderer) {
		std::fprintf(
			stderr,
			"SDL failed to create renderer.  %s\n",
			SDL_GetError()
		);
		return false;
	}

	// Set color used when clearing.
	SDL_SetRenderDrawColor(g_renderer, 0xFF, 0x00, 0xFF, 0xFF);

	return true;

}

//=====================================================================
static void close () {

	// Destroy window
	SDL_DestroyRenderer(g_renderer);
	g_renderer = nullptr;
	SDL_DestroyWindow(g_window);
	g_window = nullptr;

}


//=====================================================================
//
// main program
//
//=====================================================================

//=====================================================================
int main (int argc, const char * argv[]) {

	// initalize SDL
	if (!init())
		return 1;

	bool readyToQuit = false;
	SDL_Event e;

	while (!readyToQuit) {
		// handle input
		while (SDL_PollEvent(&e)) {
			switch (e.type) {
				case SDL_QUIT: {
					readyToQuit = true;
				} break;

				case SDL_KEYUP: {
					switch (e.key.keysym.sym) {
						case SDLK_ESCAPE: readyToQuit = true; break;
					}
				}
			}
		} // end while SDL_PollEvent

		// sdl render
		SDL_SetRenderDrawColor(g_renderer, 0xFF, 0x00, 0xFF, 0xFF);
		SDL_RenderClear(g_renderer);

		SDL_RenderPresent(g_renderer);
	}

	close();

	return 0;

}


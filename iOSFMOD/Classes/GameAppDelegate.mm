#import "GameAppDelegate.h"
#import "ES2RendererView.h"

#include <fmod.hpp>
#include <fmod_errors.h>

@implementation GameAppDelegate

// This app shows how to use Game in a more modern way.
// It eliminates the iOS 3.2 backwards compatibility code that
// had a workaround for DisplayLink not being present, and eliminates
// the ES1Renderer class entirely.
//
// 

// You need this synthesize call, to be able to call self.window in this class.
@synthesize window ;


bool FMOD_ErrorCheck( FMOD_RESULT result, int line, const char* file ) {
  if( result != FMOD_OK ) {
    printf( "FMOD error %s:%d -- (%d) %s", file, line, result, FMOD_ErrorString(result) );
  }

  return result == FMOD_OK;
}

#define FMOD_CHECK( result ) FMOD_ErrorCheck( result, __LINE__, __FILE__ )


FMOD::System* fmodSystem = 0;
// We replaced the initWithCoder method with this regular init one
// 2.
- (id) init {
  puts( "2. [GameAppDelegate init] (WITHOUT CODER)" ) ;
  FMOD_CHECK( FMOD::System_Create( &fmodSystem ) );
  FMOD_CHECK( fmodSystem->init( 64, FMOD_INIT_NORMAL, 0 ) );
  
  FMOD::Sound* sound = 0;
  NSString *filename = @"/brace for missile impact.mp3";
  
  NSString *path = [[NSBundle mainBundle] resourcePath];
  NSString *p = [path stringByAppendingString:filename];
  //[[NSBundle mainBundle] resourcePath], filename] UTF8String];
  FMOD_CHECK( fmodSystem->createSound( p.UTF8String, FMOD_CREATESAMPLE, 0, &sound ) );
  
  FMOD::Channel* channel = 0;
  FMOD_CHECK( fmodSystem->playSound( sound, 0, 0, &channel ) );
  
  
  self = [super init];
  if (!self)  return self;
  
  return self ;
}

// 3.
- (void) applicationDidFinishLaunching:(UIApplication *)application {
  puts( "3. [GameAppDelegate applicationDidFinishLaunching]" ) ;
  // Override point for customization after application launch.
  // Allocate the window, make it visible, hook up the root view controller as THIS.
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window makeKeyAndVisible];
  self.window.rootViewController = self ;
  
  [self startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application {
  puts( "[GameAppDelegate applicationWillResignActive]" ) ;
	[self stopAnimation];
}

// 12.
- (void) applicationDidBecomeActive:(UIApplication *)application {
  puts( "12. [GameAppDelegate applicationDidBecomeActive]" ) ;
	[self startAnimation];
}

- (void) applicationWillTerminate:(UIApplication *)application {
  puts( "APP WILL TERM" ) ;
	[self stopAnimation];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
  puts( "Received memory warning!" ) ; // this only happens ONCE .. like after that your
  // app just gets terminated (regardless of how you respond on this first warning.)
}

// 4.
- (void) loadView {
  puts( "4. [GameAppDelegate loadView]" ) ;
  // This is how you provide a programmatic view.
  // The VIEW IS the ES2Renderer.  This is better architecture imo.
  renderer = [[ES2RendererView alloc] init];
  self.view = renderer ;
  self.view.multipleTouchEnabled = true ; // Enable multitouch!  This is so important.
  self.view.contentScaleFactor = [[UIScreen mainScreen] scale] ;
    
  CAEAGLLayer *eaglLayer = (CAEAGLLayer *)renderer.layer;
  eaglLayer.opaque = TRUE;
  eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
  
  animating = 0 ;
  displayLink = nil ;
}

// 8.
- (void) startAnimation {
  puts( "8. [GameAppDelegate startAnimation]" ) ;
	if( !animating )
	{
    puts( "STARTING ANIMATION" ) ;
	  displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];

    // Force 60fps, interval=1 means 60 fps
    [displayLink setFrameInterval:1];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		animating = 1 ;
	} else puts ( "WAS ANIM, NOT RESTARTING" ) ;
}

- (void) stopAnimation {
  puts("[GameAppDelegate stopAnimation]");
	if( animating )
	{
    animating = 0 ;
    [displayLink invalidate];
    displayLink = nil;
	}
}

// 13.
- (void) drawView:(id)sender {
  //puts("13. [GameAppDelegate drawView]");
  [renderer render];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches objectEnumerator] nextObject] ;
  CGPoint pt = [touch locationInView:self.view] ;
  printf( "touchesBegan %lu (%.1f %.1f)\n", [touches count], pt.x, pt.y ) ;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches objectEnumerator] nextObject] ;
  CGPoint pt = [touch locationInView:self.view] ;
  printf( "touchesMoved %lu (%.1f %.1f)\n", [touches count], pt.x, pt.y ) ;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches objectEnumerator] nextObject] ;
  CGPoint pt = [touch locationInView:self.view] ;
  printf( "touchesEnded %lu (%.1f %.1f)\n", [touches count], pt.x, pt.y ) ;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches objectEnumerator] nextObject] ;
  CGPoint pt = [touch locationInView:self.view] ;
  printf( "touchesCancelled %lu (%.1f %.1f)\n", [touches count], pt.x, pt.y ) ;
}

@end

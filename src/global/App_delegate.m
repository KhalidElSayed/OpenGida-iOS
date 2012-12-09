//
// OpenGida v1.0 Cliente iOS
//
// Copyright 2011 eFaber, S.L.
// Copyrigth 2011 Secretaría General de Comunicación
//    Komunikaziorako Idazkaritza Nagusia
//    Gobierno Vasco – Eusko Jaurlaritza 
// Licencia con arreglo a la EUPL, Versión 1.1 o –en cuanto sean aprobadas 
// por la Comisión Europea– versiones posteriores de la EUPL (la Licencia);
// Solo podrá usarse esta obra si se respeta la Licencia. Puede obtenerse una 
// copia de la Licencia en: http://ec.europa.eu/idabc/eupl 
// Salvo cuando lo exija la legislación aplicable o se acuerde por escrito, 
// el programa distribuido con arreglo a la Licencia se distribuye TAL CUAL,
// SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ni expresas ni implícitas.
// Véase la Licencia en el idioma concreto que rige los permisos y limitaciones 
// que establece la Licencia
//
//  http://opengida.efaber.net, opengida@efaber.net

#import "App_delegate.h"

#import "categories/UINavigationBar+Bidrasil.h"
#import "global/BIGlobal.h"
#import "global/BITab_view_controller.h"

#import "ASIHTTPRequest.h"
#import "ELHASO.h"

#ifdef USE_DCINTROSPECT
#ifdef TARGET_IPHONE_SIMULATOR
#import "DCIntrospect.h"
#endif
#endif


/// The ASIHTTPRequest default is 10, sistem defaults are ususally 60
#define _DEFAULT_TIMEOUT				30


/// Stores the server url before going to the background for later checks.
static NSString *_gLast_server_url;
/// Stores the language code before going to the background for later checks.
static NSString *_gLast_langcode;


@implementation App_delegate

- (void)dealloc
{
	[window_ release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	DLOG(@"didFinishLaunchingWithOptions:%@", launchOptions);

	[UINavigationBar setup_swizzling];

	[BIGlobal set_ui_bundle:[BIGlobal get_effective_ui_langcode]];
	[ASIHTTPRequest setDefaultTimeOutSeconds:_DEFAULT_TIMEOUT];

	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window_.backgroundColor = [UIColor whiteColor];

	BITab_view_controller *c = [BITab_view_controller new];
	window_.rootViewController = c;
	[window_ makeKeyAndVisible];
	[c release];

#ifdef USE_DCINTROSPECT
#if TARGET_IPHONE_SIMULATOR
	[[DCIntrospect sharedIntrospector] start];
#endif
#endif

	return YES;
}

/** Application shutdown. Save cache and stuff...
 * Note that the method could be called even during initialisation,
 * so you can't make any guarantees about objects being available.
 **/
- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save the hierarchy of the index tab.
	BITab_view_controller *tab =
		(BITab_view_controller*)window_.rootViewController;
	LASSERT([tab isKindOfClass:[BITab_view_controller class]], @"Uh oh");
	[tab save_hierarchy];
}

/** We are going to be ignored for a while.
 * We only are interested to detect system settings changes in the background,
 * so save the current settings to memory to check them back.
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
	[_gLast_server_url release];
	[_gLast_langcode release];
	_gLast_server_url = [[BIGlobal get_server_url] retain];
	_gLast_langcode = [[BIGlobal get_effective_ui_langcode] retain];
}

/** The application is coming back from the background.
 * We need to make sure the user settings were not changed behind our back. If
 * needed, update the required views. Also detect changes to localization.
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[BIGlobal synchronize];
	RASSERT(_gLast_server_url.length > 0, @"Bad last server url?", return);
	RASSERT(_gLast_langcode.length > 0, @"Bad last langcode?", return);

	if (![_gLast_server_url isEqualToString:[BIGlobal get_server_url]]) {
		DLOG(@"Hey, the server changed in the background!");
		BITab_view_controller *tab =
			(BITab_view_controller*)window_.rootViewController;
		LASSERT([tab isKindOfClass:[BITab_view_controller class]], @"Uh oh");
		[tab server_changed];
	}

	if (![_gLast_langcode
			isEqualToString:[BIGlobal get_effective_ui_langcode]]) {
		DLOG(@"Effective language code changed, resetting user interface");
		dispatch_async_low(^{
				DLOG(@"Sending notification...");
				[[NSNotificationQueue defaultQueue]
					enqueueNotification:[NSNotification
						notificationWithName:BIUI_langcode_did_change
						object:nil]
					postingStyle:NSPostNow];
				DLOG(@"Sent");
			});
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

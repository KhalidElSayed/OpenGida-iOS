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

#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"


// Public globals.
NSBundle *gLang_bundle = nil;
BOOL gShow_dev_warnings = NO;
DECLARE_NOTIFICATION(BIData_langcode_did_change);
DECLARE_NOTIFICATION(BIUI_langcode_did_change);

// Private globals.
static NSString *_http_server;
static NSString *_http_username;
static NSString *_http_password;
static NSString *_data_langcode;


@implementation BIGlobal

/** Forces a synchronization of the NSUserDefaults and flushes cached variables.
 * Usually you want to call this when coming back from the background to check
 * that user settings are updated.
 */
+ (void)synchronize
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	[_http_server release];
	[_http_username release];
	[_http_password release];
	[_data_langcode release];
	_http_server = nil;
	_http_username = nil;
	_http_password = nil;
	_data_langcode = nil;
}

/** Returns the server URL from the settings bundle.
 * This caches the value internally to be faster on the next call.
 */
+ (NSString*)get_server_url
{
	if (_http_server)
		return _http_server;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	gShow_dev_warnings = [defaults boolForKey:DEFAULTS_SHOW_WARNINGS];
	_http_server = [[defaults stringForKey:DEFAULTS_HTTP_SERVER] retain];
	if (!_http_server)
		return _http_server = @"http://www2.irekia.euskadi.net/";

	return _http_server;
}

/** Returns the server http authentication user from the settings bundle.
 * This caches the value internally to be faster on the next call.
 */
+ (NSString*)get_http_user;
{
	if (_http_username)
		return _http_username;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_http_username = [[defaults stringForKey:DEFAULTS_HTTP_USER] retain];
	if (!_http_username)
		return _http_username = @"";

	return _http_username;
}

/** Returns the server http authentication password from the settings bundle.
 * This caches the value internally to be faster on the next call.
 */
+ (NSString*)get_http_pass;
{
	if (_http_password)
		return _http_password;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_http_password = [[defaults stringForKey:DEFAULTS_HTTP_PASS] retain];
	if (!_http_password)
		return _http_password = @"";

	return _http_password;
}

/** Returns the search preferences for the user.
 * \return YES if the user has previously activated geolocation search. By
 * default NO.
 */
+ (BOOL)get_location_search
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:DEFAULTS_LOCATION_SEARCH];
}

/** Sets the location preferences of the user.
 */
+ (void)set_location_search:(BOOL)doit
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:doit forKey:DEFAULTS_LOCATION_SEARCH];
}

/** Similar to get_data_langcode, but returns a human readable string.
 * The returned string is in the current user interface language.
 */
+ (NSString*)get_data_lang_string
{
	if ([@"eu" isEqualToString:[BIGlobal get_data_langcode]])
		return _(DATA_LANGCODE_EU);
	else
		return _(DATA_LANGCODE_ES);
}

/** Returns the data language from the settings bundle.
 * This caches the value internally to be faster on the next call. The data
 * language is used for the network queries against the server and can be
 * different from the ui language.
 */
+ (NSString*)get_data_langcode;
{
	if (_data_langcode)
		return _data_langcode;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_data_langcode = [[defaults stringForKey:DEFAULTS_DATA_LANGCODE] retain];
	if (!_data_langcode)
		return _data_langcode = @"es";

	return _data_langcode;
}

/** Sets the preferred data langcode.
 * This is called usually from the preference settings page, when the user
 * selects one of the available hardcoded languages. The function will update
 * the user settings and change the variable in memory for the next network
 * requests, then broadcast a notification.
 */
+ (void)set_data_langcode:(NSString*)langcode
{
	LASSERT(2 == langcode.length, @"Unexpected language code, use 2 letters");
	[langcode retain];
	[_data_langcode release];
	_data_langcode = langcode;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_data_langcode forKey:DEFAULTS_DATA_LANGCODE];

	dispatch_async_low(^{
			DLOG(@"Sending notification...");
			[[NSNotificationQueue defaultQueue]
				enqueueNotification:[NSNotification
					notificationWithName:BIData_langcode_did_change object:nil]
				postingStyle:NSPostNow];
			DLOG(@"Sent");
		});
}

/** Like get_ui_langcode but returns a human readable string for the code.
 * If the code is unknown, returns the automatic string.
 */
+ (NSString*)get_ui_lang_string
{
	NSString *langcode = [BIGlobal get_ui_langcode];
	if ([@"eu" isEqualToString:langcode])
		return @"Euskara";
	else if ([@"en" isEqualToString:langcode])
		return @"English";
	else if ([@"es" isEqualToString:langcode])
		return @"Español";
	else
		return _(UI_LANG_AUTOMATIC);
}

/** Returns the ui language from the settings bundle.
 * The result is not cached. The returned langcode may be the auto default
 * value, expect any kind of string.
 */
+ (NSString*)get_ui_langcode;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ret = [defaults stringForKey:DEFAULTS_UI_LANGCODE];
	return ret.length ? ret : @"auto";
}

/** Sets the preferred ui langcode.
 * This is called usually from the preference settings page, when the user
 * selects one of the available hardcoded languages. The function will update
 * the user settings and broadcast a notification.
 */
+ (void)set_ui_langcode:(NSString*)langcode
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:langcode forKey:DEFAULTS_UI_LANGCODE];
	langcode = [BIGlobal get_effective_ui_langcode];
	[BIGlobal set_ui_bundle:langcode];

	dispatch_async_low(^{
			DLOG(@"Sending notification...");
			[[NSNotificationQueue defaultQueue]
				enqueueNotification:[NSNotification
					notificationWithName:BIUI_langcode_did_change object:nil]
				postingStyle:NSPostNow];
			DLOG(@"Sent");
		});
}

/** Call this at the beginning of the application to set the ui language.
 * If you fail to call this, the global gLang_bundle won't be set and all the
 * calls to get language strings will fail.  If the langcode is not found,
 * Spanish is loaded as default language.
 */
+ (void)set_ui_bundle:(NSString*)code
{
	LASSERT(2 == code.length, @"Unexpected language code, use 2 letters");
	[gLang_bundle release];

	gLang_bundle = [[NSBundle bundleWithPath:[[NSBundle mainBundle]
		pathForResource:code ofType:@"lproj"]] retain];

	if (!gLang_bundle)
		gLang_bundle = [[NSBundle bundleWithPath:[[NSBundle mainBundle]
			pathForResource:@"es" ofType:@"lproj"]] retain];
	LASSERT(gLang_bundle, @"Couldn't load the language bundle!");
	DLOG(@"Loaded language bundle for %@", _(LANG));
}

/** Returns the currently effective selected user language.
 * This function only looks at the system preferences, the global
 * OS language, and returns the string it thinks should be used by
 * the code. This transforms the auto setting too. The final returned
 * string should be two characters long, or something like that.
 */
+ (NSString*)get_effective_ui_langcode
{
	// Read the user's language preferences.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *langcode = [defaults objectForKey:DEFAULTS_UI_LANGCODE];
	if (!langcode || [langcode isEqualToString:@"auto"]) {
		NSArray *langs = [defaults objectForKey:DEFAULTS_APPLE_LANGUAGES];
		langcode = [langs get:0];
	}

	// Just in case we get something weird.
	if ([langcode length] < 2) {
		DLOG(@"We got some weird code '%@', setting es", langcode);
		langcode = @"es";
	}
	return langcode;
}

/** Given an array of NSNumber pairs, saves it to the hierarchy slot.
 */
+ (void)save_hierarchy:(NSArray*)hierarchy
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:hierarchy forKey:DEFAULTS_HIERARCHY];
}

/** Returns the previously saved array through save_hierarchy.
 * Returns nil if it was empty or there was a problem.
 */
+ (NSArray*)load_hierarchy
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:DEFAULTS_HIERARCHY];
}

/** Returns the path for a file in the bundle using the current ui langcode.
 * This is very similar to get_path, but only searches the bundle and for the
 * specified langcode.
 * \return May return nil if something went wrong.
 */
+ (NSString*)get_path_lang:(NSString*)filename
{
	NSString *path = [[NSBundle mainBundle] pathForResource:filename
		ofType:nil inDirectory:@"."
		forLocalization:[BIGlobal get_data_langcode]];
	LASSERT(path, @"Coudln't find localized bundle path!");
	return path;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

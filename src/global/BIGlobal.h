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

#import <Foundation/Foundation.h>

/* Constants to access NSUserDefaults dictionary.
 * These should be the same as in the settings package.
 */
#define DEFAULTS_APPLE_LANGUAGES			@"AppleLanguages"
#define DEFAULTS_CACHE_SIZE					@"cache_size"
#define DEFAULTS_CACHE_SIZE_EXTERNAL		@"cache_size_external"
#define DEFAULTS_CACHE_SIZE_OUR				@"cache_size_our"
#define DEFAULTS_CLEAR_CACHE_ON_BOOT		@"clear_cache_on_boot"
#define DEFAULTS_DATA_LANGCODE				@"lang"
#define DEFAULTS_HIERARCHY					@"tab_hierarchy"
#define DEFAULTS_HTTP_PASS					@"http_password"
#define DEFAULTS_HTTP_SERVER				@"http_server"
#define DEFAULTS_HTTP_USER					@"http_username"
#define DEFAULTS_LOCATION_SEARCH			@"location_search"
#define DEFAULTS_UI_LANGCODE				@"ui_lang"
#define DEFAULTS_SHOW_WARNINGS				@"show_dev_warnings"
#define LAST_LANGCODE						@"last_lang"
#define LAST_TAB							@"last_tab"
#define LAST_VERSION						@"last_run_version"


/// Use this to query the current localized strings. Call set_ui_bundle: first.
extern NSBundle *gLang_bundle;

/// This global variable holds the state of development warnings.
extern BOOL gShow_dev_warnings;

/// And use this macro to save typing and get the selected bundle.
#define _(KEY)  [gLang_bundle localizedStringForKey:@"" # KEY \
	value:@"" # KEY table:nil]

/// This one is for formatter strings. Remember to use %1$@ for positions.
#define _F(KEY, ...)  [NSString stringWithFormat:[gLang_bundle \
	localizedStringForKey:@"" # KEY value:@"" # KEY table:nil], __VA_ARGS__]

// Shortcuts to avoid repeating too much boring code defining notifications.
#define EXTERNAL_NOTIFICATION(NAME)	extern NSString *const NAME

#define DECLARE_NOTIFICATION(NAME) NSString *const NAME = @"" # NAME

#define DEV_LOG(...) do { \
	NSString *__text = [NSString stringWithFormat:__VA_ARGS__]; \
	DLOG(@"%@", __text); \
	if (gShow_dev_warnings) { \
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dev warning" \
			message:__text delegate:nil cancelButtonTitle:@"Ouch" \
			otherButtonTitles:nil]; \
		run_on_ui(^{ [alert show]; }); \
		[alert release]; \
	} \
} while (0)


// Shortcut for most animations.
#define DEFAULT_ANIM_OPTIONS \
	options:UIViewAnimationOptionCurveEaseInOut | \
		UIViewAnimationOptionTransitionNone | \
		UIViewAnimationOptionAllowUserInteraction


#define MINIMUM_ROW_HEIGHT		38


@interface BIGlobal : NSObject
{
}

+ (void)synchronize;
+ (NSString*)get_server_url;
+ (NSString*)get_http_user;
+ (NSString*)get_http_pass;
+ (BOOL)get_location_search;
+ (void)set_location_search:(BOOL)doit;

+ (NSString*)get_data_langcode;
+ (NSString*)get_data_lang_string;
+ (void)set_data_langcode:(NSString*)langcode;

+ (NSString*)get_effective_ui_langcode;
+ (NSString*)get_ui_lang_string;
+ (NSString*)get_ui_langcode;
+ (void)set_ui_langcode:(NSString*)langcode;

+ (void)set_ui_bundle:(NSString*)code;

+ (void)save_hierarchy:(NSArray*)hierarchy;
+ (NSArray*)load_hierarchy;

+ (NSString*)get_path_lang:(NSString*)filename;

@end

EXTERNAL_NOTIFICATION(BIData_langcode_did_change);
EXTERNAL_NOTIFICATION(BIUI_langcode_did_change);

// vim:tabstop=4 shiftwidth=4 syntax=objc

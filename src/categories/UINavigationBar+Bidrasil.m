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

#import "categories/UINavigationBar+Bidrasil.h"

#import "categories/UIColor+Bidrasil.h"

#import "ELHASO.h"


#define _BAR_RECT			CGRectMake(0, 0, 320, 44)


/// Stores if we draw the Bidrasil title, not welcome on modal controllers.
static BOOL _gShow_bidrasil = YES;


/** \class UINavigationBar
 * Modifies the iOS default drawing behaviour.
 */
@implementation UINavigationBar (Bidrasil)

/// Returns the image that is used for the normal navigation bar.
+ (UIImage*)bar_background
{
	UIImage *cached_image = nil;
	if (cached_image)
		return cached_image;

	const CGRect full_rect = _BAR_RECT;
	UIGraphicsBeginImageContext(full_rect.size);

	UIImage *bar = [UIImage imageNamed:@"navigation_bar.png"];
	[bar drawInRect:full_rect];

	cached_image =
		[UIGraphicsGetImageFromCurrentImageContext() retain];
	LASSERT(cached_image, @"Couldn't scale image?");
	UIGraphicsEndImageContext();
	return cached_image;
}

/// Returns the image that is used for the navigation bar with logo.
+ (UIImage*)bar_background_with_logo
{
	UIImage *cached_image = nil;
	if (cached_image)
		return cached_image;

	UIImage *background = [UINavigationBar bar_background];

	CGRect rect = _BAR_RECT;
	UIGraphicsBeginImageContext(rect.size);
	[background drawInRect:rect];

	UIImage *logo = [UIImage imageNamed:@"navigation_bar_icon.png"];
	if (logo.size.height < 1 || logo.size.width < 1) {
		LASSERT(NO, @"No logo?");
	} else {
		rect.origin.x = floorf((rect.size.width - logo.size.width) / 2.0f);
		rect.origin.y = floorf((rect.size.height - logo.size.height) / 2.0f);
		rect.size = logo.size;
		[logo drawInRect:rect];
	}

	cached_image =
		[UIGraphicsGetImageFromCurrentImageContext() retain];
	LASSERT(cached_image, @"Couldn't draw image?");
	UIGraphicsEndImageContext();
	return cached_image;
}

/** Hack iOS navigation bar to use custom background everywhere.
 * Note that custom_draw_rect will actually be drawRect due to swizzling inside
 * the App_delegate, so calling custom_draw_rect is not a recursive call but
 * getting the standard OS behaviour.
 */
- (void)custom_draw_rect:(CGRect)rect
{
	if (!_gShow_bidrasil)
		[[UINavigationBar bar_background] drawInRect:rect];
	else
		[[UINavigationBar bar_background_with_logo] drawInRect:rect];
}

/** Enables or disables displaying the Bidrasil branding text.
 * For some modal view controllers you may prefer to remove the text since it
 * conflicts with other text put by the OS.
 */
+ (void)show_bidrasil:(BOOL)doit
{
	DLOG(@"UINavigationBar+Bidrasil: %@ logo", doit ? @"show" : @"hide");
	_gShow_bidrasil = doit;
}

/** Sets up UINavigation swizzling for iOS 4.x.
  * On iOS5 there is a new mechanism to change the navigation bar, but for
  * previous versions we still are required to swizzle the drawRect method.
  * Call this once during the startup to recover this behaviour for old iOS
  * versions.
  */
+ (void)setup_swizzling
{
	if (!NSClassFromString(@"UIAppearance")) {
		DLOG(@"Swizzling navigation bar for iOS 4.x");
		swizzle([UINavigationBar class],
			@selector(drawRect:), @selector(custom_draw_rect:));
	} else {
		DLOG(@"Running on iOS 5.x, using appearance proxy for navigation bar");
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

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

#import "global/BIMail_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "categories/UINavigationBar+Bidrasil.h"

#import "ELHASO.h"


@implementation BIMail_view_controller

/** Initialises the view, and also fixes the look.
 */
- (id)init
{
	if (!(self = [super init]))
		return nil;

	self.navigationBar.tintColor = [UIColor navigation_bar_green_2];

	if ([self.navigationBar respondsToSelector:@selector(
			setBackgroundImage:forBarMetrics:)]) {

		[self.navigationBar setBackgroundImage:[UINavigationBar bar_background]
			forBarMetrics:UIBarMetricsDefault];
	}

	return self;
}

/// Overrides the presentation to change the navigation bar for iOS 4.x.
- (void)presentModalViewController:(UIViewController*)controller
	animated:(BOOL)animated
{
	[UINavigationBar show_bidrasil:NO];
	[super presentModalViewController:controller animated:animated];
}

@end

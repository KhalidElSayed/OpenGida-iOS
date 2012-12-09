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

#import "global/BIContent_view_controller.h"

@class NSURL;

/** Shows an HTML to the user.
 *
 * Nothing fancy, the file comes from the bundle's resources.
 */
@interface BIHTML_view_controller : BIContent_view_controller
	<UIWebViewDelegate>
{
	/// Tracks our web view.
	UIWebView *web_view_;

	/// Put here the relative path to the file you want to show.
	NSString *filename_;

	/// Link to open externally, used by the alert delegate.
	NSURL *external_;
}

@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSURL *external;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

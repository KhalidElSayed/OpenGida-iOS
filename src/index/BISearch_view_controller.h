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

#import "index/BIIndex_view_controller.h"

@class CLLocation;

/** Similar to the index, this controller shows search results.
 *
 * Paging is supported when first_page is false. This class overrides the usage
 * of the navigation_ instance variable by filling it up with the strings
 * required for the names of the two (or more) available search groups.
 */
@interface BISearch_view_controller : BIIndex_view_controller
{
	/// Holds the initial words used to create the search.
	NSString *search_text_;

	/// Store here if this is the search index or there is paging.
	BOOL first_page_;

	/// Points to the search location if available.
	CLLocation *location_;
}

@property (nonatomic, retain) CLLocation *location;

- (void)set_search:(NSString*)text;

- (void)paginate_search:(API_TYPE)type total_count:(int)total_count
	initial_search:(BIAPI_entry*)initial_search;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

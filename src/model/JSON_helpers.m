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

#import "model/JSON_helpers.h"

#import <assert.h>

@protocol BIInitializer <NSObject>
- (id)init_with_data:(id)data;
@end

/** Simple wrapper around temporary creation of items.
 * Usually you parse JSON objects and create a temporary array with the ones
 * which were successfully converted. This function wraps the typical block of
 * code. You only need to pass the array of JSON items and the expected class
 * of the objects you want to create.
 *
 * \return Returns an array with valid objects. Returns nil instead of an empty
 * array.
 */
NSArray *parse_json_items(NSArray *items, Class type)
{
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:items.count];

	for (id item_data in items) {
		id<BIInitializer> item = [type alloc];
		assert([item respondsToSelector:@selector(init_with_data:)] &&
			"Programmer error, unexpected API was used");
		item = [item init_with_data:item_data];
		if (item) {
			[valid addObject:item];
			[item release];
		}
	}

	return valid.count ? valid : nil;
}

// vim:tabstop=4 shiftwidth=4 syntax=objc

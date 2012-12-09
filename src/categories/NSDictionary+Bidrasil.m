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

#import "categories/NSDictionary+Bidrasil.h"

#import "ELHASO.h"


/** \class NSDictionary
 * Extra methods to type less accessing dictionaries.
 */
@implementation NSDictionary (Bidrasil)

/** Converts a string in the dictionary into an API_TYPE.
 * Most of the time you should be passing API_ERROR as the default value to
 * verify if the parsing went ok. The default value is returned if the parsing
 * didn't match any of the known types.
 */
- (API_TYPE)get_type:(NSString*)key def:(API_TYPE)def
{
	NSString *value = [self get_string:key def:nil];
	if (value.length < 1)
		return def;

	if ([value isEqualToString:@"category"])
		return API_CATEGORY;
	else if ([value isEqualToString:@"person"])
		return API_PERSON;
	else if ([value isEqualToString:@"people"])
		return API_PERSON;
	else if ([value isEqualToString:@"entities"])
		return API_ENTITY;
	else if ([value isEqualToString:@"entity"])
		return API_ENTITY;
	else
		return def;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

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

#import "net/BIAPI_types.h"

#import <UIKit/UIKit.h>


/** Returns the type icon for the  item.
 * May return nil.
 */
UIImage *get_icon_for_api_type(API_TYPE type)
{
	switch (type) {
		case API_CATEGORY: return [UIImage imageNamed:@"type-category.png"];
		case API_ENTITY: return [UIImage imageNamed:@"type-entity.png"];
		case API_PERSON: return [UIImage imageNamed:@"type-person.png"];
		case API_ERROR: return [UIImage imageNamed:@"type-error.png"];
		case API_SEARCH_MORE_ENTITIES:
		case API_SEARCH_MORE_PEOPLE:
			return [UIImage imageNamed:@"type-more.png"];

		case API_SEARCH_ROOT:
		case API_SEARCH_PEOPLE:
		case API_SEARCH_ENTITIES:
		case API_UNKNOWN:
			return nil;
	}

	return nil;
}

// vim:tabstop=4 shiftwidth=4 syntax=objc

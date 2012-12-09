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

#import "model/BIJSON_Category.h"
#import "net/BIAPI_types.h"

/** JSON storage class.
 * This class is used to parse the result of search JSON queries, and is used
 * internally by the network API. Usually this is the intermediate structure
 * from which BISearch_item objects are spawned.
 */
@interface BIJSON_Search : BIJSON_Category
{
}

+ (id)parse_json:(NSDictionary*)json search_term:(NSString*)search_term;
+ (id)parse_json:(NSDictionary*)json type:(API_TYPE)type;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

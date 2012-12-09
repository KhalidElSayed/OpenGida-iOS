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

#import "ASIHTTPRequest.h"

@class JSONDecoder;
@class JSON_request;

/** Conform to this protocol to process the http data in the background.
 */
@protocol BIJSON_parser

/** Called in the background to let you do parsing and complex stuff.
 * You can retrieve the json from the property of the request, unless the error
 * parameter is not nil, in which case something bad happened and the json is
 * invalid.
 */
- (void)parse_in_background:(JSON_request*)request error:(NSError*)error;

@end


/** Simple wrapper around ASIHTTPRequest to run JSON parsing in background.
 */
@interface JSON_request : ASIHTTPRequest
{
	/// The parsed json dictionary.
	NSDictionary *json_;

	/// The processed items from the dictionary.
	NSArray *items_;
}

@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) NSArray *items;

+ (NSDictionary*)parse:(ASIHTTPRequest*)request;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

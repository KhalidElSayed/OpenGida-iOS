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

/** Models one category item received from the server.
 */
@interface BICategory_item : NSObject
{
	NSString *name_;
	API_TYPE type_;
	int id_;
	BOOL indent_;
}

/// Name of the category item.
@property (nonatomic, retain) NSString *name;
/// Type of information this item points to.
@property (nonatomic, assign) API_TYPE type;
/// Identifier of the information pointed by this item.
@property (nonatomic, assign) int id_;
/// Set to true if this item has to be indented visually to the user.
@property (nonatomic, assign) BOOL indent;

+ (BICategory_item*)generic_error;
+ (BICategory_item*)specific_error:(NSString*)message;
+ (BICategory_item*)more_search:(API_TYPE)type total:(int)total;

- (id)init_with_json:(NSDictionary*)data;
- (UIViewController*)get_controller;
- (UIImage*)get_icon;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

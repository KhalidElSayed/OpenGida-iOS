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

@class BIPagination;

/** JSON storage class.
 * This class is used to parse the result of category JSON queries, and is used
 * internally by the network API. Usually this is the intermediate structure
 * from which BICategory_item objects are spawned.
 */
@interface BIJSON_Category : NSObject
{
	/// Holds information about pagination in the returned JSON.
	BIPagination *pagination_;

	/// Holds the returned items in the JSON, may contain NSNull objects.
	NSMutableArray *items_;

	/// Holds the returned navigation section of the JSON, if available.
	NSArray *navigation_;

	/// For the APIs where single items are returned, this points to them.
	NSObject *single_item_;

	/// Holds the names of the quick index titles.
	NSArray *qi_titles_;

	/// Holds the indices for each index title.
	NSArray *qi_numbers_;
}

+ (id)parse_json:(NSDictionary*)json;
- (NSMutableArray*)prepare_for_first_use;

@property (nonatomic, retain) BIPagination *pagination;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSArray *navigation;
@property (nonatomic, retain) NSArray *qi_titles;
@property (nonatomic, retain) NSArray *qi_numbers;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

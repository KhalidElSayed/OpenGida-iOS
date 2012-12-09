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

/// Type of interactive rows for BIInteractive_row.
enum IR_TYPE_ENUM
{
	IR_UNKNOWN,		///< Bad value, to detect uninitialized stuff.
	IR_NAME,		///< Simple text, usually first row. Not interactive.
	IR_ADDRESS,		///< Text with address, may be interactive with location.
	IR_PHONE,		///< Phone number, always interactive.
	IR_FAX,			///< Fax number, never interactive. Alias for IR_NAME.
	IR_EMAIL,		///< Email address, always interactive.
	IR_WEB,			///< Web address, always interactive.
	IR_TWITTER,		///< Twitter handle, possibly interactive.
	IR_FACEBOOK,	///< Facebook url, interactive if valid URL.
	IR_LINKEDIN,	///< Linkedin url, interactive if valid URL.
	IR_LAST,		///< Never used, simple array end witness.
};

typedef enum IR_TYPE_ENUM IR_TYPE;

/** Very simple object containing interface info for a BIRelationship_item.
 * BIRelationship_item objects are simple UI facades which show a bunch of
 * rows, some interactive, some not. This object encapsulates the different row
 * types and their interactivity behaviour.
 */
@interface BIInteractive_row : NSObject
{
	IR_TYPE type_;
	NSString *data_;
	BOOL is_interactive_, is_private_;
	float latitude_, longitude_;
}

/// Type of the interactive row.
@property (nonatomic, assign) IR_TYPE type;
/// Contents of the row to show.
@property (nonatomic, retain) NSString *data;
/// Set to YES if the row can be interactive. Simple shortcut for complex logic.
@property (nonatomic, assign) BOOL is_interactive;
/// Set to YES if the row is interactive. Runtime attribute used by entity rows.
@property (nonatomic, assign) BOOL is_private;
/// Latitude of the item, if available, otherwise zero.
@property (nonatomic, assign) float latitude;
/// Longitude of the item, if available, otherwise zero.
@property (nonatomic, assign) float longitude;

- (id)init_with_data:(NSArray*)data;
- (NSString*)type_string;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

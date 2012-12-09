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

#import <AddressBook/AddressBook.h>

/** Models a source for the address book.
 * Provides additional default names for nameless address book sources.
 */
@interface BIAddressbook_source : NSObject
{
	ABRecordRef ref_;
	BOOL is_default_;
	ABRecordID record_id_;
	ABSourceType source_type_;
	NSString *name_;
}

/// YES if this source is the default.
@property (nonatomic, assign) BOOL is_default;

/// The record identifier of the source in the addressbook.
@property (nonatomic, assign) ABRecordID record_id;

/// The native source type of the source.
@property (nonatomic, assign) ABSourceType source_type;

/// Human readable name of the source, or nil if it doesn't even have a type.
@property (nonatomic, retain) NSString *name;


+ (BIAddressbook_source*)get:(ABRecordRef)ref;
+ (NSArray*)get_sources;
- (ABRecordRef)ref;
- (void)setRef:(ABRecordRef)ref;
- (NSString*)type_name;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

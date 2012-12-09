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

@class BIAddressbook_source;
@class BIContact_info;


/** Models one entity or person item received from the server.
 */
@interface BIEntity_item : NSObject
{
	API_TYPE type_;
	int id__;
	BOOL is_complete_;

	// Attributes for complete queries.
	NSString *share_url_;
	NSString *first_name_, *last_name_;
	NSString *image_;
	unsigned int update_date_;
	NSString *address_road_, *address_postal_, *address_city_, *address_state_;
	float latitude_, longitude_;
	BIContact_info *public_contact, *private_contact;
	NSArray *people_;
	NSArray *relationships_;
	NSArray *works_for_, *job_titles_;
}

/// Type of information this item points to, either API_ENTITY or API_PERSON.
@property (nonatomic, assign) API_TYPE type;
/// The type is known only if the query is complete. Update queries only
/// contain relationships.
@property (nonatomic, readonly, assign) BOOL is_complete;

/// The following attributes are available only for complete queries.

/// Identifier of the information pointed by this item.
@property (nonatomic, readonly, assign) int id_;
/// Sharing URL of the element.
@property (nonatomic, retain) NSString *share_url;
/// First name of the person. Or full name of the entity.
@property (nonatomic, retain) NSString *first_name;
/// Last name of the person, nil for entities.
@property (nonatomic, retain) NSString *last_name;
/// URL of the image, if available.
@property (nonatomic, retain) NSString *image;
/// Last content update for this entry. Zero if not available.
@property (nonatomic, assign) unsigned int update_date;
/// Road address.
@property (nonatomic, retain) NSString *address_road;
/// Postal code.
@property (nonatomic, retain) NSString *address_postal;
/// City of the thing.
@property (nonatomic, retain) NSString *address_city;
/// Guess, what, a state!
@property (nonatomic, retain) NSString *address_state;
/// If not zero, contains the latitude of the object.
@property (nonatomic, assign) float latitude;
/// If not zero, contains the longitude of the object.
@property (nonatomic, assign) float longitude;
/// If present, contains all the public contact information.
@property (nonatomic, retain) BIContact_info *public_contact;
/// If present, contains all the private contact information.
@property (nonatomic, retain) BIContact_info *private_contact;
/// If present, contains an array of BIRelated_person objects.
@property (nonatomic, retain) NSArray *people;
/// If present, contains an array of BIRelationship objects.
@property (nonatomic, retain) NSArray *relationships;
/// If present, contains an array of (NSString*) entities this person works
/// for. The number of items in this array matches those in array job_titles.
@property (nonatomic, retain) NSArray *works_for;
/// If present, contains an array of (NSString*) job titles this person has.
/// The number of items in this array matches those in array works_for.
@property (nonatomic, retain) NSArray *job_titles;

- (id)init_with_json:(NSDictionary*)data id_:(int)id_;
- (NSString*)full_address;
- (NSString*)full_name;
- (BOOL)save_record:(BIAddressbook_source*)source;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

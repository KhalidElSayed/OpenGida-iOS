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

#import "model/BIContact_info.h"

#import "model/BIInteractive_row.h"

#import "ELHASO.h"
#import "NSDictionary+ELHASO.h"

@interface BIContact_info ()
@end

@implementation BIContact_info

@synthesize emails = emails_;
@synthesize webs = webs_;
@synthesize phones = phones_;
@synthesize faxes = faxes_;
@synthesize twitters = twitters_;
@synthesize facebooks = facebooks_;
@synthesize linkedins = linkedins_;

/** Initializes a contact information object.
 * There's no special requirement of entity objects to have attributes, so
 * construction always works. As a special case, if none of the attributes
 * contain data, nil will be returned and the object released.
 */
- (id)init_with_json:(NSDictionary*)data
{
	if (!(self = [super init]))
		return nil;

	self.emails = [data get_array:@"email" of:[NSString class] def:nil];
	self.webs = [data get_array:@"web" of:[NSString class] def:nil];
	self.phones = [data get_array:@"phone" of:[NSString class] def:nil];
	self.faxes = [data get_array:@"fax" of:[NSString class] def:nil];
	self.twitters = [data get_array:@"twitter" of:[NSString class] def:nil];
	self.facebooks = [data get_array:@"facebook" of:[NSString class] def:nil];
	self.linkedins = [data get_array:@"linkedin" of:[NSString class] def:nil];

	if (!emails_ && !webs_ && !phones_ && !faxes_ && !twitters_ &&
			!facebooks_ && !linkedins_) {
		[self release];
		return nil;
	} else {
		return self;
	}
}

- (void)dealloc
{
	[linkedins_ release];
	[facebooks_ release];
	[emails_ release];
	[webs_ release];
	[phones_ release];
	[faxes_ release];
	[twitters_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:5];
#define _ADD(VARNAME) do { \
	if (nil != (VARNAME ## _)) \
		[values addObject:[NSString stringWithFormat:@"" # VARNAME ":%@", \
			VARNAME ## _]]; \
} while (0)

	_ADD(emails);
	_ADD(webs);
	_ADD(phones);
	_ADD(faxes);
	_ADD(twitters);
	_ADD(facebooks);
	_ADD(linkedins);

	return [NSString stringWithFormat:@"BIContact_info {%@}",
		[values componentsJoinedByString:@", "]];
}

/** Convenience helper method of BIEntity_view_controller.
 * This method creates and returns an array with BIInteractive_row objects
 * created for all the valid contact types of this BIContact_info object. All
 * the returned objects are marked as public.
 */
- (NSArray*)interactive_rows
{
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:10];

	void (^add_row)(NSString*,IR_TYPE,BOOL) =
		^(NSString* data, IR_TYPE type, BOOL is_interactive){
			BIInteractive_row *row = [[BIInteractive_row alloc] init];
			row.type = type;
			row.is_interactive = is_interactive;
			row.data = data;
			[valid addObject:row];
			[row release];
		};

	for (NSString *phone in self.phones)
		add_row(phone, IR_PHONE, YES);

	for (NSString *fax in self.faxes)
		add_row(fax, IR_FAX, NO);

	for (NSString *email in self.emails)
		add_row(email, IR_EMAIL, YES);

	for (NSString *web in self.webs)
		add_row(web, IR_WEB, YES);

	for (NSString *twitter in self.twitters)
		add_row(twitter, IR_TWITTER, YES);

	for (NSString *facebook in self.facebooks)
		add_row(facebook, IR_FACEBOOK, YES);

	for (NSString *linkedin in self.linkedins)
		add_row(linkedin, IR_LINKEDIN, YES);

	return valid;
}

/** Similar to interactive_rows but only for rows which allow facetime.
 * This means emails and phone numbers.
 */
- (NSArray*)facetime_rows
{
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:10];

	void (^add_row)(NSString*,IR_TYPE,BOOL) =
		^(NSString* data, IR_TYPE type, BOOL is_interactive){
			BIInteractive_row *row = [[BIInteractive_row alloc] init];
			row.type = type;
			row.is_interactive = is_interactive;
			row.data = data;
			[valid addObject:row];
			[row release];
		};

	for (NSString *phone in self.phones)
		add_row(phone, IR_PHONE, YES);

	for (NSString *email in self.emails)
		add_row(email, IR_EMAIL, YES);

	return valid;
}

/** Similar to interactive_rows but only for phone numbers.
 */
- (NSArray*)sms_rows
{
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:10];

	for (NSString *phone in self.phones) {
		BIInteractive_row *row = [[BIInteractive_row alloc] init];
		row.type = IR_PHONE;
		row.is_interactive = YES;
		row.data = phone;
		[valid addObject:row];
		[row release];
	}

	return valid;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

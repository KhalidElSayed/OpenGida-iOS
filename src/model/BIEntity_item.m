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

#import "model/BIEntity_item.h"

#import "global/BIGlobal.h"
#import "model/BIAddressbook_source.h"
#import "model/BIContact_info.h"
#import "model/BIRelated_person.h"
#import "model/BIRelationship.h"
#import "model/JSON_helpers.h"
#import "model/JSON_helpers.h"

#import "ABContactsHelper.h"
#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSDictionary+ELHASO.h"

#import <AddressBook/AddressBook.h>


@interface BIEntity_item ()
- (void)parse_works_for:(NSArray*)elements;
- (void)parse_address:(NSArray*)elements;
- (NSArray*)contacts_in_source:(BIAddressbook_source*)source;
- (ABContact*)find_contact_in_source:(BIAddressbook_source*)source;
- (ABContact*)create_contact_in_source:(BIAddressbook_source*)source;
- (NSArray*)groups_in_source:(BIAddressbook_source*)source;

- (ABGroup*)find_group:(NSString*)group_name
	in_source:(BIAddressbook_source*)source;

- (ABGroup*)create_group_in_source:(BIAddressbook_source*)source;
@end

@implementation BIEntity_item

@synthesize type = type_;
@synthesize id_ = id__;
@synthesize is_complete = is_complete_;
@synthesize share_url = share_url_;
@synthesize first_name = first_name_;
@synthesize last_name = last_name_;
@synthesize image = image_;
@synthesize update_date = update_date_;
@synthesize address_road = address_road_;
@synthesize address_postal = address_postal_;
@synthesize address_city = address_city_;
@synthesize address_state = address_state_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;
@synthesize public_contact = public_contact_;
@synthesize private_contact = private_contact_;
@synthesize people = people_;
@synthesize relationships = relationships_;
@synthesize works_for = works_for_;
@synthesize job_titles = job_titles_;

#pragma mark -
#pragma mark Methods

/** Initializes an entity element.
 * There's no special requirement of entity objects to have attributes, so
 * construction mostly always works, only fails for low memory.
 */
- (id)init_with_json:(NSDictionary*)data id_:(int)id_;
{
	if (!(self = [super init]))
		return nil;

	id__ = id_;
	NSDictionary *person_data = [data get_dict:@"person" def:nil];
	NSDictionary *entity_data = [data get_dict:@"entity" def:nil];
	NSDictionary *attributes = person_data ? person_data : entity_data;

	if (person_data)
		type_ = API_PERSON;
	else if (entity_data)
		type_ = API_ENTITY;
	else
		type_ = API_UNKNOWN;

	is_complete_ = nil != attributes;
	self.share_url = [attributes get_string:@"share_url" def:nil];
	self.first_name = [attributes get_string:@"first_name" def:nil];
	self.last_name = [attributes get_string:@"last_name" def:nil];
	self.image = [attributes get_string:@"image" def:nil];
	self.update_date = [attributes get_uint:@"update_date" def:0];
	[self parse_works_for:[attributes get_array:@"works_for"
		of:[NSArray class] def:nil]];
	[self parse_address:[attributes get_array:@"address" def:nil]];
	public_contact_ = [[BIContact_info alloc] init_with_json:attributes];
	attributes = [data get_dict:@"private_info" def:nil];
	if (attributes)
		private_contact_ = [[BIContact_info alloc] init_with_json:attributes];

	self.people = parse_json_items(
		[data get_array:@"people" of:[NSArray class] def:nil],
		[BIRelated_person class]);

	self.relationships = parse_json_items(
		[data get_array:@"relationships" of:[NSDictionary class] def:nil],
		[BIRelationship class]);

	return self;
}

- (void)dealloc
{
	[works_for_ release];
	[job_titles_ release];
	[share_url_ release];
	[first_name_ release];
	[last_name_ release];
	[image_ release];
	[address_road_ release];
	[address_postal_ release];
	[address_city_ release];
	[address_state_ release];
	[public_contact_ release];
	[private_contact_ release];
	[people_ release];
	[relationships_ release];
	[super dealloc];
}

/** Helper of init_with_json to parse the works_for array attribute.
 * Doesn't return anything, modifies the works_for and job_titles properties in
 * place.
 */
- (void)parse_works_for:(NSArray*)elements
{
	self.works_for = nil;
	self.job_titles = nil;
	if (!elements)
		return;

	NSMutableArray *jobs = [NSMutableArray arrayWithCapacity:elements.count];
	NSMutableArray *firms = [NSMutableArray arrayWithCapacity:elements.count];
	const Class expected = [NSString class];

	for (NSArray *pair in elements) {
		LASSERT([pair isKindOfClass:[NSArray class]], @"Bad types");
		if (2 != pair.count) {
			DLOG(@"Ignoring works_for suspect pair %@", pair);
			continue;
		}
		NSString *job = [pair get:0];
		NSString *firm = [pair get:1];
		if ([job isKindOfClass:expected] && [firm isKindOfClass:expected]) {
			[jobs addObject:job];
			[firms addObject:firm];
		} else {
			DLOG(@"Rejecting job %@ firm %@, bad object types", jobs, firms);
		}
	}

	LASSERT(jobs.count == firms.count, @"Internal logic error, bad pairs");
	if (jobs.count) {
		self.job_titles = jobs;
		self.works_for = firms;
	}
}

/** Helper of init_with_json to parse the address array attribute.
 * Doesn't return anything, modifies the address property in place.
 */
- (void)parse_address:(NSArray*)elements
{
	/// Addresses are tricky, the array contains different kinds of objects.
	int f = 0;
	for (id thing in elements) {
		NSString *text = [thing isKindOfClass:[NSString class]] ? thing : nil;
		NSNumber *num = [thing isKindOfClass:[NSNumber class]] ? thing : nil;
		const BOOL string_pos = f < 4;
		const BOOL number_pos = (4 == f || 5 == f);
		if ((string_pos && text.length) || number_pos) {
			switch (f) {
				case 0: self.address_road = text; break;
				case 1: self.address_postal = text; break;
				case 2: self.address_city = text; break;
				case 3: self.address_state = text; break;
				case 4: latitude_ = [num floatValue]; break;
				case 5: longitude_ = [num floatValue]; break;
				default:
					DLOG(@"Parsing address, going out of valid range!");
					break;
			}
		}
		f++;
	}
}

/** Debugging helper.
 */
- (NSString*)description
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:20];
#define _ADD(VARNAME) do { \
	if (nil != (VARNAME ## _)) \
		[values addObject:[NSString stringWithFormat:@"" # VARNAME ":%@", \
			VARNAME ## _]]; \
} while (0)

	_ADD(first_name);
	_ADD(last_name);
	_ADD(share_url);
	_ADD(image);
	_ADD(address_road);
	_ADD(address_postal);
	_ADD(address_city);
	_ADD(address_state);
	if (latitude_ || longitude_)
		[values addObject:[NSString stringWithFormat:@"lat:%f lon:%f",
			latitude_, longitude_]];
	_ADD(public_contact);
	_ADD(private_contact);
	_ADD(people);
	_ADD(relationships);
	_ADD(works_for);
	_ADD(job_titles);

	return [NSString stringWithFormat:@"BIEntity_item {id:%d, type:%d, "
		"complete:%d, %@, update_date:%u}", id__, is_complete_, type_,
		[values componentsJoinedByString:@", "], update_date_];
}

/** Returns the full address of the item, joined by \n separators.
 * If there are no address components, the empty string is returned.
 */
- (NSString*)full_address
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:4];
	if (self.address_road.length) [values addObject:self.address_road];
	if (self.address_postal.length) [values addObject:self.address_postal];
	if (self.address_city.length) [values addObject:self.address_city];
	if (self.address_state.length) [values addObject:self.address_state];
	return [values componentsJoinedByString:@", "];
}

/** Returns a composition of first_name and last_name.
 */
- (NSString*)full_name
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:2];
	if (self.first_name.length) [values addObject:self.first_name];
	if (self.last_name.length) [values addObject:self.last_name];
	return [values componentsJoinedByString:@" "];
}

/** Tries to save a record in a source.
 * This may take some time, you might want to run it in the background.
 *
 * \return Returns YES if the record was saved successfully. Note that
 * returning YES could mean a partial save: the addressbook might reject
 * creating groups in certain sources or adding a person to a specific group.
 * Since the API provided doesn't allow us to know the true reason, once the
 * record is saved to the addressbook, further manipulations are returned as
 * YES even though they might have failed.
 */
- (BOOL)save_record:(BIAddressbook_source*)source
{
	NSError *error = nil;
	// Find the contact, or add it?
	ABContact *contact = [self find_contact_in_source:source];
	if (!contact) {
		DLOG(@"Creating contact...");
		contact = [self create_contact_in_source:source];
		contact.firstname = self.first_name;
		contact.lastname = self.last_name;
	} else {
		DLOG(@"Got contact");
	}

	// Set the organization/person type and some "parent" info.
	contact.kind = (NSNumber*)((API_ENTITY == self.type) ?
		kABPersonKindOrganization : kABPersonKindPerson);
	contact.organization = [self.works_for get:0];
	contact.jobtitle = [self.job_titles get:0];

	// Fill in addresses. We only have one though.
	contact.addressDictionaries = [NSArray arrayWithObject:[ABContact
		dictionaryWithValue:[ABContact addressWithStreet:self.address_road
		withCity:self.address_city withState:self.address_state
		withZip:self.address_postal withCountry:_(COUNTRY_SPAIN) withCode:@"es"]
		andLabel:kABWorkLabel]];

	NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:5];
	// Fill in emails for the contact.
	for (NSString *address in self.public_contact.emails)
		[contacts addObject:[ABContact dictionaryWithValue:address
			andLabel:kABPersonPhoneMainLabel]];
	for (NSString *address in self.private_contact.emails)
		[contacts addObject:[ABContact dictionaryWithValue:address
			andLabel:kABPersonPhoneMainLabel]];
	contact.emailDictionaries = contacts;

	// Repeat for URLs
	[contacts removeAllObjects];
	for (NSString *address in self.public_contact.webs)
		[contacts addObject:[ABContact dictionaryWithValue:address
			andLabel:kABPersonHomePageLabel]];
	for (NSString *address in self.private_contact.webs)
		[contacts addObject:[ABContact dictionaryWithValue:address
			andLabel:kABPersonHomePageLabel]];
	contact.urlDictionaries = contacts;

	// The phones and faxes go together.
	[contacts removeAllObjects];
	for (NSString *text in self.public_contact.phones)
		[contacts addObject:[ABContact dictionaryWithValue:text
			andLabel:kABPersonPhoneMainLabel]];
	for (NSString *text in self.public_contact.faxes)
		[contacts addObject:[ABContact dictionaryWithValue:text
			andLabel:kABPersonPhoneWorkFAXLabel]];
	for (NSString *text in self.private_contact.phones)
		[contacts addObject:[ABContact dictionaryWithValue:text
			andLabel:kABPersonPhoneMainLabel]];
	for (NSString *text in self.private_contact.faxes)
		[contacts addObject:[ABContact dictionaryWithValue:text
			andLabel:kABPersonPhoneWorkFAXLabel]];
	contact.phoneDictionaries = contacts;

	// Try to add the twitter as a note.
	[contacts removeAllObjects];
	for (NSString *text in self.public_contact.twitters)
		[contacts addObject:text];
	for (NSString *text in self.private_contact.twitters)
		[contacts addObject:text];

	contact.note = contacts.count < 1 ? nil : _F(CONTACT_NOTE_TWITTER,
		[contacts componentsJoinedByString:@", "]);

	//[contact removeSelfFromAddressBook:&error];
	if (![ABContactsHelper addContact:contact withError:&error]) {
		DLOG(@"Couldn't add contact: %@", error);
		return NO;
	}

	// Find the group or add it?
	NSString *group_name = _(CONTACT_GROUP_NAME);
	ABGroup *group = [self find_group:group_name in_source:source];
	if (!group) {
		DLOG(@"Creating group...");
		group = [self create_group_in_source:source];
		group.name = group_name;
		if (![ABContactsHelper addGroup:group withError:&error]) {
			DLOG(@"Couldn't add group: %@", error);
			return YES;
		}
	}
	DLOG(@"Got group");

	// I wasn't able to get the ABGroup object to add a member, so we use our
	// own custom code to save.
	DLOG(@"Preparing to save person to group, cross your... streams");
	CFErrorRef err = nil;
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef g = ABAddressBookGetGroupWithRecordID(ab, group.recordID);
	ABRecordRef p = ABAddressBookGetPersonWithRecordID(ab,
		contact.recordID);
	DLOG(@"Got ab %@ group %@ person %@", ab, g, p);
	const bool ret1 = ABGroupAddMember(g, p, &err);
	DLOG(@"GroupAddMember ... %d - %@", ret1, err);
	const bool ret2 = ABAddressBookSave(ab, &err);
	DLOG(@"Saving addressbook anyway... %d - %@", ret2, err);
	CFRelease(ab);

	DLOG(@"Successful? %d", ret1 && ret2);
	return YES;
}

#pragma mark -
#pragma mark Addressbook extension methods

/// Replacement for ABContactsHelper::contacts to force a specific source.
- (NSArray*)contacts_in_source:(BIAddressbook_source*)source
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeopleInSource(
		addressBook, source.ref);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
	for (id person in thePeople)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
	[thePeople release];
	CFRelease(addressBook);
	return array;
}

/** Searches the contact in the source.
 * The search is performed using first and last name string comparison. Returns
 * the ABContact if found, nil otherwise.
 */
- (ABContact*)find_contact_in_source:(BIAddressbook_source*)source
{
	NSPredicate *pred;
	NSArray *contacts = [self contacts_in_source:source];
	NSString *fname = self.first_name;
	NSString *lname = self.last_name;
	if (fname.length > 0) {
		pred = [NSPredicate predicateWithFormat:@"firstname like %@", fname];
		contacts = [contacts filteredArrayUsingPredicate:pred];
	}
	if (lname.length > 0) {
		pred = [NSPredicate predicateWithFormat:@"lastname like %@", lname];
		contacts = [contacts filteredArrayUsingPredicate:pred];
	}
	return [contacts get:0];
}

/// Replaces ABContact::contact to force a specific source.
- (ABContact*)create_contact_in_source:(BIAddressbook_source*)source
{
	ABRecordRef person = ABPersonCreateInSource(source.ref);
	id contact = [ABContact contactWithRecord:person];
	CFRelease(person);
	return contact;
}

/// Replaces ABContactsHelper::groups to force a specific source.
- (NSArray*)groups_in_source:(BIAddressbook_source*)source
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *groups = (NSArray *)ABAddressBookCopyArrayOfAllGroupsInSource(
		addressBook, source.ref);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:groups.count];
	for (id group in groups)
		[array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
	[groups release];
	CFRelease(addressBook);
	return array;
}

/// Replaces ABContactsHelper::groupsMatchingName to force a specify a source.
- (ABGroup*)find_group:(NSString*)group_name
	in_source:(BIAddressbook_source*)source
{
	return [[ABContactsHelper groupsMatchingName:group_name] get:0];
	NSPredicate *pred = [NSPredicate
		predicateWithFormat:@"name contains[cd] %@ ", group_name];
	NSArray *groups = [ABContactsHelper groups];
	return [[groups filteredArrayUsingPredicate:pred] get:0];
}

/// Replaces ABGroup::group to force a specific source.
- (ABGroup*)create_group_in_source:(BIAddressbook_source*)source
{
	ABRecordRef grouprec = ABGroupCreateInSource(source.ref);
	id group = [ABGroup groupWithRecord:grouprec];
	CFRelease(grouprec);
	return group;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

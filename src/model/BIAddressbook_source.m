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

#import "model/BIAddressbook_source.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSMutableArray+ELHASO.h"

@implementation BIAddressbook_source

@synthesize is_default = is_default_;
@synthesize record_id = record_id_;
@synthesize source_type = source_type_;
@synthesize name = name_;

/** Returns an BIAddressbook_source for the source.
 * Will return nil if the reference is invalid.
 */
+ (BIAddressbook_source*)get:(ABRecordRef)ref
{
	if (!ref)
		return nil;
	BIAddressbook_source *ret = [BIAddressbook_source new];
	ret.ref = ref;
	return [ret autorelease];
}

- (void)dealloc
{
	[name_ release];
	if (ref_)
		CFRelease(ref_);
	[super dealloc];
}

/// Debugging helper.
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIAddressbook_source {name:%@, "
		@"default:%d, id:%d, type:%d(%@)}", name_, is_default_,
		record_id_, source_type_, [self type_name]];
}

/// Simple getter for the ABRecordRef value.
- (ABRecordRef)ref
{
	return ref_;
}

/** Setter of the ABRecordRef, retaining the new value.
 * By setting the record, all the other properties are automatically updated.
 */
- (void)setRef:(ABRecordRef)ref
{
	CFRetain(ref);
	if (ref_)
		CFRelease(ref_);
	ref_ = ref;

	self.record_id = ABRecordGetRecordID(ref);
	CFNumberRef sourceType = (CFNumberRef)ABRecordCopyValue(ref,
		kABSourceTypeProperty);
	CFStringRef sourceName = (CFStringRef)ABRecordCopyValue(ref,
		kABSourceNameProperty);

	self.source_type = sourceType ? [(NSNumber*)sourceType intValue] : -1;
	if (sourceName && CFStringGetLength(sourceName))
		self.name = (NSString*)sourceName;
	else
		self.name = self.type_name;

	if (sourceType)
		CFRelease(sourceType);
	if (sourceName)
		CFRelease(sourceName);
}

/** Returns a translated string for the type of source.
 * If the source type is not known, nil is returned instead.
 */
- (NSString*)type_name
{
	switch (self.source_type) {
		case kABSourceTypeLocal: return _(ABS_LOCAL);
		case kABSourceTypeExchange: return _(ABS_EXCHANGE);
		case kABSourceTypeExchangeGAL: return _(ABS_EXCHANGE_GAL);
		case kABSourceTypeMobileMe: return _(ABS_MOBILEME);
		case kABSourceTypeLDAP: return _(ABS_LDAP);
		case kABSourceTypeCardDAV: return _(ABS_CARDDAV);
		case kABSourceTypeCardDAVSearch: return _(ABS_CARDDAVSEARCH);
		default: return nil;
	}
}

/** Returns an array of BIAddressbook_source objects.
 * The first object will always be the default saving source. In very weird
 * cases this might return zero entries.
 */
+ (NSArray*)get_sources
{
	NSMutableArray *valid_sources = [NSMutableArray arrayWithCapacity:10];
	ABAddressBookRef addressBook = ABAddressBookCreate();

	// Get the default source.
	ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
	[valid_sources append:[BIAddressbook_source get:source]];
	if (source)
		CFRelease(source);

	BIAddressbook_source *default_source = [valid_sources get:0];
	// Now that we have the default source, go through the rest (if any).

	CFArrayRef sources = ABAddressBookCopyArrayOfAllSources(addressBook);
	for (CFIndex i = 0; i < CFArrayGetCount(sources); i++) {
		BIAddressbook_source *new_source = [BIAddressbook_source get:
			(ABRecordRef)CFArrayGetValueAtIndex(sources, i)];
		if (!new_source)
			continue;
		if (default_source && new_source.record_id == default_source.record_id)
			continue;
		[valid_sources append:new_source];
	}
	CFRelease(sources);
	CFRelease(addressBook);
	return valid_sources;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

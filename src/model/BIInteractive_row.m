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

#import "model/BIInteractive_row.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSDictionary+ELHASO.h"


@interface BIInteractive_row ()
@end

@implementation BIInteractive_row

@synthesize type = type_;
@synthesize data = data_;
@synthesize is_interactive = is_interactive_;
@synthesize is_private = is_private_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;

/** Initializes an interactive row.
 * If the rows passed to initialise don't match what is expected nil will be
 * returned.
 */
- (id)init_with_data:(NSArray*)data;
{
	LASSERT([data isKindOfClass:[NSArray class]], @"Bad data type");
	if (!(self = [super init]))
		return nil;

	type_ = IR_LAST;
	int f = 0;
	for (id thing in data) {
		NSString *text = [thing isKindOfClass:[NSString class]] ? thing : nil;
		NSNumber *num = [thing isKindOfClass:[NSNumber class]] ? thing : nil;
		const BOOL string_pos = f < 2;
		if ((string_pos && text.length) || (!string_pos && num)) {
			switch (f) {
				case 0:
					if ([text isEqualToString:@"name"])
						type_ = IR_NAME;
					else if ([text isEqualToString:@"address"])
						type_ = IR_ADDRESS;
					else if ([text isEqualToString:@"phone"])
						type_ = IR_PHONE;
					else if ([text isEqualToString:@"fax"])
						type_ = IR_FAX;
					else if ([text isEqualToString:@"email"])
						type_ = IR_EMAIL;
					else if ([text isEqualToString:@"web"])
						type_ = IR_WEB;
					else if ([text isEqualToString:@"twitter"])
						type_ = IR_TWITTER;
					else if ([text isEqualToString:@"facebook"])
						type_ = IR_FACEBOOK;
					else if ([text isEqualToString:@"linkedin"])
						type_ = IR_LINKEDIN;
					else
						DLOG(@"Unknown BIInteractive_row type '%@'", text);
					break;
				case 1: self.data = text; break;
				case 2: latitude_ = [num floatValue]; break;
				case 3: longitude_ = [num floatValue]; break;
				default:
					DLOG(@"Parsing interactive row, going out of valid range!");
					break;
			}
		}
		f++;
	}

	// Check that we got most attributes.
	if (IR_LAST == type_ || self.data.length < 1) {
		DLOG(@"Can't create an interactive row without type or data");
		[self release];
		return nil;
	}

	// Set the interactivity bit depending on the retrieved data.
	switch (type_) {
		case IR_NAME:
		case IR_FAX:
			is_interactive_ = NO;
			break;

		case IR_PHONE:
		case IR_EMAIL:
		case IR_WEB:
		case IR_TWITTER:
		case IR_FACEBOOK:
		case IR_LINKEDIN:
			is_interactive_ = YES;
			break;

		case IR_ADDRESS:
			is_interactive_ = (latitude_ && longitude_);
			break;

		default:
			LASSERT(NO, @"Unhandled interactivity row type!");
			break;
	}

	return self;
}

- (void)dealloc
{
	[data_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	NSString *extra = (latitude_ && longitude_) ? [NSString
		stringWithFormat:@", lat:%f lon:%f", latitude_, longitude_] : nil;

	return [NSString stringWithFormat:@"BIInteractive_row {type_:%d, "
		@"is_interactive:%d, data:%@%@}", type_, is_interactive_, data_,
		NON_NIL_STRING(extra)];
}

/** Returns the textual version of the type property.
 * \return Returns nil if the type is invalid. The returned string is localized
 * and all lower case.
 */
- (NSString*)type_string
{
	switch (self.type) {
		case IR_NAME: return _(CONTACTS_TEXT);
		case IR_ADDRESS: return _(CONTACTS_ADDRESS);
		case IR_PHONE: return _(CONTACTS_PHONE);
		case IR_FAX: return _(CONTACTS_FAX);
		case IR_EMAIL: return _(CONTACTS_EMAIL);
		case IR_WEB: return _(CONTACTS_WEB);
		case IR_TWITTER: return _(CONTACTS_TWITTER);
		case IR_FACEBOOK: return _(CONTACTS_FACEBOOK);
		case IR_LINKEDIN: return _(CONTACTS_LINKEDIN);
		default:
			LASSERT(NO, @"Unknown BIInteractive_row type");
			return nil;
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

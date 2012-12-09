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

#import "model/BIRelated_person.h"

#import "entity/BIEntity_view_controller.h"

#import "ELHASO.h"
#import "NSDictionary+ELHASO.h"

@interface BIRelated_person ()
@end

@implementation BIRelated_person

@synthesize id_ = id__;
@synthesize image = image_;
@synthesize full_name = full_name_;
@synthesize job = job_;

/** Initializes a related person object.
 * Related persons have all their properties present except the image url.
 */
- (id)init_with_data:(NSArray*)data
{
	LASSERT([data isKindOfClass:[NSArray class]], @"Bad data type");
	if (!(self = [super init]))
		return nil;

	id__ = -1;
	// Parse
	int f = 0;
	for (id thing in data) {
		NSString *text = [thing isKindOfClass:[NSString class]] ? thing : nil;
		NSNumber *num = [thing isKindOfClass:[NSNumber class]] ? thing : nil;
		const BOOL string_pos = f > 0;
		if ((string_pos && text.length) || (!string_pos && 0 == f)) {
			switch (f) {
				case 0: id__ = [num intValue]; break;
				case 1: self.job = text; break;
				case 2: self.full_name = text; break;
				case 3: self.image = text; break;
				default:
					DLOG(@"Parsing related persons, going out of valid range!");
					break;
			}
		}
		f++;
	}

	// Check that we got most attributes.
	if (id__ < 0) {
		DLOG(@"Can't create a related person without valid id");
		[self release];
		return nil;
	}

	if (self.job.length < 1) {
		DLOG(@"Can't create a related person without valid job title");
		[self release];
		return nil;
	}

	if (self.full_name.length < 1) {
		DLOG(@"Can't create a related person without valid full name");
		[self release];
		return nil;
	}

	return self;
}

- (void)dealloc
{
	[image_ release];
	[job_ release];
	[full_name_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIRelated_person {id:%d, "
		@"name:%@, job:%@, image:%@}", id__, full_name_, job_, image_];
}

/** Gets the appropriate view controller for the person being pointed by this.
 * \return The returned view controller needs only to be pushed on the
 * navigation stack. The method can return nil, in which case you shouldn't try
 * to push nil on the stack. Really.
 */
- (UIViewController*)get_controller
{
	BIEntity_view_controller *c = [BIEntity_view_controller new];
	[c set_api:API_PERSON num:self.id_];
	c.item_title = self.full_name;
	return [c autorelease];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

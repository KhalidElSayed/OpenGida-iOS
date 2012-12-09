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

#import "model/BIPagination.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"


@implementation BIPagination

@synthesize index = index_;
@synthesize total = total_;
@synthesize size = size_;

/** Parses a JSON array containing pagination attributes.
 * \return Returns a nicely filled out BIPagination class, or nil if the info
 * was not valid.
 */
+ (id)parse_json:(NSArray*)json
{
	if (![json isKindOfClass:[NSArray class]])
		return nil;

	if (3 != json.count) {
		DLOG(@"Ignoring pagination array with wrong count %@", json);
		return nil;
	}

	for (id tester in json) {
		if (![tester respondsToSelector:@selector(intValue)]) {
			DLOG(@"Ignoring patination array without numbers: %@", json);
			return nil;
		}
	}
	const int page_total = [[json get:0] intValue];
	const int page_index = [[json get:2] intValue];
	const int page_size = [[json get:1] intValue];

	if (page_total < 1) {
		DLOG(@"Ignoring pagination with zero or less items %@", json);
		return nil;
	}

	if (page_index < 0 || page_index >= page_total) {
		DLOG(@"Ignoring page index out of bounds of total %@", json);
		return nil;
	}

	if (page_size < 1 || page_size > page_total) {
		DLOG(@"Ignoring bad page size %@", json);
		return nil;
	}

	BIPagination *ret = [BIPagination new];
	if (!ret)
		return nil;

	ret.total = page_total;
	ret.size = page_size;
	ret.index = page_index;

	return [ret autorelease];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIPagination {total:%d, "
		@"page size %d, index %d}", total_, size_, index_];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

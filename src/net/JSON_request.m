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

#import "net/JSON_request.h"

#import "ELHASO.h"
#import "JSONKit.h"


@implementation JSON_request

@synthesize json = json_;
@synthesize items = items_;

static JSONDecoder *_decoder;

+ (void)initialize
{
	if (!_decoder)
		_decoder = [[JSONDecoder decoder] retain];
}

- (void)dealloc
{
	[json_ release];
	[items_ release];
	[super dealloc];
}

/** Simple hook to let the caller parse data in the background thread.
 * If the delegate doesn't conform to the BIJSON_parser protocol, nothing
 * happens. Otherwise this method parses the basic JSON with the global decoder
 * and passes the result to the function.
 */
- (void)requestFinished
{
	DONT_BLOCK_UI();
	if ([self.delegate
			respondsToSelector:@selector(parse_in_background:error:)]) {
		NSError *json_error = nil;
		id<BIJSON_parser> d = self.delegate;
		const int status = [self responseStatusCode];
		if (status < 200 || status >= 300) {
			NSString *error_message = [NSString stringWithFormat:
				@"Server returned (%d): %@ for %@", status,
				[self responseStatusMessage], url];
			DLOG(@"%@", error_message);
			self.json = nil;
			json_error = [NSError errorWithDomain:NSURLErrorDomain
				code:status userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
					url, NSURLErrorFailingURLErrorKey,
					error_message, NSLocalizedDescriptionKey, nil]];
		} else {
			@synchronized (_decoder) {
				NSData *data = [self responseData];
				self.json = [_decoder objectWithData:data error:&json_error];
			}
		}
		[d parse_in_background:self error:json_error];
	}

	[super requestFinished];
}

/** Uses the global static JSON decoder to parse random ASIHTTPRequest results.
 * \return Returns nil or the NSDictionary with the results.
 */
+ (NSDictionary*)parse:(ASIHTTPRequest*)request
{
	NSDictionary *ret = nil;
	NSError *error = nil;

	@synchronized (_decoder) {
		ret = [_decoder objectWithData:[request responseData] error:&error];
	}

	if (error) {
		DLOG(@"There was a JSON parsing error!\n\t%@", error);
		return nil;
	} else {
		return ret;
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

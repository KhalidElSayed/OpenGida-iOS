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

#import "protocol/BIItem_receiver_protocol.h"
#import "net/BIAPI_types.h"

@class ASINetworkQueue;
@class CLLocation;
@class JSON_request;
@class MAZeroingWeakRef;

/** Object controlling network connections to a specific API point.
 *
 * View controllers create instances of this class to control network requests.
 * The object encapsulates the success/error handlers and presents a simple
 * item array with the available results.
 */
@interface BIAPI_entry : NSObject
{
	/// Internal array of items as received from the net.
	NSMutableArray *items_;

	/// Or maybe we are holding a single answer?
	NSObject *single_item_;

	/// Internal array of navigation categories as received from the net.
	NSMutableArray *navigation_;

	/// The base API url for this entry.
	NSString *base_url_;

	/// Pointer to the callback receiving updates.
	MAZeroingWeakRef *delegate_;

	/// Stores the type and identifier of the resource we requested.
	API_TYPE type_;
	int id__;

	/// Internal connection object for the request.
	JSON_request *request_;

	/// Stores the total number of items according to pagination or negative.
	int pagination_total_;
	/// Stores the size of each pagination request or negative if not needed.
	int pagination_size_;

	/// The operation queue we will use to query pagination requests.
	ASINetworkQueue *page_queue_;
	/// This set will block the same queries while they are being done.
	NSMutableSet *page_progress_;

	/// This will be set to NO when the user calls start.
	BOOL virgin_;

	/// Holds a copy of the last searched text before url encoding it.
	NSString *search_term_;

	/// Variables to hold the results of quick_index parsing.
	NSArray *qi_titles_, *qi_numbers_;

	/// Text version of the location used to make the search. Just append.
	NSString *location_params_;
}

@property (nonatomic, readonly, assign) API_TYPE type;
@property (nonatomic, readonly, assign) int id_;
@property (nonatomic, retain) id<BIItem_receiver_protocol> delegate;
@property (nonatomic, retain) NSString *search_term;
@property (nonatomic, retain) NSString *location_params;

- (id)init_with_entry:(API_TYPE)type item:(int)id_
	delegate:(id<BIItem_receiver_protocol>)delegate;

- (id)init_with_search:(NSString*)text location:(CLLocation*)location
	delegate:(id<BIItem_receiver_protocol>)delegate;

- (id)init_with_search:(API_TYPE)type total_count:(int)total_count
	initial_search:(BIAPI_entry*)initial_search
	delegate:(id<BIItem_receiver_protocol>)delegate;

- (BOOL)start;
- (void)cancel;
- (NSString*)html_url;

- (void)request_page_for_row:(int)row;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

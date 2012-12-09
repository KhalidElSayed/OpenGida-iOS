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

#import "net/BIAPI_entry.h"

#import "global/BIGlobal.h"
#import "model/BICategory_item.h"
#import "model/BIEntity_item.h"
#import "model/BIJSON_Category.h"
#import "model/BIJSON_Search.h"
#import "model/BIPagination.h"
#import "net/JSON_request.h"

#import "ASIDownloadCache.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ELHASO.h"
#import "JSONKit.h"
#import "MAZeroingWeakRef.h"
#import "NSArray+ELHASO.h"
#import "NSDictionary+ELHASO.h"
#import "NSString+ELHASO.h"
#import "UILabel+ELHASO.h"

#import <CoreLocation/CoreLocation.h>


#define _DEFAULT_ROWS				30


@interface BIAPI_entry () <BIJSON_parser>

@end

@implementation BIAPI_entry

@synthesize type = type_;
@synthesize id_ = id__;
@synthesize search_term = search_term_;
@synthesize location_params = location_params_;

/** Initialize the default ASIHTTPRequest content cache.
 */
+ (void)initialize
{
	static BOOL virgin = YES;
	if (virgin) {
		ASIDownloadCache *cache = [ASIDownloadCache sharedCache];
		//cache.defaultCachePolicy = ASICachePermanentlyCacheStoragePolicy;
		DLOG(@"Setting permanent ASIDownloadCache to %@", cache.storagePath);
		[ASIHTTPRequest setDefaultCache:cache];
	}
}

/** Initializes an index search.
 * You can pass any of API_CATEGORY, API_ENTITY or API_PERSON. Any other types
 * will be rejected and you will get nil returned.
 */
- (id)init_with_entry:(API_TYPE)type item:(int)id_
	delegate:(id<BIItem_receiver_protocol>)delegate;
{
	if (!(self = [super init]))
		return nil;

	virgin_ = YES;
	id__ = id_;
	type_ = type;
	self.delegate = delegate;
	pagination_size_ = pagination_total_ = -1;

	switch (type) {
		case API_CATEGORY:
			if (id_ < 1)
				base_url_ = [[NSString alloc]
					initWithFormat:@"%@/%@/categories.json",
					[BIGlobal get_server_url], [BIGlobal get_data_langcode]];
			else
				base_url_ = [[NSString alloc]
					initWithFormat:@"%@/%@/categories/%d.json",
					[BIGlobal get_server_url],
					[BIGlobal get_data_langcode], id_];
			LASSERT(!self.delegate || [self.delegate respondsToSelector:
				@selector(update_items:navigation:qi_titles:qi_numbers:)],
				@"Huh, bad category API selector?");
			break;

		case API_ENTITY:
			base_url_ = [[NSString alloc]
				initWithFormat:@"%@/%@/entities/%d.json",
					[BIGlobal get_server_url],
					[BIGlobal get_data_langcode], id_];
			LASSERT(!self.delegate || [self.delegate
				respondsToSelector:@selector(update_entity:)],
				@"Huh, bad entity API selector?");
			break;

		case API_PERSON:
			base_url_ = [[NSString alloc]
				initWithFormat:@"%@/%@/people/%d.json",
					[BIGlobal get_server_url],
					[BIGlobal get_data_langcode], id_];
			LASSERT(!self.delegate || [self.delegate
				respondsToSelector:@selector(update_entity:)],
				@"Huh, bad entity API selector?");
			break;

		default:
			LASSERT(0, @"Unknown BIAPI_entry type request");
			[self release];
			return nil;
	}

	return self;
}

/** Initializes a word search.
 * The type of the search will be API_SEARCH_ROOT. If you pass a non nil
 * CLLocation you will get a geosearch.
 */
- (id)init_with_search:(NSString*)text location:(CLLocation*)location
	delegate:(id<BIItem_receiver_protocol>)delegate
{
	if (!(self = [super init]))
		return nil;

	virgin_ = YES;
	id__ = -1;
	type_ = API_SEARCH_ROOT;
	self.delegate = delegate;
	pagination_size_ = pagination_total_ = -1;
	LASSERT(!search_term_, @"Wrong initialization");
	search_term_ = [text retain];

	NSString *filename = location ? @"geosearch" : @"search";
	LASSERT(!location_params_, @"Double initialization");
	if (location)
		location_params_ = [[NSString alloc] initWithFormat:@"&lat=%f&lon=%f",
			location.coordinate.latitude, location.coordinate.longitude];

	base_url_ = [[NSString alloc]
		initWithFormat:@"%@/%@/site/%@.json?q=%@%@",
		[BIGlobal get_server_url], [BIGlobal get_data_langcode],
		filename, [text split_and_encode],
		NON_NIL_STRING(location_params_)];

	LASSERT(!self.delegate || [self.delegate respondsToSelector:
		@selector(update_items:navigation:qi_titles:qi_numbers:)],
		@"Huh, bad category API selector?");

	return self;
}

/** Initializes a detailed search with pagination.
 * Pass the type of the pagination, either API_SEARCH_ENTITIES or
 * API_SEARCH_PEOPLE and the total count of expected results. The other
 * parameters are extracted from the previous BIAPI_entry used for the initial
 * search.
 */
- (id)init_with_search:(API_TYPE)type total_count:(int)total_count
	initial_search:(BIAPI_entry*)initial_search
	delegate:(id<BIItem_receiver_protocol>)delegate;
{
	LASSERT(total_count > 0, @"The total search count should be positive");
	LASSERT(API_SEARCH_PEOPLE == type || API_SEARCH_ENTITIES == type,
		@"Unexpected type");
	if (!(self = [super init]))
		return nil;

	virgin_ = YES;
	id__ = -1;
	type_ = type;
	self.delegate = delegate;
	pagination_size_ = pagination_total_ = -1;
	self.search_term = initial_search.search_term;
	self.location_params = initial_search.location_params;

	NSString *filename = self.location_params.length ? @"geosearch" : @"search";
	NSString *type_param = (API_SEARCH_ENTITIES == type) ?
		@"entities" : @"people";

	base_url_ = [[NSString alloc]
		initWithFormat:@"%@/%@/site/%@.json?q=%@%@&type=%@&size=%d",
		[BIGlobal get_server_url], [BIGlobal get_data_langcode],
		filename, [self.search_term split_and_encode],
		NON_NIL_STRING(self.location_params), type_param, total_count];

	LASSERT(!self.delegate || [self.delegate respondsToSelector:
		@selector(update_items:navigation:qi_titles:qi_numbers:)],
		@"Huh, bad category API selector?");

	return self;
}

/** Cancels whatever pending downloads were being done as part of the API.
 * You have to call this always before releasing the API object, or stuff will
 * linger forever.
 */
- (void)cancel
{
	[request_ clearDelegatesAndCancel];
	[request_ release];
	request_ = nil;

	[page_queue_ reset];
	[page_queue_ release];
	page_queue_ = nil;
}

- (void)dealloc
{
	[self cancel];
	[qi_titles_ release];
	[qi_numbers_ release];
	[search_term_ release];
	[single_item_ release];
	[page_progress_ release];
	[base_url_ release];
	[navigation_ release];
	[location_params_ release];
	[items_ release];
	[delegate_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIAPI_entry {type:%d, id:%d, url:%@}",
		type_, id__, base_url_];
}

/// Weak delegate setter.
- (void)setDelegate:(id<BIItem_receiver_protocol>)delegate
{
	[delegate_ release];
	delegate_ = [[MAZeroingWeakRef alloc] initWithTarget:delegate];
}

/// Weak delegate getter.
- (id<BIItem_receiver_protocol>)delegate
{
	return [delegate_ target];
}

/** Returns the base_url_ without .json extension, for HTML consumption.
 */
- (NSString*)html_url
{
	return [base_url_ stringByReplacingOccurrencesOfString:@".json"
		withString:@""];
}

/** Starts the network request for the API.
 * You can call this method as many times as you want, but it will actually
 * only perform once.
 * \return Returns YES if the connection was actually started.
 */
- (BOOL)start
{
	if (!virgin_)
		return NO;

	virgin_ = NO;
	[request_ clearDelegatesAndCancel];
	[request_ release];

	NSURL *url = nil;
	// The paginated search requires a "help", appending the first page.
	if (API_SEARCH_ENTITIES == type_ || API_SEARCH_PEOPLE == type_)
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=1",
			base_url_]];
	else
		url = [NSURL URLWithString:base_url_];

	request_ = [[JSON_request requestWithURL:url] retain];

	NSString *username = [BIGlobal get_http_user];
	if (username.length > 0) {
		[request_ setUsername:username];
		[request_ setPassword:[BIGlobal get_http_pass]];
	}
	[request_ setDelegate:self];
	DLOG(@"Net %@", url);
	[request_ startAsynchronous];
	return YES;
}

#pragma mark JSON_request protocol

/** Parses the JSON dom in the background.
 */
- (void)parse_in_background:(JSON_request*)request error:(NSError*)error
{
	DONT_BLOCK_UI();
	LASSERT(!items_, @"Double initialization");
	LASSERT(!single_item_, @"This shouldn't be called twice");

	if (error || !request.json) {
		NSString *error_message = _F(JSON_PARSER_ERROR,
			error.localizedDescription);
		DLOG(@"%@", error_message);
		items_ = [[NSMutableArray alloc] initWithObjects:[BICategory_item
			specific_error:error_message], nil];
		return;
	}

	if (API_CATEGORY == type_) {
		BIJSON_Category *data = [BIJSON_Category parse_json:request.json];
		if (data) {
			items_ = [[data prepare_for_first_use] retain];
			navigation_ = [[NSMutableArray alloc]
				initWithArray:data.navigation];
			qi_titles_ = [data.qi_titles retain];
			qi_numbers_ = [data.qi_numbers retain];
			if (data.pagination) {
				pagination_total_ = data.pagination.total;
				pagination_size_ = data.pagination.size;
			}
		} else {
			NSString *error_message = _(JSON_CATEGORY_ERROR);
			DLOG(@"%@", error_message);
			items_ = [[NSMutableArray alloc] initWithObjects:[BICategory_item
				specific_error:error_message], nil];
		}
	} else if (API_ENTITY == type_ || API_PERSON == type_) {
		BIEntity_item *thing = [[BIEntity_item alloc]
			init_with_json:request.json id_:id__];
		single_item_ = thing;
		LASSERT(type_ == thing.type || !thing, @"Unexpected parsed type!");
	} else if (API_SEARCH_ROOT == type_) {
		BIJSON_Search *data = [BIJSON_Search parse_json:request.json
			search_term:search_term_];
		if (data) {
			items_ = [[data prepare_for_first_use] retain];
			navigation_ = [[NSMutableArray alloc]
				initWithArray:data.navigation];
		} else {
			NSString *error_message = _(JSON_SEARCH_ERROR);
			DLOG(@"%@", error_message);
			items_ = [[NSMutableArray alloc] initWithObjects:[BICategory_item
				specific_error:error_message], nil];
		}
	} else if (API_SEARCH_PEOPLE == type_ || API_SEARCH_ENTITIES == type_) {
		BIJSON_Search *data = [BIJSON_Search parse_json:request.json
			type:type_];
		if (data && data.pagination) {
			items_ = [[data prepare_for_first_use] retain];
			navigation_ = [[NSMutableArray alloc]
				initWithArray:data.navigation];
			pagination_total_ = data.pagination.total;
			pagination_size_ = data.pagination.size;
		} else {
			NSString *error_message = _(JSON_SEARCH_PAGE_ERROR);
			DLOG(@"%@", error_message);
			items_ = [[NSMutableArray alloc] initWithObjects:[BICategory_item
				specific_error:error_message], nil];
		}
	} else {
		LASSERT(NO, @"Not implemented yet");
	}
}

/** Something happened to the network and the request failed.
 */
- (void)requestFailed:(JSON_request*)request
{
	NSString *error_message = _F(NETWORK_ERROR,
		request.originalURL, request.error.localizedDescription);
	DLOG(@"%@", error_message);

	UNLOAD_OBJECT(items_);
	items_ = [[NSMutableArray alloc] initWithObjects:[BICategory_item
		specific_error:error_message], nil];

	switch (type_) {
		case API_ENTITY:
		case API_PERSON:
			[self.delegate update_entity:[items_ get:0]];
			break;
		default:
			[self.delegate update_items:items_ navigation:navigation_
				qi_titles:nil qi_numbers:nil];
			break;
	}
}

/** Cool, we can update now the data processed inside parse_in_background.
 */
- (void)requestFinished:(JSON_request*)request
{
#ifdef DEBUG
	if (0 == (random() % 3)) {
		[self requestFailed:request];
		return;
	}
#endif
	switch (type_) {
		case API_CATEGORY:
		case API_SEARCH_ROOT:
		case API_SEARCH_ENTITIES:
		case API_SEARCH_PEOPLE:
			[self.delegate update_items:items_ navigation:navigation_
				qi_titles:qi_titles_ qi_numbers:qi_numbers_];
			break;
		case API_ENTITY:
		case API_PERSON:
			[self.delegate update_entity:(BIEntity_item*)single_item_];
			break;
		default:
			LASSERT(NO, @"Not implemented yet");
			break;
	}
}

#pragma mark GDC pagination code

/** Requests pagination from the server.
 * This method will fail if the pagination is not correctly set up, or the
 * index request falls out of the known range. Otherwise, the method will queue
 * a network request and parse to update the page containing the specified
 * item.
 *
 * All requests are handled serially, so if the first request fetches the item,
 * further requests won't do anything because they are rejected while the page
 * is being fetched.
 */
- (void)request_page_for_row:(int)row
{
	LASSERT(items_, @"Can't request a page for something without items!");
	LASSERT(![items_ get_non_null:row], @"Requested row is already there");

	if (!page_queue_) {
		page_queue_ = [ASINetworkQueue new];
		page_queue_.shouldCancelAllRequestsOnFailure = NO;
		[page_queue_ setMaxConcurrentOperationCount:3];
		[page_queue_ setDelegate:self];
		[page_queue_ setRequestDidFinishSelector:@selector(page_request_done:)];
		[page_queue_ setRequestDidFailSelector:@selector(page_request_error:)];
		[page_queue_ go];
		page_progress_ = [[NSMutableSet alloc] initWithCapacity:10];
	}

	LASSERT(page_queue_, @"Couldn't create operation queue");
	RASSERT(pagination_size_ > 0, @"Invalida pagination size", return);
	RASSERT(row >= 0 && row < pagination_total_,
		@"Pagination request is out of range", return);

	const BOOL has_question_mark = (NSNotFound != [base_url_
		rangeOfString:@"?" options:NSLiteralSearch].location);
	NSString *page_url = [NSString stringWithFormat:@"%@%@page=%d",
		base_url_, has_question_mark ? @"&" : @"?", 1 + row / pagination_size_];
	NSURL *url = [NSURL URLWithString:page_url];

	// Check if the request is already being processed.
	@synchronized (page_progress_) {
		if ([page_progress_ member:url])
			return;
		else
			[page_progress_ addObject:url];
	}

	// Create a connection request and enqueue it with others.
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	DLOG(@"Net page %@", page_url);
	[page_queue_ addOperation:request];
}

/** Synchronized removeObject wrapper around the page_progress_ variable.
 * It's such a pain to write synchro... whatever.
 */
- (void)remove_progress_lock:(NSURL*)url
{
	@synchronized (page_progress_) {
		[page_progress_ removeObject:url];
	}
}

/** Run when a page request finishes successfully.
 * Since this is run in the UI thread, we spawn a low priority block for the
 * JSON processing.
 */
- (void)page_request_done:(ASIHTTPRequest*)request
{
	if (!self.delegate) {
		dispatch_async_low(^{
				[self remove_progress_lock:[request originalURL]];
			});
		return;
	}

	const BOOL search_pagination = (API_SEARCH_ENTITIES == type_ ||
		API_SEARCH_PEOPLE == type_);

	// Ok, with a delegate we will perform the processing.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		DONT_BLOCK_UI();
		// Parse the returned JSON and replace it at the specified index.
		NSDictionary *json = [JSON_request parse:request];
		BIJSON_Category *data = search_pagination ?
			[BIJSON_Search parse_json:json type:type_] :
			[BIJSON_Category parse_json:json];

		if (!data.pagination) {
			[self remove_progress_lock:[request originalURL]];
			DEV_LOG(@"Didn't find pagination info in parsed JSON! %@",
				[request responseString]);
			return;
		}

		const NSRange r =
			(NSRange){ data.pagination.index, data.items.count };

		// Check that we are not out of range
		if (r.location + r.length > items_.count) {
			DEV_LOG(@"Server returned page index %d with length %d => "
				@"[%d to %d], but the table has only %d items. Ignoring.",
				r.location, r.length,
				r.location, r.location + r.length, items_.count);
		} else {
			[items_ replaceObjectsInRange:r
				withObjectsFromArray:data.items];

			// Tell the delegate we got some objects. Brute force or not.
			if ([self.delegate respondsToSelector:@selector(update_range:)]) {
				// Figure out what should be the section for the indices.
				const int section = [self.delegate
					respondsToSelector:@selector(get_item_section)] ?
					[self.delegate get_item_section] : 0;

				// Build list of rows to update.
				NSMutableArray *indices = [NSMutableArray
					arrayWithCapacity:r.length];
				for (int f = 0; f < r.length; f++)
					[indices addObject:[NSIndexPath
						indexPathForRow:r.location + f inSection:section]];

				run_on_ui(^{ [self.delegate update_range:indices]; });
			} else {
				run_on_ui(^{ [self.delegate update_items:items_
						navigation:navigation_ qi_titles:qi_titles_
						qi_numbers:qi_numbers_]; });
			}
		}
		[self remove_progress_lock:[request originalURL]];
	});
}

/** A page request failed.
 * Oh well, at least free the requested url from the protection set.
 */
- (void)page_request_error:(ASIHTTPRequest*)request
{
	DLOG(@"Error retrieving %@:\n%@", [request originalURL], [request error]);
	[self remove_progress_lock:[request originalURL]];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

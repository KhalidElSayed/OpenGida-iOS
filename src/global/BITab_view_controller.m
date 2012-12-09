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

#import "global/BITab_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "entity/BIEntity_view_controller.h"
#import "global/BIGlobal.h"
#import "index/BIIndex_view_controller.h"
#import "protocol/BISerialization_protocol.h"
#import "settings/BIInfo_view_controller.h"
#import "settings/BIMaster_langcode_view_controller.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSNotificationCenter+ELHASO.h"


// Internal forward declarations.
NSString *_extract_hierarchy_tuple(NSArray *tuple, int *api, int *num);

@interface BITab_view_controller ()
- (UINavigationController*)build_tab:(UIViewController*)controller
	tab_title:(NSString*)tab_title tab_icon:(NSString*)tab_icon;
@end

@implementation BITab_view_controller

- (void)loadView
{
	[super loadView];

	// One time app initialisation.
	static BOOL virgin = YES;
	if (!virgin)
		return;

	BIIndex_view_controller *t1 = [BIIndex_view_controller new];
	[t1 set_api:API_CATEGORY num:0];
	BIMaster_langcode_view_controller *t2 =
		[BIMaster_langcode_view_controller new];
	BIInfo_view_controller *t3 = [BIInfo_view_controller new];

	self.viewControllers = [NSArray arrayWithObjects:
		[self build_tab:t1 tab_title:_(TAB_GUIDE) tab_icon:@"tab_main.png"],
		[self build_tab:t2 tab_title:_(TAB_LANG) tab_icon:@"tab_lang.png"],
		[self build_tab:t3 tab_title:_(TAB_INFO) tab_icon:@"tab_help.png"],
		nil];
	[t1 release];
	[t2 release];
	[t3 release];
	virgin = NO;

	// Recover the hierarchy of the first tab, if possible.
	NSArray *hierarchy = [BIGlobal load_hierarchy];
	if (hierarchy.count > 1) {
		UINavigationController *nav = [self.viewControllers get:0];
		LASSERT(nav, @"Can't be nil!");

		// Verify the first pair looks ok.
		NSArray *root_tuple = [hierarchy get:0];
		int api, num;
		NSString *title = _extract_hierarchy_tuple(root_tuple, &api, &num);
		if (!title) {
			DLOG(@"Couldn't extract a valid root tuple!");
		} else {
			LASSERT(API_CATEGORY == api, @"Bad persistence 1?");
			LASSERT(0 == num, @"Bad persistence 2?");
			NSArray *pending = [hierarchy subarrayWithRange:(NSRange){ 1,
				hierarchy.count - 1}];
			// Iterate the rest of hierarchy items, pushing each on the stack.
			for (NSArray *tuple in pending) {
				title = _extract_hierarchy_tuple(tuple, &api, &num);
				if (!title || (0 == api && 0 == num)) {
					DLOG(@"Bad tuple %@", tuple);
					break;
				}

				// Construct the new controller.
				UIViewController *controller = nil;
				if (0 == api) {
					t1 = [BIIndex_view_controller new];
					[t1 set_api:API_CATEGORY num:num];
					t1.item_title = title;
					controller = t1;
				} else {
					LASSERT(API_ENTITY == api || API_PERSON == api, @"Uh oh");
					BIEntity_view_controller *entity =
						[BIEntity_view_controller new];
					entity.item_title = title;
					[entity set_api:api num:num];
					controller = entity;
				}

				// Push push baby!
				if (controller) {
					controller.hidesBottomBarWhenPushed = YES;
					[nav pushViewController:controller animated:NO];
					[controller release];
				} else {
					DLOG(@"There was an error restoring the hierarchy?");
					break;
				}
			}
		}
	}

	// To be safe, empty the hierarchy now that it was restored.
	[BIGlobal save_hierarchy:nil];

	[[NSNotificationCenter defaultCenter] refresh_observer:self
		selector:@selector(refresh_ui:)
		name:BIUI_langcode_did_change object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

/** Called when the user changes globally the user language.
 * We need to refresh the text of the tabs.
 */
- (void)refresh_ui:(NSNotification*)notification
{
	run_on_ui(^{
			DLOG(@"refreshing BITab_view_controller %@", notification);
			UINavigationController *nav = [self.viewControllers get:0];
			nav.tabBarItem.title = _(TAB_GUIDE);
			nav = [self.viewControllers get:1];
			nav.tabBarItem.title = _(TAB_LANG);
			nav = [self.viewControllers get:2];
			nav.tabBarItem.title = _(TAB_INFO);
			self.viewControllers = self.viewControllers;
		});
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

/** Simple UINavigationController wrapper over normal view controllers.
 * Pass the title of the tab and the path to the tab's icon.
 */
- (UINavigationController*)build_tab:(UIViewController*)controller
	tab_title:(NSString*)tab_title tab_icon:(NSString*)tab_icon
{
	//controller.title = tab_title;
	UINavigationController *navigation_controller =
		[[UINavigationController alloc] initWithRootViewController:controller];

	navigation_controller.navigationBar.tintColor =
		[UIColor navigation_bar_green_2];

	UITabBarItem *item = [[UITabBarItem alloc]
		initWithTitle:tab_title image:[UIImage imageNamed:tab_icon] tag:0];
	navigation_controller.tabBarItem = item;
	[item release];
	return [navigation_controller autorelease];
}

/** Tries to save the current guide hierarchy to a file.
 */
- (void)save_hierarchy
{
	if (0 != self.selectedIndex)
		return;

	DLOG(@"Saving hierarchy for guide tab");
	NSArray *hierarchy = ASK_GETTER(self.selectedViewController,
		viewControllers, nil);
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:hierarchy.count];
	for (id controller in hierarchy) {
		NSArray *tuple = ASK_GETTER(controller, get_serialization_tuple, nil);
		if (3 == tuple.count) {
			[valid addObject:tuple];
		} else {
			DLOG(@"Unexpected hierarchy cut at %@", controller);
			break;
		}
	}

	if (valid.count > 1)
		[BIGlobal save_hierarchy:valid];
	else
		[BIGlobal save_hierarchy:nil];
}

/** Called when the user changed the server in the background.
 * What we do is pop all the guide view controllers and simulate a content
 * change on the root one, so it fetches new data.
 */
- (void)server_changed
{
	UINavigationController *nav = [self.viewControllers get:0];
	LASSERT([nav isKindOfClass:[UINavigationController class]], @"Ho hooo");
	[nav popToRootViewControllerAnimated:NO];
	// Force data language refresh.
	ASK_GETTER(nav.visibleViewController, force_api_refresh, nil);
}

@end

/** Extracts a valid hierarchy tuple from the object.
 * The tuple is expected to have three objects, the first being the title and
 * the two others numbers. If something fails or doesn't live up to the
 * expectetions, returns nil. Otherwise the return value is the title and the
 * parameters are overwritten with the stored numbers.
 */
NSString *_extract_hierarchy_tuple(NSArray *tuple, int *api, int *num)
{
	if (!api || !num) {
		DLOG(@"Bad input pointers to extract tuple");
		return nil;
	}

	if (![tuple isKindOfClass:[NSArray class]]) {
		DLOG(@"Trying to extract array from non array! %@", tuple);
		return nil;
	}

	if (3 != tuple.count) {
		DLOG(@"Tuple with bad count %@", tuple);
		return nil;
	}

	NSString *title = [tuple get:0];
	NSNumber *n1 = [tuple get:1];
	NSNumber *n2 = [tuple get:2];

	if (![title isKindOfClass:[NSString class]]) {
		DLOG(@"first tuple object expected string %@", tuple);
		return nil;
	}

	if (![n1 isKindOfClass:[NSNumber class]]) {
		DLOG(@"second tuple object expected number %@", tuple);
		return nil;
	}

	if (![n2 isKindOfClass:[NSNumber class]]) {
		DLOG(@"second tuple object expected number %@", tuple);
		return nil;
	}

	*api = [n1 intValue];
	*num = [n2 intValue];
	return title;
}

// vim:tabstop=4 shiftwidth=4 syntax=objc

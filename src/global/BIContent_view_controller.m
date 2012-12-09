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

#import "global/BIContent_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "categories/UINavigationBar+Bidrasil.h"
#import "global/BIGlobal.h"
#import "global/BIMail_view_controller.h"

#import "ELHASO.h"
#import "NSObject+ELHASO.h"
#import "UIActivity.h"
#import "UIImageView+ELHASO.h"
#import "UILabel+ELHASO.h"
#import "UIView+ELHASO.h"


#define _FADE_SPEED				0.3


@interface BIContent_view_controller ()
- (void)rebuild_connecting_label;
@end


@implementation BIContent_view_controller

/** Handles creation of the view, pseudo constructor.
 */
- (void)loadView
{
	[super loadView];
	self.view.frame = self.view.bounds;

	[self rebuild_connecting_label];
	UIBarButtonItem *back = [[UIBarButtonItem alloc]
		initWithTitle:_(NAVIGATION_BACK) style:UIBarButtonItemStylePlain
		target:nil action:nil];
	self.navigationItem.backBarButtonItem = back;
	[back release];
}

/** Performs the reverse operation of loadView.
 * Call this inside your viewDidUnload or viewWillUnload methods to free extra
 * memory.
 */
- (void)unload_view
{
	[connecting_label_ release]; connecting_label_ = nil;
}

/** Frees up all resources.
 */
- (void)dealloc
{
	wait_for_ui(^{ [self unload_view]; });
	[super dealloc];
}

- (void)viewDidUnload
{
	wait_for_ui(^{ [self unload_view]; });
}

/** Simulates warnings, to force proper implementations of memory.
 * The warning will be queued so it happens after all the hierarchy of
 * viewDidAppear calls is run. Also updates is_visible_.
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self after:0 perform:^{ simulate_memory_warning(); }];
	is_visible_ = YES;
}

/** Updates is_visible_ local variable.
 */
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	is_visible_ = NO;
}

/// Hooks changing the navigation bar appearance for iOS 5.
- (void)viewDidLoad
{
	if ([self.navigationController.navigationBar
			respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {

		[self.navigationController.navigationBar
			setBackgroundImage:[UINavigationBar bar_background_with_logo]
			forBarMetrics:UIBarMetricsDefault];
	}
}


/** Practically does the same as rebuild_connecting_label.
 * However, this method can be subclassed.
 */
- (void)set_ui_labels
{
	[self rebuild_connecting_label];
	UIBarButtonItem *back = [[UIBarButtonItem alloc]
		initWithTitle:_(NAVIGATION_BACK) style:UIBarButtonItemStylePlain
		target:nil action:nil];
	self.navigationItem.backBarButtonItem = back;
	[back release];
}

/** Tries to show an error message/object on the screen.
 * You can pass any kind of object here and the method will try to solve its
 * type and figure out a way to display it. In the worst case, a generic error
 * message will be shown to the user. The error will be stored in the
 * connecting_label_ so you can call hide_connecting_label if you want to get
 * rid of it (eg. when the user retries a connection).
 */
- (void)show_error_label:(id)error_object
{
	NSString *error_text = ASK_GETTER(error_object, name, nil);
	if (!error_text)
		error_text = ASK_GETTER(error_object,
			localizedDescription, _(GENERIC_ERROR));

	UNLOAD_VIEW(connecting_label_);
	connecting_label_ = [[UILabel round_text:error_text
		bounds:CGRectMake(0, 0, 260, 400) fit:YES radius:20
		view:[UIImageView imageNamed:@"type-error.png"]] retain];
	connecting_label_.center = self.view.center;
	connecting_label_.alpha = 1;
	connecting_label_.userInteractionEnabled = NO;
	[self.view addSubview:connecting_label_];
	[connecting_label_ align_rect];
}

/** Refreshes the connecting_label_ object.
 * This involves freeing the previous one and creating a new one.
 */
- (void)rebuild_connecting_label
{
	const CGFloat alpha = connecting_label_.alpha;

	UNLOAD_VIEW(connecting_label_);
	connecting_label_ = [[UILabel round_text:_(CONTENT_CONNECTING_LABEL)
		bounds:CGRectMake(0, 0, 200, 200) fit:YES radius:20
		view:[UIActivity get_white_large]] retain];
	connecting_label_.center = self.view.center;
	connecting_label_.alpha = alpha;
	connecting_label_.userInteractionEnabled = NO;
	[self.view addSubview:connecting_label_];
	[connecting_label_ align_rect];
}

/** Fades in a label telling the user to wait while we connect to the server.
 * Also hides the retry button, since obviously the user is retrying already
 * the connection.
 */
- (void)show_connecting_label
{
	[self hide_retry_button];
	[UIView animateWithDuration:_FADE_SPEED delay:0
		DEFAULT_ANIM_OPTIONS | UIViewAnimationOptionBeginFromCurrentState
		animations:^{ connecting_label_.alpha = 1; } completion:nil];
}

/** Fades out the previously faded in label with show_connecting_label:
 */
- (void)hide_connecting_label
{
	[UIView animateWithDuration:_FADE_SPEED delay:0
		DEFAULT_ANIM_OPTIONS | UIViewAnimationOptionBeginFromCurrentState
		animations:^{ connecting_label_.alpha = 0; } completion:nil];
}

/** Shows in an animated fashion the retry button for the user.
 * Pass the action that will be hooked to it. Usually in this action you will
 * call hide_retry_button to disallow multiple retries.
 */
- (void)show_retry_button:(SEL)action
{
	UIBarButtonItem *button = [[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
		target:self action:action];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[button release];
	UIAccessibilityPostNotification(
		UIAccessibilityScreenChangedNotification, nil);
}

/// Hides the retry button, if available.
- (void)hide_retry_button
{
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	UIAccessibilityPostNotification(
		UIAccessibilityScreenChangedNotification, nil);
}

#ifdef ALLOWS_LANDSCAPE
/** Pass an orientation, get the width of the screen in that orientation.
 * Usually you will want to use this inside your
 * willAnimateRotationToInterfaceOrientation: method.
 */
- (CGFloat)will_rotate_to_width:(UIInterfaceOrientation)orientation
{
	// Detect what will be the biggest axis, and use that for new width.
	const CGRect app_frame = [[UIScreen mainScreen] applicationFrame];
	const BOOL portrait = UIInterfaceOrientationPortrait == orientation ||
		UIInterfaceOrientationPortraitUpsideDown == orientation;
	const CGFloat bigger = MAX(app_frame.size.height, app_frame.size.width);
	const CGFloat smaller = MIN(app_frame.size.height, app_frame.size.width);

	return portrait ? smaller : bigger;
}
#endif

/** Pops up a single button alert to the user. Fire and forget.
 */
- (void)show_alert:(NSString*)title text:(NSString*)text
	button:(NSString*)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
		message:text delegate:nil cancelButtonTitle:button
		otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/** Generic handler for URLs.
 * First constructs the URL removing whitespace, then tests if the URL can be
 * opened. If not, the error title/text are shown to the user.
 */
- (void)open_url:(NSString*)protocol address:(NSString*)address
	error_title:(NSString*)error_title error_text:(NSString*)error_text
{
	NSString *clean = [[address componentsSeparatedByCharactersInSet:
		[NSCharacterSet whitespaceAndNewlineCharacterSet]]
		componentsJoinedByString:@""];
	NSURL *url = [NSURL URLWithString:[protocol stringByAppendingString:clean]];
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:url]) {
		DLOG(@"Opening %@", url);
		[app openURL:url];
	} else {
		[self show_alert:error_title text:error_text button:_(BUTTON_ACCEPT)];
	}
}

/** The user wants to share the thing with the world or tell somebody something.
 * Pass the address you want to fill in the email view composer. While the view
 * composer goes up, the bidrasil name is disabled. It is enabled later in the
 * delegate callback.
 */
- (void)send_email:(NSString*)to
{
	if (![BIMail_view_controller canSendMail]) {
		[self show_alert:_(ERROR_NOMAIL_TITLE) text:_(ERROR_NOMAIL_MESSAGE)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	BIMail_view_controller *mail = [BIMail_view_controller new];
	mail.mailComposeDelegate = self;
	if (to.length)
		[mail setToRecipients:[NSArray arrayWithObject:to]];
	[UINavigationBar show_bidrasil:NO];
	[self presentModalViewController:mail animated:YES];
	[mail release];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

/** Forces dismissing of the view, only logging the error, not dealing with it.
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller
	didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	DLOG(@"Did mail fail? %@", error);
	[UINavigationBar show_bidrasil:YES];
	[self dismissModalViewControllerAnimated:YES];
}

@end

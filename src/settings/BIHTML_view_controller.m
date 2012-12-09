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

#import "settings/BIHTML_view_controller.h"

#import "categories/UINavigationBar+Bidrasil.h"
#import "global/BIGlobal.h"

#import "ELHASO.h"


@implementation BIHTML_view_controller

@synthesize filename = filename_;
@synthesize external = external_;

- (void)loadView
{
	[super loadView];

	self.title = @"";
	self.navigationItem.title = self.title;

	LASSERT(!web_view_, @"Double initialization");
	web_view_ = [[UIWebView alloc] initWithFrame:self.view.bounds];
	//web_view_.scalesPageToFit = YES;
	web_view_.autoresizesSubviews = YES;
	web_view_.autoresizingMask = FLEXIBLE_SIZE;
	web_view_.delegate = self;
	web_view_.dataDetectorTypes = UIDataDetectorTypeNone;
	NSString *path = [BIGlobal get_path_lang:self.filename];
	if (path)
		[web_view_ loadRequest:[NSURLRequest requestWithURL:
			[NSURL fileURLWithPath:path]]];
	[self.view addSubview:web_view_];
}

- (void)dealloc
{
	web_view_.delegate = nil;
	[web_view_ stopLoading];
	[web_view_ release];
	[external_ release];
	[filename_ release];
	[super dealloc];
}

/** Used by the web view delegate to open an url.
 * Before calling this you are meant to set the self.external variable properly.
 */
- (void)alert_opening_url
{
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle:_(WEBHELP_ALERT_TITLE) message:_(WEBHELP_ALERT_MESSAGE)
		delegate:self cancelButtonTitle:_(BUTTON_CANCEL)
		otherButtonTitles:_(BUTTON_ACCEPT), nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView
	clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex) {
		DLOG(@"Opening %@, bye bye!", self.external);
		[[UIApplication sharedApplication] openURL:self.external];
		exit(0);
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

/** Unlike the default behaviour, we don't want to show the bidrasil title yet.
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller
	didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	DLOG(@"Did mail fail? %@", error);
	[UINavigationBar show_bidrasil:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate protocol

- (void)webViewDidStartLoad:(UIWebView*)webView
{
	DLOG(@"Started loading.");
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
	DLOG(@"Did finish load");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	DLOG(@"Failed load with %@", error);
}

- (BOOL)webView:(UIWebView *)webView
	shouldStartLoadWithRequest:(NSURLRequest *)request
	navigationType:(UIWebViewNavigationType)navigationType
{
	switch (navigationType) {
		case UIWebViewNavigationTypeLinkClicked:
		case UIWebViewNavigationTypeFormSubmitted:
		case UIWebViewNavigationTypeFormResubmitted: {
			DLOG(@"Requesting %@", request);
			if (NSOrderedSame ==
					[[[request URL] scheme] caseInsensitiveCompare:@"mailto"]) {
				[self send_email:[[request URL] resourceSpecifier]];
			} else {
				self.external = request.URL;
				[self alert_opening_url];
			}
			return NO;
		}
		default:
			return YES;
	}
	return YES;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

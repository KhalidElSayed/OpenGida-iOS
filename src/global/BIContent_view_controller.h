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

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <UIKit/UIKit.h>

/** Common class for reusable methods.
 */
@interface BIContent_view_controller : UIViewController
	<MFMailComposeViewControllerDelegate>
{
	/// Simple label showing an activity indicator and a message.
	UIView *connecting_label_;

	/// Tracks the current visibility of the controller.
	BOOL is_visible_;
}

- (void)unload_view;
- (void)set_ui_labels;
- (void)show_connecting_label;
- (void)hide_connecting_label;
- (void)show_error_label:(id)error_object;
- (void)show_retry_button:(SEL)action;
- (void)hide_retry_button;

- (void)show_alert:(NSString*)title text:(NSString*)text
	button:(NSString*)button;

- (void)open_url:(NSString*)protocol address:(NSString*)address
	error_title:(NSString*)error_title error_text:(NSString*)error_text;

- (void)send_email:(NSString*)to;

- (void)mailComposeController:(MFMailComposeViewController*)controller
	didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

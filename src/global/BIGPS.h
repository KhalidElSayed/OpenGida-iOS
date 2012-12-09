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

#import <CoreLocation/CoreLocation.h>

/// Possible values for the accuracy setting of the GPS.
enum ACCURACY_ENUM
{
	HIGH_ACCURACY,			///< Best the device can provide. Default.
	MEDIUM_ACCURACY,		///< About 50m.
	LOW_ACCURACY,			///< 150m or more.
};

/// Required alias for enum.
typedef enum ACCURACY_ENUM ACCURACY;

@protocol BIGPS_delegate
- (void)gps_denied;
@end


/** Wraps and controlls the GPS collection of data.
 *
 * Holds the pointer to the real sqlite object and provides additional
 * wrapper helper functions to handle the database.
 */
@interface BIGPS : NSObject <CLLocationManagerDelegate>
{
	/// Pointer to the manager activating/desactivating Core Location.
	CLLocationManager *manager_;

	/// Last received position.
	CLLocation *last_pos_;

	BOOL gps_is_on_;

	/// Current accuracy setting.
	ACCURACY accuracy_;

	/// Notifications of denial are sent to this delegate.
	id<BIGPS_delegate> delegate_;
}

@property (nonatomic, retain, readonly) CLLocation *last_pos;
@property (nonatomic, readonly, assign) BOOL gps_is_on;
@property (nonatomic, readonly, assign) ACCURACY accuracy;
@property (nonatomic, assign) id<BIGPS_delegate> delegate;

+ (BIGPS*)get;
+ (NSString*)key_path;
- (id)init;
- (bool)start;
- (void)stop;
- (void)add_watcher:(id)watcher;
- (void)remove_watcher:(id)watcher;
- (void)set_accuracy:(ACCURACY)accuracy;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc

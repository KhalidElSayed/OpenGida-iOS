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

@class UIImage;

/// Api type, used for category index.
enum API_TYPE_ENUM
{
	API_CATEGORY,	///< For use with remote categories.
	API_ENTITY,		///< Retrieves information about an entity.
	API_PERSON,		///< Retrieves information about a person.
	API_SEARCH_ROOT,		///< Base index search page, no paging.
	API_SEARCH_PEOPLE,		///< Paged people specific search.
	API_SEARCH_ENTITIES,	///< Paged entities specific search.
	API_SEARCH_MORE_PEOPLE,		///< Moar button for people results.
	API_SEARCH_MORE_ENTITIES,	///< Moar button for entities results.
	API_ERROR,		///< Something when wrong, show an error to the user.
	API_UNKNOWN,	///< Valid object, but unknown/incomplete type.
};

typedef enum API_TYPE_ENUM API_TYPE;

UIImage *get_icon_for_api_type(API_TYPE type);

// vim:tabstop=4 shiftwidth=4 syntax=objc

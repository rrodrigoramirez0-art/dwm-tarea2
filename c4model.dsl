workspace "Bocato" "Plataforma de Sánguches Italianos - Modelo C4" {

    !identifiers hierarchical

    model {
        visitante = person "Cliente / Visitante" "Persona que consulta el catálogo público de sánguches."
        cliente = person "Cliente Autenticado" "Persona que realiza pedidos y consulta sus órdenes."
        operador = person "Administrador" "Personal autorizado para gestionar el catálogo e inventario."

        sistema = softwareSystem "Bocato System" "Sistema integral de venta y gestión de sánguches." {
            tags "SistemaEvaluado"

            frontend = container "Frontend Responsivo" "Interfaz de usuario web (HTML, CSS, JS) para consultar menú y hacer login." "HTML5 / JavaScript" {
                tags "Frontend"
            }

            apiGateway = container "API Gateway" "Punto de entrada HTTP (:8000). Valida Bearer Token, consulta Vault e inyecta X-Gateway-Secret." "FastAPI (:8000)" {
                tags "Gateway"
            
                httpEntry = component "Adaptador HTTP / CORS" "Recibe solicitudes del cliente, maneja preflight OPTIONS y CORS." "Módulo de Entrada" {
                    tags "EntradaC3"
                }
                identityFilter = component "Filtro de Autenticación" "Comprueba el Bearer Token entrante contra los secretos de Vault." "Módulo de Seguridad" {
                    tags "ControlC3"
                }
                routeDispatcher = component "Despachador Proxy" "Enruta la petición al backend e inyecta la cabecera X-Gateway-Secret." "Módulo de Enrutamiento" {
                    tags "AplicacionC3"
                }
                errorMapper = component "Manejador de Errores" "Captura excepciones de red y retorna respuestas HTTP (401, 403, 502)." "Módulo de Errores" {
                    tags "ErrorC3"
                }
            }

            authService = container "Auth Service" "Servicio de autenticación (:8100), emisión de tokens, introspección y revocación." "FastAPI (:8100)" {
                tags "Seguridad"
            }

            secretManager = container "HashiCorp Vault" "Almacena secretos compartidos (client_token y backend_shared_secret)." "Vault (:8200)" {
                tags "Seguridad"
            }

            backend = container "Backend API" "Servicio interno de negocio (:9000). Expone /sandwiches y valida acceso exclusivo del Gateway." "FastAPI (:9000)" {
                tags "Privado"
            
                backendApi = component "Endpoints API" "Atiende /sandwiches y procesa solicitudes de productos." "API Interna" {
                    tags "EntradaC3"
                }
                securityFilter = component "Verificador de Gateway" "Valida que las peticiones contengan la cabecera X-Gateway-Secret válida." "Módulo de Seguridad" {
                    tags "ControlC3"
                }
            }

            dbSandwiches = container "Datos de Menú" "Almacenamiento persistente o en memoria del catálogo de productos." "Database / Memory" {
                tags "BaseDatos"
            }
        }

        // --- RELACIONES C1 y C2 ---
        visitante -> sistema.frontend "Consulta productos y promociones" "Navegador Web"
        cliente -> sistema.frontend "Inicia sesión y realiza pedidos" "Navegador Web"
        operador -> sistema.frontend "Administra productos autorizados" "Navegador Web"

        sistema.frontend -> sistema.apiGateway.httpEntry "Envía peticiones HTTP con Bearer Token" "HTTPS / JSON"
        sistema.apiGateway -> sistema.secretManager "Consulta client_token y backend_shared_secret" "HTTP API"
        sistema.apiGateway -> sistema.authService "Solicita introspección o validación de sesión" "HTTPS / JSON"
        sistema.apiGateway.routeDispatcher -> sistema.backend "Enruta solicitudes inyectando X-Gateway-Secret" "HTTPS / JSON"
        sistema.backend -> sistema.dbSandwiches "Lee y escribe datos del menú" "Acceso a datos"

        // --- RELACIONES INTERNAS C3 ---
        sistema.apiGateway.httpEntry -> sistema.apiGateway.identityFilter "Solicita comprobación de acceso"
        sistema.apiGateway.identityFilter -> sistema.apiGateway.routeDispatcher "Permite la petición autorizada"
        sistema.apiGateway.routeDispatcher -> sistema.apiGateway.errorMapper "Reporta fallos de conexión (502 Bad Gateway)"
        sistema.backend.securityFilter -> sistema.backend.backendApi "Permite el paso si el secreto es correcto"
    }

    views {
        systemContext sistema "C1_Contexto" "Contexto general del sistema Bocato." {
            title "C1 - Contexto del Sistema Bocato"
            include *
            autoLayout lr
        }

        container sistema "C2_Contenedores" "Arquitectura de contenedores y seguridad de Bocato." {
            title "C2 - Contenedores del Sistema Bocato"
            include *
            autoLayout lr
        }

        component sistema.apiGateway "C3_API_Gateway" "Componentes internos del API Gateway." {
            title "C3 - API Gateway (Interno)"
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background #56718A
                color #FFFFFF
            }
            element "Software System" {
                shape roundedbox
                background #0C527A
                color #FFFFFF
            }
            element "SistemaEvaluado" {
                background #173B5D
                color #FFFFFF
            }
            element "Container" {
                shape roundedbox
                background #E3ECF5
                color #173B5D
            }
            element "Frontend" {
                shape webbrowser
                background #CDE5F7
                color #153E5B
            }
            element "Gateway" {
                background #2B6289
                color #FFFFFF
            }
            element "Seguridad" {
                background #3F6171
                color #FFFFFF
            }
            element "Privado" {
                background #D5E8EF
                color #173B5D
            }
            element "BaseDatos" {
                shape cylinder
                background #E5EAF0
                color #243F56
            }
            element "Component" {
                shape roundedbox
                background #EDF3F7
                color #173B5D
            }
            element "EntradaC3" {
                background #D3E9F7
                color #153F62
            }
            element "ControlC3" {
                background #DBE4EC
                color #213F56
            }
            element "AplicacionC3" {
                background #D7E9DE
                color #20533E
            }
            element "ErrorC3" {
                background #F2E6DB
                color #70462C
            }
        }
    }
}
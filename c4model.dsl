workspace "Bocato" "Plataforma de Sánguches Italianos - Modelo C4" {

    !identifiers hierarchical

    model {
        // 1. Actores (Contexto Bocato)
        visitante = person "Visitante" "Consulta el catálogo público de sánguches y promociones."
        cliente = person "Cliente Autenticado" "Inicia sesión, realiza pedidos de sánguches y revisa sus órdenes."
        operador = person "Administrador" "Gestiona el catálogo, inventario y operaciones de Bocato."

        // 2. Sistema principal
        sistema = softwareSystem "Bocato System" "Sistema integral de venta y gestión de sánguches." {
            tags "SistemaEvaluado"

            frontend = container "Frontend Responsivo" "Interfaz de usuario web (HTML, CSS, JS)." "React / SPA" {
                tags "Frontend"
            }

            apiGateway = container "API Gateway" "Punto de entrada HTTP. Valida tokens y enruta tráfico." "FastAPI (:8000)" {
                tags "Gateway"
                httpAdapter = component "Adaptador HTTP" "Recibe peticiones HTTP del frontend, maneja CORS." { tags "EntradaC3" }
                accessFilter = component "Filtro de acceso" "Valida los Bearer Tokens de seguridad." { tags "ControlC3" }
                router = component "Despachador de rutas" "Enruta solicitudes a los microservicios." { tags "AplicacionC3" }
                errorHandler = component "Manejador de errores" "Captura excepciones (502, 401, 403)." { tags "ErrorC3" }
            }

            authService = container "Auth Service" "Gestión de identidad, sesiones y emisión de tokens." "FastAPI (:8100)" {
                tags "Seguridad"
                identityApi = component "API de identidad" "Endpoints de login y registro." { tags "EntradaC3" }
                credVerifier = component "Verificador de credenciales" "Valida usuarios y contraseñas." { tags "ControlC3" }
                sessionMgr = component "Gestor de sesiones" "Administra y emite tokens JWT." { tags "AplicacionC3" }
            }

            secretManager = container "HashiCorp Vault" "Almacena secretos compartidos y contraseñas." "Vault (:8200)" {
                tags "Seguridad"
            }

            // Servicios privados requeridos por el profe
            inventory = container "Inventory Service" "Gestión del catálogo de sánguches e ingredientes." "Microservicio FastAPI"
            orders = container "Orders Service" "Gestión de órdenes de compra de los clientes." "Microservicio FastAPI"
            clients = container "Clients Service" "Gestión de perfiles de clientes de Bocato." "Microservicio FastAPI"
            payments = container "Payments Service" "Procesamiento de pagos de los pedidos." "Microservicio FastAPI"

            // Bases de datos individuales
            dbInventory = container "dbInventory" "Base de datos del menú." "Database" { tags "BaseDatos" }
            dbOrders = container "dbOrders" "Base de datos de pedidos." "Database" { tags "BaseDatos" }
            dbClients = container "dbClients" "Base de datos de clientes." "Database" { tags "BaseDatos" }
            dbPayments = container "dbPayments" "Base de datos de pagos." "Database" { tags "BaseDatos" }
            dbIdentity = container "dbIdentity" "Base de datos de usuarios." "Database" { tags "BaseDatos" }

            graphqlGateway = container "GraphQL Gateway" "Punto de entrada para consultas unificadas del menú y pedidos." "GraphQL" {
                tags "Gateway"
                gqlEndpoint = component "Endpoint GraphQL" "Atiende consultas GraphQL entrantes." { tags "EntradaC3" }
                queryValidator = component "Validador de consultas" "Valida sintaxis de la consulta." { tags "ControlC3" }
                fieldPolicy = component "Política de acceso" "Aplica reglas de autorización por campo." { tags "ControlC3" }
                resolvers = component "Resolvers de negocio" "Resuelve y arma los datos de sánguches." { tags "AplicacionC3" }
                connectors = component "Conectores de subsistemas" "Se comunica con los servicios privados." { tags "AplicacionC3" }
            }
        }

        // --- RELACIONES ---

        // Actores hacia el frontend
        visitante -> sistema.frontend "Consulta menú de sánguches" "HTTPS"
        cliente -> sistema.frontend "Compra y revisa pedidos" "HTTPS"
        operador -> sistema.frontend "Administra plataforma" "HTTPS"

        // Frontend hacia los Gateways
        sistema.frontend -> sistema.apiGateway "Solicita datos estándar vía REST" "HTTPS/JSON"
        sistema.frontend -> sistema.graphqlGateway "Solicita datos complejos agregados" "GraphQL"

        // Gateway hacia Auth Service
        sistema.apiGateway.accessFilter -> sistema.authService.identityApi "Valida token de sesión" "HTTPS/REST"

        // Seguridad y secretos
        sistema.apiGateway -> sistema.secretManager "Obtiene certificados y llaves" "HTTPS"
        sistema.authService -> sistema.secretManager "Firma tokens de seguridad" "HTTPS"
        sistema.inventory -> sistema.secretManager "Lee credenciales de BD" "HTTPS"
        sistema.orders -> sistema.secretManager "Lee credenciales de BD" "HTTPS"
        sistema.clients -> sistema.secretManager "Lee credenciales de BD" "HTTPS"
        sistema.payments -> sistema.secretManager "Lee credenciales de BD" "HTTPS"

        // Enrutamiento del Gateway a microservicios
        sistema.apiGateway.router -> sistema.inventory "Enruta peticiones de menú" "HTTPS"
        sistema.apiGateway.router -> sistema.orders "Enruta peticiones de pedidos" "HTTPS"
        sistema.apiGateway.router -> sistema.clients "Enruta peticiones de cliente" "HTTPS"
        sistema.apiGateway.router -> sistema.payments "Enruta peticiones de pago" "HTTPS"

        // Relaciones entre servicios privados
        sistema.orders -> sistema.inventory "Reserva stock de ingredientes" "gRPC/REST"
        sistema.orders -> sistema.clients "Valida estado del cliente" "gRPC/REST"
        sistema.orders -> sistema.payments "Genera cobro del pedido" "gRPC/REST"

        // Persistencia
        sistema.inventory -> sistema.dbInventory "Lee y escribe menú" "TCP"
        sistema.orders -> sistema.dbOrders "Lee y escribe órdenes" "TCP"
        sistema.clients -> sistema.dbClients "Lee y escribe perfiles" "TCP"
        sistema.payments -> sistema.dbPayments "Lee y escribe transacciones" "TCP"
        sistema.authService.sessionMgr -> sistema.dbIdentity "Lee y escribe credenciales" "TCP"

        // GraphQL relaciones
        sistema.graphqlGateway.connectors -> sistema.inventory "Consulta datos de sánguches" "HTTPS"
        sistema.graphqlGateway.connectors -> sistema.orders "Consulta historial de pedidos" "HTTPS"
        sistema.graphqlGateway.connectors -> sistema.clients "Consulta perfil de usuario" "HTTPS"

        // --- Relaciones Internas de Componentes C3 ---

        // API Gateway C3
        sistema.apiGateway.httpAdapter -> sistema.apiGateway.accessFilter "Pasa la petición HTTP"
        sistema.apiGateway.accessFilter -> sistema.apiGateway.router "Permite el paso si es válido"
        sistema.apiGateway.router -> sistema.apiGateway.errorHandler "Reporta fallo de conexión"

        // Auth Service C3
        sistema.authService.identityApi -> sistema.authService.credVerifier "Entrega datos de login"
        sistema.authService.credVerifier -> sistema.authService.sessionMgr "Confirma identidad válida"

        // GraphQL Gateway C3
        sistema.graphqlGateway.gqlEndpoint -> sistema.graphqlGateway.queryValidator "Pasa la consulta"
        sistema.graphqlGateway.queryValidator -> sistema.graphqlGateway.fieldPolicy "Consulta reglas"
        sistema.graphqlGateway.fieldPolicy -> sistema.graphqlGateway.resolvers "Autoriza ejecución"
        sistema.graphqlGateway.resolvers -> sistema.graphqlGateway.connectors "Ejecuta resolución de datos"
    }

    views {
        systemContext sistema "C1_Contexto" "Contexto general del sistema Bocato." {
            title "C1 - Contexto del Sistema Bocato"
            include *
            autoLayout lr
        }

        container sistema "C2_Contenedores" "Arquitectura completa de contenedores de Bocato." {
            title "C2 - Contenedores Bocato"
            include *
            autoLayout lr
        }

        component sistema.apiGateway "C3_API_Gateway" "Componentes internos del API Gateway." {
            title "C3 - Componentes API Gateway"
            include *
            autoLayout lr
        }

        component sistema.authService "C3_Auth_Service" "Componentes internos del servicio de Auth." {
            title "C3 - Componentes Auth Service"
            include *
            autoLayout lr
        }

        component sistema.graphqlGateway "C3_GraphQL_Gateway" "Componentes internos del Gateway GraphQL." {
            title "C3 - Componentes GraphQL Gateway"
            include *
            autoLayout lr
        }

        container sistema "C2_Catalogo" "Recorrido de Catálogo." {
            title "C2 - Vista filtrada: Recorrido de Catálogo"
            include visitante frontend apiGateway graphqlGateway inventory dbInventory
            autoLayout lr
        }

        container sistema "C2_Pedidos" "Recorrido de Pedidos." {
            title "C2 - Vista filtrada: Recorrido de Pedidos"
            include cliente frontend apiGateway orders dbOrders clients dbClients payments dbPayments
            autoLayout lr
        }

        styles {
            element "Person" { shape person; background #56718A; color #FFFFFF }
            element "Software System" { shape roundedbox; background #0C527A; color #FFFFFF }
            element "SistemaEvaluado" { background #173B5D; color #FFFFFF }
            element "Container" { shape roundedbox; background #E3ECF5; color #173B5D }
            element "Frontend" { shape webbrowser; background #CDE5F7; color #153E5B }
            element "Gateway" { background #2B6289; color #FFFFFF }
            element "Seguridad" { background #3F6171; color #FFFFFF }
            element "BaseDatos" { shape cylinder; background #E5EAF0; color #243F56 }
            element "Component" { shape roundedbox; background #EDF3F7; color #173B5D }
            element "EntradaC3" { background #D3E9F7; color #153F62 }
            element "ControlC3" { background #DBE4EC; color #213F56 }
            element "AplicacionC3" { background #D7E9DE; color #20533E }
            element "ErrorC3" { background #F2E6DB; color #70462C }
        }
    }
}

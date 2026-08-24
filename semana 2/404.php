<?php 
$page_title = "Página no encontrada"; 
include 'includes/header.php'; 
?>

<div class="container-fluid bg-warning py-4">
    <div class="row">
        <div class="col-12 text-center">
            <h2>Error 404</h2>
        </div>
    </div>
</div>

<div class="container py-5 text-center">
    <i class="fa fa-exclamation-triangle fa-5x text-warning mb-4"></i>
    <h3 class="mb-3">¡Opps! La página que buscas no existe.</h3>
    <p class="text-muted mb-4">Es posible que la dirección esté mal escrita o que la página se haya movido.</p>
    <a href="index.php" class="btn btn-primary btn-lg">Volver al Inicio</a>
</div>

<?php include 'includes/footer.php'; ?>
<?php $page_title = "Servicios"; include 'includes/header.php'; ?>

    <div class="container-fluid bg-warning py-4">
        <div class="row">
            <div class="col-12 text-center">
                <h2>Servicios del Taller</h2>
            </div>
        </div>
    </div>

    <div class="container-fluid py-5">
        <div class="row">
            <div class="col-md-3 mb-4">
                <div class="card h-100 text-center">
                    <div class="card-body">
                        <i class="fa fa-tint fa-3x mb-3"></i>
                        <h5 class="card-title">Cambio de Aceite</h5>
                        <p class="card-text">Cambio de aceite y filtro con productos de calidad.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card h-100 text-center">
                    <div class="card-body">
                        <i class="fa fa-circle-o fa-3x mb-3"></i>
                        <h5 class="card-title">Frenos</h5>
                        <p class="card-text">Revisión y cambio de pastillas, discos y líquido de frenos.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card h-100 text-center">
                    <div class="card-body">
                        <i class="fa fa-cogs fa-3x mb-3"></i>
                        <h5 class="card-title">Mantención General</h5>
                        <p class="card-text">Revisión completa según kilometraje del fabricante.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card h-100 text-center">
                    <div class="card-body">
                        <i class="fa fa-stethoscope fa-3x mb-3"></i>
                        <h5 class="card-title">Diagnóstico</h5>
                        <p class="card-text">Escaneo computarizado para detectar fallas del motor.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?php
// Ejemplo de uso de DOMDocument para generar un aviso dinámico en servidor
$dom = new DOMDocument();
$alertDiv = $dom->createElement('div', '¡Consulta por nuestras promociones de temporada en taller!');
$alertDiv->setAttribute('class', 'alert alert-info text-center my-3');
$dom->appendChild($alertDiv);
?>

<div class="container">
    <?php echo $dom->saveHTML(); ?>
</div>
<?php include 'includes/footer.php'; ?>

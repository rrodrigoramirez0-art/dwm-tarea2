<?php
$page_title = "Contacto";
include 'includes/header.php';

// Procesamiento simple del formulario (se ejecuta al enviar el POST)
$mensaje_enviado = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
    $comentario = filter_input(INPUT_POST, 'comment', FILTER_SANITIZE_SPECIAL_CHARS);
    // Aquí normalmente se enviaría un correo o se guardaría en base de datos.
    $mensaje_enviado = true;
}
?>

    <div class="container-fluid bg-warning py-4">
        <div class="row">
            <div class="col-12 text-center">
                <h2>Contacto</h2>
            </div>
        </div>
    </div>

    <div class="container-fluid py-5">
        <div class="row justify-content-center">
            <div class="col-md-6">

                <?php if ($mensaje_enviado): ?>
                    <div class="alert alert-success">¡Gracias! Recibimos tu mensaje, te contactaremos pronto.</div>
                <?php endif; ?>

                <form action="contacto.php" method="post">
                    <div class="mb-3 mt-2">
                        <label for="email" class="form-label">Email:</label>
                        <input type="email" class="form-control" id="email" name="email" placeholder="Ingresa tu email" required>
                    </div>
                    <div class="mb-3">
                        <label for="comment" class="form-label">Comentarios:</label>
                        <textarea class="form-control" rows="5" id="comment" name="comment" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary mt-1">Enviar</button>
                </form>
            </div>
        </div>
    </div>

<?php include 'includes/footer.php'; ?>

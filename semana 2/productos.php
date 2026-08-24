<?php $page_title = "Autos"; include 'includes/header.php'; ?>

    <div class="container-fluid bg-warning py-4">
        <div class="row">
            <div class="col-12 text-center">
                <h2>Autos Disponibles</h2>
            </div>
        </div>
    </div>

    <!-- Carousel -->
    <div id="carouselAutos" class="carousel slide" data-bs-ride="carousel">
        <div class="carousel-indicators">
            <button type="button" data-bs-target="#carouselAutos" data-bs-slide-to="0" class="active"></button>
            <button type="button" data-bs-target="#carouselAutos" data-bs-slide-to="1"></button>
            <button type="button" data-bs-target="#carouselAutos" data-bs-slide-to="2"></button>
        </div>
        <div class="carousel-inner">
            <div class="carousel-item active">
                <img src="https://picsum.photos/seed/auto1/1200/450" class="d-block w-100" alt="Auto 1">
            </div>
            <div class="carousel-item">
                <img src="https://picsum.photos/seed/auto2/1200/450" class="d-block w-100" alt="Auto 2">
            </div>
            <div class="carousel-item">
                <img src="https://picsum.photos/seed/auto3/1200/450" class="d-block w-100" alt="Auto 3">
            </div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#carouselAutos" data-bs-slide="prev">
            <span class="carousel-control-prev-icon"></span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#carouselAutos" data-bs-slide="next">
            <span class="carousel-control-next-icon"></span>
        </button>
    </div>
    <!-- Fin Carousel -->

    <!-- Cards de autos -->
    <div class="container-fluid py-5">
        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="card h-100">
                    <img src="https://picsum.photos/seed/carA/400/250" class="card-img-top" alt="Auto A">
                    <div class="card-body">
                        <h5 class="card-title">Chevrolet Sail 2022</h5>
                        <p class="card-text">45.000 km · Automático · Full equipo</p>
                        <p class="fw-bold">$8.990.000</p>
                        <a href="contacto.php" class="btn btn-primary">Consultar</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card h-100">
                    <img src="https://picsum.photos/seed/carB/400/250" class="card-img-top" alt="Auto B">
                    <div class="card-body">
                        <h5 class="card-title">Suzuki Swift 2021</h5>
                        <p class="card-text">38.000 km · Mecánico · Único dueño</p>
                        <p class="fw-bold">$7.490.000</p>
                        <a href="contacto.php" class="btn btn-primary">Consultar</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-4">
                <div class="card h-100">
                    <img src="https://picsum.photos/seed/carC/400/250" class="card-img-top" alt="Auto C">
                    <div class="card-body">
                        <h5 class="card-title">Hyundai Tucson 2023</h5>
                        <p class="card-text">20.000 km · Automático · 4x2</p>
                        <p class="fw-bold">$16.990.000</p>
                        <a href="contacto.php" class="btn btn-primary">Consultar</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

<?php include 'includes/footer.php'; ?>

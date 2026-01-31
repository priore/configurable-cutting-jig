// ==========================================
// IKEA LAKE LEG CUTTING TEMPLATE
// ==========================================
$fn = 64;
/* [Main Dimensions] */
// Width in mm
gamba_dim = 50.7; // [10:0.1:100]  
// Total length of the jig
lunghezza = 160; // [80:1:250]
// Thickness
wall = 10; // [2:0.5:20]
// Gauge width
extra_top = 5; // [4:1:10]
/* [Cutting Parameters] */
// Blade thickness
spessore_lama = 1.2; // [0.5:0.1:3]
// 45° cut
taglio_45 = true;
// 90° cut
taglio_90 = true;
/* Extra options */
// Inspection windows
finestre=false;
// Mounting holes
fori_fissaggio=true;


/* [Hidden] */
altezza_int = gamba_dim + 6;
SX = gamba_dim + 2*wall;
SZ = wall + altezza_int + 2;
smusso = 2; 

difference() {
    // 1. CORPO PRINCIPALE
    union() {
        // Corpo con bordi verticali smussati
        hull() {
            translate([smusso, 0, 0]) cube([SX-smusso*2, lunghezza, SZ]);
            translate([0, smusso, 0]) cube([SX, lunghezza-smusso*2, SZ]);
        }
        
        // Alette base smussate
        hull() {
            translate([-12+smusso, smusso, 0]) cube([SX+24-smusso*2, lunghezza-smusso*2, wall]);
            translate([-12, 5, 0]) cube([SX+24, lunghezza-10, wall]);
        }
        
        // LATO SINISTRO:
        translate([-extra_top, 0, SZ-extra_top])
            cube([extra_top + wall, lunghezza, extra_top]);
            
        // RINFORZO LEVIGATO
        translate([0, 0, SZ-extra_top])
        hull() {
            translate([-extra_top, 0, 0]) cube([extra_top, lunghezza, 0.1]);
            translate([-1, 0, -wall/2]) cube([1, lunghezza, 0.1]);
            translate([0, 0, -wall]) cube([0.1, lunghezza, 0.1]);
        }

        // --- AGGIUNTA RIGHELLO IN RILIEVO ---
        for (i = [0 : 10 : lunghezza/2 - 5]) {
            pos_cm = i / 10;
            // Numeri e tacche
            rilievo(lunghezza/2 + i, str(pos_cm));
            if (i != 0) rilievo(lunghezza/2 - i, str(pos_cm));
            
            if (i < lunghezza/2 - 5) {
                tacca_5mm(lunghezza/2 + i + 5);
                tacca_5mm(lunghezza/2 - i - 5);
            }
        }
    }

    // 2. Canale a "U" passante
    translate([wall, -1, wall])
        cube([gamba_dim, lunghezza + 2, altezza_int + 20]);

    // 3. TAGLI DI SICUREZZA
    if (taglio_90) {
        taglio(lunghezza/2, 0);
    }
    if (taglio_45) {
        taglio(lunghezza/2, 45);
    }

    // 4. FINESTRE DI ISPEZIONE
    if (finestre) {
        for (y = [18, lunghezza-38]) {
            translate([SX/2, y + 10, wall + 18])
            rotate([0, 90, 0])
            rotate([0, 0, 45]) 
                cube([22, 22, SX + 40], center=true); 
        }
    }

    // 5. FORI SVASATI
    if (fori_fissaggio) {
        for(x = [-6, SX + 6], y = [15, lunghezza - 15]) {
            translate([x, y, -1]) {
                cylinder(d = 4.5, h = wall + 2); 
                translate([0, 0, wall - 2]) cylinder(d1 = 4.5, d2 = 9, h = 3); 
            }
        }
}

    // 6. SMUSSI FINALI
    for(y = [0, lunghezza]) {
        translate([-extra_top, y, SZ-extra_top/2])
            rotate([0, 0, 45])
                cube([smusso*2, smusso*2, extra_top+10], center=true);
        translate([SX, y, SZ/2])
            rotate([0, 0, 45])
                cube([smusso*2, smusso*2, SZ+10], center=true);
    }
}

// Modulo per Numeri in Rilievo
module rilievo(y_pos, testo) {
    // Numero alzato di 0.8mm sopra la superficie SZ
    translate([-extra_top + 1.2, y_pos - 2, SZ])
        linear_extrude(height = 0.8)
            text(testo, size = 3.5, font = "Arial:style=Bold");
    // Tacca lunga alzata di 0.8mm
    translate([0, y_pos, SZ]) 
        cube([wall, 1, 0.8]); 
}

// Modulo per Tacca 5mm in Rilievo
module tacca_5mm(y_pos) {
    translate([wall-3, y_pos, SZ]) 
        cube([3, 0.7, 0.8]);
}

// Modulo Taglio
module taglio(y_pos, ang) {
    translate([SX/2, y_pos, SZ/2 + wall + 7]) 
    rotate([0, 0, ang]) {
        cube([SX * 4, spessore_lama, SZ + 20], center=true);
        translate([0, 0, SZ/2 - (wall + 4.5)]) 
            rotate([45, 0, 0])
                cube([SX * 4, spessore_lama * 5, spessore_lama * 5], center=true);
    }
}
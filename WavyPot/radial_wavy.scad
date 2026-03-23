// Figure out how to "close the figure" at the bottom.

// --- Base parameters ---
R = 10.0;
n0 = 4;       // initial number of teeth
A0 = 0.4;     // initial amplitude
k0 = 1.22;     // initial exponent

NUM_THETA_INCS = 1000;
TOTAL_ROTATION = 360*n0;
DTHETA_DEG = TOTAL_ROTATION / NUM_THETA_INCS;


function radius_shifted_power(k, A, theta_deg) =
    // Now compute the radius of the hemisphere
    // parametrized by the height A.
    // r = sqrt(R^2-RL-A)^2) by the Pythagorean Theorem.
    let(r = sqrt(2*R*A - pow(A,2)),
        c = cos(theta_deg),
        u = (c + 1.0) / 2.0,        // [0, 1]
        Ap = 1.0 - u,
        s = 2.0 * (pow(u,k) - 1.0))    // [-1, 1]
        r + s * (R - r);

points = [
    for(dtheta_deg = [0 : DTHETA_DEG : TOTAL_ROTATION ])
        let (
            r = radius_shifted_power(k0,A0,dtheta_deg),
            x = r*cos(dtheta_deg),
            y = r*sin(dtheta_deg))
        [x,y]
];


for (p = points)
    translate(p)
        circle(r=0.1);

// polygon(points);



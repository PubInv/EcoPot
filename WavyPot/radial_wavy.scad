// Figure out how to "close the figure" at the bottom.

// --- Base parameters ---
R = 10.0;
n0 = 6;       // initial number of teeth
A0 = 10;     // initial amplitude
k0 = 1.22;     // initial exponent

NUM_THETA_INCS = 500;
A_RADIUS_INCS = 100;
D_A_MM = A0 / A_RADIUS_INCS;
TOTAL_ROTATION = 360;
DTHETA_DEG = TOTAL_ROTATION / NUM_THETA_INCS;



function radius_shifted_power(k, A, n, theta_deg) =
    // Now compute the radius of the hemisphere
    // parametrized by the height A.
    // r = sqrt(R^2-RL-A)^2) by the Pythagorean Theorem.
    let(r = sqrt(pow(R,2) - pow(A,2)),
        c = cos(theta_deg*n),
        u = (c + 1.0) / 2.0,        // convert cosine to [0, 1]
        // convert to [-1, 1] to wiggle around the radius...
        // raising to a power here gives us some softness...
        s = 2.0 * pow(u,k) - 1.0)    
        max(0,r + s * (R - r));

for(a_mm = [0 : D_A_MM : R ])
    let( points = [
        for(dtheta_deg = [0 : DTHETA_DEG : TOTAL_ROTATION ])
            let (
            r = radius_shifted_power( k0,a_mm,n0,dtheta_deg),
            x = r*cos(dtheta_deg),
            y = r*sin(dtheta_deg))
            [x,y,a_mm]
    ])
for (p = points)
    translate(p)
        circle(r=0.1);

// polygon(points);



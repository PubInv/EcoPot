
"""
Vertical-meridian CadQuery version of a spherical-coordinate wavy hemispherical shell.

This differs from the horizontal-ring loft approach:

- Instead of fixing theta and drawing closed latitude rings,
  this fixes phi and draws open meridian splines from theta=0 to theta=pi/2.

- Adjacent meridians are joined with ruled faces.

- The outer surface, inner surface, and rim band are assembled into a shell,
  then converted to a solid and exported as STEP.

Why this helps:
- theta=0 is the pole, where latitude rings collapse and can create a small
  missing/ill-conditioned cap.
- Meridian curves are naturally well-defined from theta=0 to theta=pi/2.
- Every vertical slice includes the pole and rim.

Requires:
    pip install cadquery

Run:
    python wavy_pot_vertical_meridians.py
"""

import cadquery as cq
import math


# ----------------------------
# Parameters
# ----------------------------

inner_radius = 50.0
wall_thickness = 2.0

theta_count = 32   # samples from pole to rim along each meridian
phi_count = 96     # meridians around circumference

WAVY_LOBE = 6
WAVY_AMPLITUDE_FACTOR = 0.2
g = 3.0

output_file = "wavy_pot_vertical_meridians.step"


# ----------------------------
# Spherical coordinate helpers
# ----------------------------

def sph(theta, phi, radius):
    """
    theta: polar angle, 0 at +Z pole, pi/2 at equator/rim
    phi: azimuth around Z axis
    radius: rho(theta, phi)
    """
    x = radius * math.sin(theta) * math.cos(phi)
    y = radius * math.sin(theta) * math.sin(phi)
    z = radius * math.cos(theta)
    return (x, y, z)


def wavy_norm(theta, phi, n=WAVY_LOBE):
    return (
        1.0
        + WAVY_AMPLITUDE_FACTOR
        * math.cos(n * phi)
        * (math.sin(2.0 * theta) ** g)
    )


def rho_inner(theta, phi):
    return inner_radius * wavy_norm(theta, phi)


def rho_outer(theta, phi):
    # This is radial thickness, not true surface-normal thickness.
    # For your current model this matches the simple spherical-coordinate shell idea.
    return rho_inner(theta, phi) + wall_thickness


def point_inner(theta, phi):
    return sph(theta, phi, rho_inner(theta, phi))


def point_outer(theta, phi):
    return sph(theta, phi, rho_outer(theta, phi))


# ----------------------------
# Curve / edge builders
# ----------------------------

def meridian_points(phi, point_fn):
    """
    Returns points along a vertical meridian at fixed phi,
    from pole theta=0 to rim theta=pi/2.

    Unlike latitude rings, theta=0 is fine here:
    all meridians share the same pole point, but each curve itself is valid.
    """
    pts = []
    for i in range(theta_count + 1):
        theta = (math.pi / 2.0) * i / theta_count
        pts.append(point_fn(theta, phi))
    return pts


def make_spline_edge(points):
    """
    Make a CadQuery/OCC Edge from a 3D spline through the supplied points.
    """
    return cq.Edge.makeSpline([cq.Vector(*p) for p in points])


def make_line_edge(p0, p1):
    return cq.Edge.makeLine(cq.Vector(*p0), cq.Vector(*p1))


def make_ruled_face(edge_a, edge_b):
    """
    Create a ruled surface between two compatible edges.
    This is the central operation for the vertical-panel construction.
    """
    return cq.Face.makeRuledSurface(edge_a, edge_b)


# ----------------------------
# Surface construction
# ----------------------------

outer_edges = []
inner_edges = []

for j in range(phi_count):
    phi = 2.0 * math.pi * j / phi_count

    outer_edges.append(make_spline_edge(meridian_points(phi, point_outer)))
    inner_edges.append(make_spline_edge(meridian_points(phi, point_inner)))


faces = []

for j in range(phi_count):
    j_next = (j + 1) % phi_count

    phi0 = 2.0 * math.pi * j / phi_count
    phi1 = 2.0 * math.pi * j_next / phi_count

    # Outer vertical panel between adjacent meridians.
    faces.append(make_ruled_face(outer_edges[j], outer_edges[j_next]))

    # Inner vertical panel.
    #
    # Reverse the order of the edges to encourage inward-facing orientation.
    # If makeSolid complains about orientation, this is one of the first
    # things to experiment with.
    faces.append(make_ruled_face(inner_edges[j_next], inner_edges[j]))

    # Rim band at theta = pi/2 connecting inner and outer rim points.
    theta_rim = math.pi / 2.0

    outer_rim_0 = point_outer(theta_rim, phi0)
    outer_rim_1 = point_outer(theta_rim, phi1)
    inner_rim_0 = point_inner(theta_rim, phi0)
    inner_rim_1 = point_inner(theta_rim, phi1)

    rim_outer_edge = make_line_edge(outer_rim_0, outer_rim_1)
    rim_inner_edge = make_line_edge(inner_rim_0, inner_rim_1)

    faces.append(make_ruled_face(rim_outer_edge, rim_inner_edge))

# ----------------------------
# Trying to make handles...
# ----------------------------

def make_horizontal_torus_handles(
    sphere_radius=52.0,
    handle_major_radius=16.0,
    handle_tube_radius=3.0,
    z=9.0,
    embed=1.0,
    steps=96,
):
    """
    Two horizontal half-torus handles whose axes point in Z.

    sphere_radius:
        rho of the pot at the equator/rim-ish reference sphere.

    z:
        vertical height of handle center above sphere center.

    The function computes the local XY pot radius at this z.
    """

    # For a plain hemisphere.
    # For the wavy version, replace this with your rho_wavy(theta, phi)
    # evaluated at the attachment phi and theta.
    pot_xy_radius = math.sqrt(max(0.0, sphere_radius**2 - z**2))


import cadquery as cq
import math

def make_horizontal_torus_handles(
    sphere_radius=52.0,
    handle_major_radius=16.0,
    handle_tube_radius=3.0,
    z=9.0,
    embed=1.0,
    steps=96,
):
    pot_xy_radius = math.sqrt(max(0.0, sphere_radius**2 - z**2))

    def one_handle(side):
        cx = side * (pot_xy_radius + handle_major_radius - embed)

        pts = []

        curve_adjust = 10;

        if side > 0:
            a0, a1 = 2 * math.pi * (-curve_adjust + 90) / 360, 2  * math.pi * (curve_adjust+270) / 360
        else:
            a0, a1 = -2 * math.pi * (curve_adjust + 90) / 360 ,2  * math.pi * (curve_adjust+90) / 360

        for i in range(steps + 1):
            a = a0 + (a1 - a0) * i / steps
            x = handle_major_radius * math.cos(a)
            y = handle_major_radius * math.sin(a)
            pts.append((x, y, 0.0))

        path = cq.Workplane("XY").spline(pts)

        p0 = pts[0]

        profile = (
            cq.Workplane("YZ")
            .center(p0[1], p0[2])
            .circle(handle_tube_radius)
        )

        handle_local = profile.sweep(path, makeSolid=True, isFrenet=True)

#        return handle_local.translate((cx, 0, z))
        fudge = 0
        return handle_local.translate(((pot_xy_radius -fudge )*(-side), 0, z))

    return one_handle(1).union(one_handle(-1))

# ----------------------------
# Sew faces into a shell / solid
# ----------------------------

shell = cq.Shell.makeShell(faces)
solid = cq.Solid.makeSolid(shell)

pot = cq.Workplane("XY").add(solid)

handles = make_horizontal_torus_handles(
    sphere_radius=52.0,
    handle_major_radius=16.0,
    handle_tube_radius=3.0,
    z=9.0,
    embed=1.5,
)

result = pot.union(handles)

try:
    result = result.clean()
except Exception:
    pass

cq.exporters.export(result, output_file)

print(f"Exported {output_file}")

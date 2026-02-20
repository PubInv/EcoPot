import numpy as np
import math
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

# TBD: add a second harmonic when there is room.
# Figure out how to "close the figure" at the bottom.

# --- Base parameters ---
R = 2.0
n0 = 24        # initial number of teeth
A0 = 0.4      # initial amplitude
k0 = 0.5      # initial exponent

theta = np.linspace(0, 2*np.pi, 2500)

def radius_shifted_power(k, A, n):
    """
    """
    # Now compute the radius of the hemisphere
    # parametrized by the height A.
    # r = sqrt(R^2-RL-A)^2) by the Pythagorean Theorem.
    r = math.sqrt(2*R*A - A**2)
    c = np.cos(n * theta)
    u = (c + 1.0) / 2.0          # [0, 1]
    Ap = 1.0 - u
    s = 2.0 * (u ** k) - 1.0     # [-1, 1]
    return  r + s * (R - r)

# --- Figure and polar axis ---
fig = plt.figure(figsize=(6.5, 6.5))
ax = plt.subplot(111, projection='polar')
plt.subplots_adjust(bottom=0.30)

r0 = radius_shifted_power(k0, A0, n0)
(line,) = ax.plot(theta, r0, lw=2)

def update_title(k, A, n):
    ax.set_title(f"R={R},  A={A:.2f},  n={n},  k={k:.2f}")

update_title(k0, A0, n0)

# --- Sliders ---
ax_k = plt.axes([0.25, 0.18, 0.5, 0.03])
ax_A = plt.axes([0.25, 0.13, 0.5, 0.03])
ax_n = plt.axes([0.25, 0.08, 0.5, 0.03])

k_slider = Slider(ax_k, 'k', 0.05, 5.0, valinit=k0)
A_slider = Slider(ax_A, 'A', 0.0, R, valinit=A0)
n_slider = Slider(ax_n, 'n (teeth)', 3, 20, valinit=n0, valstep=1)

def update(val):
    k = float(k_slider.val)
    A = float(A_slider.val)
    n = int(n_slider.val)   # enforce integer teeth

    r = radius_shifted_power(k, A, n)
    line.set_ydata(r)
    update_title(k, A, n)
    fig.canvas.draw_idle()

k_slider.on_changed(update)
A_slider.on_changed(update)
n_slider.on_changed(update)

plt.show()

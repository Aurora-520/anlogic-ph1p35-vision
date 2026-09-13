# Overlay Layer

`logo_overlay.v` is an always-on display compositor. It uses the official Lab3
`anlogic_logo_rom.v` asset and sits after pixel algorithms, so the logo remains
visible in color, binary, grayscale, and Sobel modes. The current placement is
the active-frame origin, 160x160 pixels, matching Lab3.

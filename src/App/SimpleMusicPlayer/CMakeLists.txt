
configure_file(Style.h.in Style.h)

Dx_AddTarget(MODE "EXE" QT ON LIBS "Qt6::Widgets"  EXTERNAL miniaudio)


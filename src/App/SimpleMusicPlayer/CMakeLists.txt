
configure_file(Style.h.in Style.h)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/Style.h"
        DESTINATION config)

Dx_AddTarget(MODE "EXE" QT ON LIBS "Qt6::Widgets"  EXTERNAL miniaudio)


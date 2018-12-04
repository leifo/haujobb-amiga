TEMPLATE = app

TARGET = hellodemo

QT += core
QT += gui
QT += opengl
QT += network

CONFIG += console

OBJECTS_DIR=.obj
MOC_DIR=.moc

win32 {
   DEFINES += _USE_MATH_DEFINES=1
   DEFINES += _CRT_SECURE_NO_WARNINGS=1
   MAKEFILE = Makefile
}
# DEFINES += SYNC_PLAYER

INCLUDEPATH += ../shared
INCLUDEPATH += src

INCLUDEPATH += $$(QTDIR)/include/QtCore
INCLUDEPATH += $$(QTDIR)/include/QtGui
INCLUDEPATH += $$(QTDIR)/include/QtOpenGL

INCLUDEPATH += ../shared/libs/bass24/c
INCLUDEPATH += ../../libs/SDL-1.2.7/include

LIBS += -lopengl32

#QMAKE_LFLAGS_DEBUG += /NODEFAULTLIB:msvcrtd.lib
#QMAKE_LFLAGS_RELEASE += /NODEFAULTLIB:msvcrt.lib

#LIBS += -lbass
LIBS += ../shared/libs/bass24/c/bass.lib
#LIBS += ../../libs/SDL-1.2.7/lib/SDL.lib
#LIBS += glu32.lib
#LIBS += -L$${PWD}/../shared/rocket/lib
#LIBS += -llibrocketd
LIBS += -lws2_32


INCLUDEPATH += ../shared

INCLUDEPATH += $$(QTDIR)/include/QtCore
INCLUDEPATH += $$(QTDIR)/include/QtGui
INCLUDEPATH += $$(QTDIR)/include/QtOpenGL

OTHER_FILES += \
  build/makefile


# main demo -------------------------------------------------------------------
HEADERS += \
    src/stars/starseffect.h \
    src/movetable/movetableeffect.h \
    src/pictures/pictureeffect.h

SOURCES += \
    src/main.c \
    src/stars/starseffect.c \
    src/main.c \
    src/movetable/movetableeffect.c \
    src/pictures/pictureeffect.c

# common ----------------------------------------------------------------------
HEADERS += \
    ../shared/common/vertex.h \

SOURCES += \


# shared ----------------------------------------------------------------------
HEADERS += \
    ../shared/wos/wos.h \
    ../shared/tools/malloc.h \
    ../shared/tools/mem32.h \
    ../shared/tools/stream.h \
    ../shared/tools/cachesim.h \
    ../shared/tools/rand.h \
    ../shared/profile/profile.h \
    ../shared/image/tga.h \
    ../shared/image/gif.h \
    ../shared/image/image.h \
    ../shared/math/imath.h \
    ../shared/math/vector.h \
    ../shared/sound/adpcm.h \

SOURCES += \
    ../shared/wos/wos.cpp \
    ../shared/tools/malloc.c \
    ../shared/tools/mem32.c \
    ../shared/tools/stream.c \
    ../shared/tools/cachesim.c \
    ../shared/tools/rand.c \
    ../shared/profile/profile.c \
    ../shared/image/tga.c \
    ../shared/image/gif.c \
    ../shared/image/image.c \
    ../shared/math/imath.c \
    ../shared/math/vector.c \
    ../shared/sound/adpcm.c \

# rocket ----------------------------------------------------------------------
HEADERS += \
    ../shared/rocket/lib/device.h \
    ../shared/rocket/lib/track.h \
    ../shared/rocket/lib/sync.h

SOURCES += \
    ../shared/rocket/lib/device.c \
    ../shared/rocket/lib/track.c


DISTFILES += \
    build/makefile \
    src/assembly-bridge.s \
    src/AdpcmSource.s \
    src/PaulaOutput.s \
    build/makefile \
    src/assembly-bridge.s


TEMPLATE = app

TARGET = pictures

QT += core
QT += gui
QT += opengl
QT += network

OBJECTS_DIR=.obj
MOC_DIR=.moc

# precompiled headers
#CONFIG += precompile_header
#PRECOMPILED_HEADER = src/pch.h

# obj and pch to ramdisk
#OBJECTS_DIR=R:/obj
#MOC_DIR=R:/moc
#PRECOMPILED_DIR=R:\

win32 {
   DEFINES += _USE_MATH_DEFINES=1
   DEFINES += _CRT_SECURE_NO_WARNINGS=1
}

INCLUDEPATH += .
INCLUDEPATH += src
INCLUDEPATH += ../shared
INCLUDEPATH += ../shared/wos

INCLUDEPATH += $$(QTDIR)/include/QtCore
INCLUDEPATH += $$(QTDIR)/include/QtGui
INCLUDEPATH += $$(QTDIR)/include/QtNetwork
INCLUDEPATH += $$(QTDIR)/include/QtOpenGL

LIBS += -lopengl32

OTHER_FILES += \
    build/makefile

# source

HEADERS += \
    src/pictureeffect.h \

SOURCES += \
    src/main.c \
    src/pictureeffect.c \

# shared

HEADERS += \
    ../shared/wos/wos.h \
    ../shared/image/image.h \
    ../shared/image/gif.h \
    ../shared/tools/mem32.h \
    ../shared/math/imath.h \
    ../shared/tools/rand.h 


SOURCES += \
    ../shared/wos/wos.cpp \
    ../shared/tools/mem32.c \
    ../shared/image/gif.c \
    ../shared/tools/stream.c \
    ../shared/tools/rand.c 

DISTFILES += \
    build/makefile

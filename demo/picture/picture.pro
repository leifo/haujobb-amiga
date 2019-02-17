TEMPLATE = app

TARGET = picture

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

DEFINES += WOS_ON_PC=1

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

win32 {
   LIBS += -lopengl32
}

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
    ../shared/image/gif.h \
    ../shared/tools/mem32.h
    

SOURCES += \
    ../shared/wos/wos.cpp \
    ../shared/tools/mem32.c \
    ../shared/image/gif.c \
    ../shared/tools/stream.c

DISTFILES += \
    build/makefile

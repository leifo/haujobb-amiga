TEMPLATE = app
TARGET = test


# amiga make file
OTHER_FILES += \
    newestwos.s\
    wos_v1.63.s\
    wicked3.s\
    wicked2.s\
    wicked1.s\
    sub\wos_defines.i\
    sub\wos_copperlists_v1.6.s\
    sub\wos_hal_killer.s\
    sub\wos_hal_system.s\
    sub\wos_defines.i\
    sub\wos_incall.i\
    wos_macros.i\

DISTFILES += \
    sub/wos_macros.i \
    sub/makefile \
    wos_v1.63.s \
    buildwostest.bat

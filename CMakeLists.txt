cmake_minimum_required(VERSION 3.31.2)

project(Videoclips VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.9)

qt_add_executable(appVideoclips)

qt_add_qml_module(appVideoclips
    URI Videoclips
    VERSION 1.0
    SOURCES     main.cpp
    QML_FILES   Main.qml
    QML_FILES Actions.qml
    SOURCES videoplay.h videoplay.cpp
    QML_FILES Player.qml
    QML_FILES Contents.qml
    SOURCES videocutter.h videocutter.cpp
    QML_FILES control.js
    SOURCES videomusic.h videomusic.cpp
    QML_FILES Notification.qml
    SOURCES videopip.h videopip.cpp
    SOURCES videomerger.h videomerger.cpp
    SOURCES watermark.h watermark.cpp
    SOURCES
)

target_compile_features(appVideoclips PRIVATE cxx_std_23)

target_link_libraries(appVideoclips
    PRIVATE
        Qt6::Quick
)

set_target_properties(appVideoclips PROPERTIES
    AUTORCC true
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appVideoclips
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appVideoclips
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


















































# set(CMAKE_CXX_STANDARD_REQUIRED ON) # Globally preventing the fallback behaviour of C++ standard
#qt_add_executable(Videoclips)  //Creates and finalizes an application target of a platform-specific type.
#This command performs the following tasks:
#    1. Create a CMake target of the appropriate type for the target platform.
#    2. Link the target to the Qt::Core library.
#    3. Handle finalization of the CMake target.

# set(CMAKE_CXX_STANDARD_REQUIRED ON) # Globally preventing the fallback behaviour of C++ standard

# qt_standard_project_setup()  #set(CMAKE_AUTOUIC ON)  set(CMAKE_AUTOMOC ON)






# cmake_minimum_required(VERSION 3.16)
#
# project(Videoclips VERSION 0.1 LANGUAGES CXX)
#
# @if !true
# set(CMAKE_AUTOMOC ON)
# @endif
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
#
# find_package(Qt6 REQUIRED COMPONENTS Quick)
#
# @if true
# @if true
# qt_standard_project_setup(REQUIRES 6.9)
# @else
# qt_standard_project_setup()
# @endif
# @endif
#
# qt_add_executable(appVideoclips
#     main.cpp
# )
#
# qt_add_qml_module(appVideoclips
#     URI Videoclips
#     VERSION 1.0
#     QML_FILES
#         Main.qml
# )
#
# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(appVideoclips PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appVideoclips
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )
#
# target_link_libraries(appVideoclips
#     PRIVATE Qt6::Quick
# )
#
# include(GNUInstallDirs)
# install(TARGETS appVideoclips
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )

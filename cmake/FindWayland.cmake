# - Finds Wayland
# Find the Wayland libraries that are needed for UWAC
#
#  This module defines the following variables:
#     Wayland_FOUND           - true if UWAC has been found
#     Wayland_LIBRARIES       - Set to the full path to wayland client libraries
#     Wayland_INCLUDE_DIRS    - Set to the include directories for wayland
#

#=============================================================================
# Copyright 2015 David Fort <contact@hardening-consulting.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================

# All components are required
set(Wayland_FIND_COMPONENTS Scanner Client Cursor)
foreach(comp IN LISTS Wayland_FIND_COMPONENTS)
    set(Waylanf_FIND_REQUIREDD_${comp} TRUE)
endforeach()

find_package(PkgConfig)

if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_Wayland_Scanner wayland-scanner)
    pkg_check_modules(PC_Wayland_Client wayland-client)
    pkg_check_modules(PC_Wayland_Cursor wayland-cursor)
endif()

set(_WaylandScanner_HINTS)
if(PC_Wayland_Scanner_FOUND)
  set(_Wayland_Scanner_HINTS ${PC_Wayland_Scanner_PREFIX}/bin)
endif()
find_program(Wayland_Scanner_EXECUTABLE wayland-scanner
    HINTS ${_Wayland_Scanner_HINTS}
)

find_path(Wayland_INCLUDE_DIR wayland-client.h
    HINTS ${PC_Wayland_Client_INCLUDE_DIRS}
)

find_library(Wayland_Client_LIBRARY wayland-client
    HINTS ${PC_Wayland_Client_LIBRARY_DIRS}
)

find_library(Wayland_Cursor_LIBRARY wayland-cursor
    HINTS ${PC_Wayland_Cursor_LIBRARY_DIRS}
)

set(Wayland_Scanner_FOUND FALSE)
if(Wayland_Scanner_EXECUTABLE)
    set(Wayland_Scanner_FOUND TRUE)
endif()

set(Wayland_Client_FOUND FALSE)
set(Wayland_Cursort_FOUND FALSE)
if(Wayland_INCLUDE_DIR)
    if(Wayland_Client_LIBRARY)
        set(Wayland_Client_FOUND TRUE)
    endif()
    if(Wayland_Cursor_LIBRARY)
        set(Wayland_Cursor_FOUND TRUE)
    endif()
endif()

find_package(X11 COMPONENTS xkbcommon)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Wayland
    REQUIRED_VARS Wayland_INCLUDE_DIR X11_xkbcommon_FOUND
    HANDLE_COMPONENTS
)

if(Wayland_FOUND)
    if(NOT TARGET Wayland::Scanner)
        add_executable(Wayland::Scanner IMPORTED)
        set_target_properties(Wayland::Scanner PROPERTIES
            IMPORTED_LOCATION ${Wayland_Scanner_EXECUTABLE}
        )
    endif()

    set(Wayland_Client_INCLUDE_DIRS ${Wayland_INCLUDE_DIR})
    set(Wayland_Client_LIBRARIES ${Wayland_Client_LIBRARY})
    if(NOT TARGET Wayland::Client)
        add_library(Wayland::Client UNKNOWN IMPORTED)
        set_target_properties(Wayland::Client PROPERTIES
            IMPORTED_LOCATION ${Wayland_Client_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${Wayland_INCLUDE_DIR}
        )
    endif()

    set(Wayland_Cursor_INCLUDE_DIRS ${Wayland_INCLUDE_DIR})
    set(Wayland_Cursor_LIBRARIES ${Wayland_Cursor_LIBRARY})
    if(NOT TARGET Wayland::Cursor)
        add_library(Wayland::Cursor UNKNOWN IMPORTED)
        set_target_properties(Wayland::Cursor PROPERTIES
            IMPORTED_LOCATION ${Wayland_Cursor_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${Wayland_INCLUDE_DIR}
        )
    endif()

    set(Wayland_INCLUDE_DIRS ${Wayland_INCLUDE_DIR})
    set(Wayland_LIBRARIES ${Wayland_CLIENT_LIBRARY} ${Wayland_Cursor_LIBRARY})
    if(NOT TARGET Wayland::Wayland)
        add_library(Wayland::Wayland INTERFACE IMPORTED)
        set_target_properties(Wayland::Wayland PROPERTIES
            INTERFACE_LINK_LIBRARIES "Wayland::Client;Wayland::Cursor"
        )
    endif()
endif()

# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "basic_teleop: 1 messages, 0 services")

set(MSG_I_FLAGS "-Ibasic_teleop:/home/will/catkin_ws/src/basic_teleop/msg;-Istd_msgs:/opt/ros/jade/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(basic_teleop_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" NAME_WE)
add_custom_target(_basic_teleop_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "basic_teleop" "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" ""
)

#
#  langs = gencpp;geneus;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(basic_teleop
  "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/basic_teleop
)

### Generating Services

### Generating Module File
_generate_module_cpp(basic_teleop
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/basic_teleop
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(basic_teleop_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(basic_teleop_generate_messages basic_teleop_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" NAME_WE)
add_dependencies(basic_teleop_generate_messages_cpp _basic_teleop_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(basic_teleop_gencpp)
add_dependencies(basic_teleop_gencpp basic_teleop_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS basic_teleop_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages
_generate_msg_eus(basic_teleop
  "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/basic_teleop
)

### Generating Services

### Generating Module File
_generate_module_eus(basic_teleop
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/basic_teleop
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(basic_teleop_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(basic_teleop_generate_messages basic_teleop_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" NAME_WE)
add_dependencies(basic_teleop_generate_messages_eus _basic_teleop_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(basic_teleop_geneus)
add_dependencies(basic_teleop_geneus basic_teleop_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS basic_teleop_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(basic_teleop
  "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/basic_teleop
)

### Generating Services

### Generating Module File
_generate_module_lisp(basic_teleop
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/basic_teleop
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(basic_teleop_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(basic_teleop_generate_messages basic_teleop_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" NAME_WE)
add_dependencies(basic_teleop_generate_messages_lisp _basic_teleop_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(basic_teleop_genlisp)
add_dependencies(basic_teleop_genlisp basic_teleop_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS basic_teleop_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(basic_teleop
  "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/basic_teleop
)

### Generating Services

### Generating Module File
_generate_module_py(basic_teleop
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/basic_teleop
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(basic_teleop_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(basic_teleop_generate_messages basic_teleop_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/will/catkin_ws/src/basic_teleop/msg/Move.msg" NAME_WE)
add_dependencies(basic_teleop_generate_messages_py _basic_teleop_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(basic_teleop_genpy)
add_dependencies(basic_teleop_genpy basic_teleop_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS basic_teleop_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/basic_teleop)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/basic_teleop
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(basic_teleop_generate_messages_cpp std_msgs_generate_messages_cpp)

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/basic_teleop)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/basic_teleop
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
add_dependencies(basic_teleop_generate_messages_eus std_msgs_generate_messages_eus)

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/basic_teleop)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/basic_teleop
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
add_dependencies(basic_teleop_generate_messages_lisp std_msgs_generate_messages_lisp)

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/basic_teleop)
  install(CODE "execute_process(COMMAND \"/usr/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/basic_teleop\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/basic_teleop
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
add_dependencies(basic_teleop_generate_messages_py std_msgs_generate_messages_py)

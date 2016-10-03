; Auto-generated. Do not edit!


(cl:in-package basic_teleop-msg)


;//! \htmlinclude Move.msg.html

(cl:defclass <Move> (roslisp-msg-protocol:ros-message)
  ((direction
    :reader direction
    :initarg :direction
    :type cl:string
    :initform "")
   (duration
    :reader duration
    :initarg :duration
    :type cl:fixnum
    :initform 0))
)

(cl:defclass Move (<Move>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Move>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Move)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name basic_teleop-msg:<Move> is deprecated: use basic_teleop-msg:Move instead.")))

(cl:ensure-generic-function 'direction-val :lambda-list '(m))
(cl:defmethod direction-val ((m <Move>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader basic_teleop-msg:direction-val is deprecated.  Use basic_teleop-msg:direction instead.")
  (direction m))

(cl:ensure-generic-function 'duration-val :lambda-list '(m))
(cl:defmethod duration-val ((m <Move>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader basic_teleop-msg:duration-val is deprecated.  Use basic_teleop-msg:duration instead.")
  (duration m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Move>) ostream)
  "Serializes a message object of type '<Move>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'direction))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'direction))
  (cl:let* ((signed (cl:slot-value msg 'duration)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 65536) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Move>) istream)
  "Deserializes a message object of type '<Move>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'direction) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'direction) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'duration) (cl:if (cl:< unsigned 32768) unsigned (cl:- unsigned 65536))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Move>)))
  "Returns string type for a message object of type '<Move>"
  "basic_teleop/Move")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Move)))
  "Returns string type for a message object of type 'Move"
  "basic_teleop/Move")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Move>)))
  "Returns md5sum for a message object of type '<Move>"
  "39ad474dc541f591e27d6995c7b85b53")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Move)))
  "Returns md5sum for a message object of type 'Move"
  "39ad474dc541f591e27d6995c7b85b53")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Move>)))
  "Returns full string definition for message of type '<Move>"
  (cl:format cl:nil "string direction~%int16 duration~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Move)))
  "Returns full string definition for message of type 'Move"
  (cl:format cl:nil "string direction~%int16 duration~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Move>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'direction))
     2
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Move>))
  "Converts a ROS message object to a list"
  (cl:list 'Move
    (cl:cons ':direction (direction msg))
    (cl:cons ':duration (duration msg))
))

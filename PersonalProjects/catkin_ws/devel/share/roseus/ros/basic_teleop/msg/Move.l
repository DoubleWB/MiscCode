;; Auto-generated. Do not edit!


(when (boundp 'basic_teleop::Move)
  (if (not (find-package "BASIC_TELEOP"))
    (make-package "BASIC_TELEOP"))
  (shadow 'Move (find-package "BASIC_TELEOP")))
(unless (find-package "BASIC_TELEOP::MOVE")
  (make-package "BASIC_TELEOP::MOVE"))

(in-package "ROS")
;;//! \htmlinclude Move.msg.html


(defclass basic_teleop::Move
  :super ros::object
  :slots (_direction _duration ))

(defmethod basic_teleop::Move
  (:init
   (&key
    ((:direction __direction) "")
    ((:duration __duration) 0)
    )
   (send-super :init)
   (setq _direction (string __direction))
   (setq _duration (round __duration))
   self)
  (:direction
   (&optional __direction)
   (if __direction (setq _direction __direction)) _direction)
  (:duration
   (&optional __duration)
   (if __duration (setq _duration __duration)) _duration)
  (:serialization-length
   ()
   (+
    ;; string _direction
    4 (length _direction)
    ;; int16 _duration
    2
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _direction
       (write-long (length _direction) s) (princ _direction s)
     ;; int16 _duration
       (write-word _duration s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _direction
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _direction (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; int16 _duration
     (setq _duration (sys::peek buf ptr- :short)) (incf ptr- 2)
   ;;
   self)
  )

(setf (get basic_teleop::Move :md5sum-) "39ad474dc541f591e27d6995c7b85b53")
(setf (get basic_teleop::Move :datatype-) "basic_teleop/Move")
(setf (get basic_teleop::Move :definition-)
      "string direction
int16 duration

")



(provide :basic_teleop/Move "39ad474dc541f591e27d6995c7b85b53")



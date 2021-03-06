#!/bin/bash

# Software License Agreement (BSD License)
#
# Copyright (c) 2015, Tokyo Opensource Robotics Kyokai Association.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#  * Neither the name of the association nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

DATE=`date`
cat <<EOF
###
### THIS FILE IS AUTOMATICALLY GENERATED by $0 ${PWD} ${DATE}
###
spur:
  # Publish all joint states -----------------------------------
  joint_state_controller:
    type: joint_state_controller/JointStateController
    publish_rate: 50  
EOF

cat <<EOF

  # Velocity Controllers ---------------------------------------
EOF
for joint in bl_wheel_joint br_wheel_joint fl_wheel_joint fr_wheel_joint; do
    cat <<EOF
  ${joint}_velocity_controller:
    type: effort_controllers/JointVelocityController
    joint: ${joint}
    pid: {p: 2000.0, i: 1.0, d: 0.1}
EOF
done

cat <<EOF

  # Position Controllers ---------------------------------------
EOF
for joint in bl_rotation_joint br_rotation_joint fl_rotation_joint fr_rotation_joint larm_elbow_p_joint larm_shoulder_p_joint larm_shoulder_r_joint larm_shoulder_y_joint larm_wrist_p_joint larm_wrist_r_joint rarm_elbow_p_joint rarm_shoulder_p_joint rarm_shoulder_r_joint rarm_shoulder_y_joint rarm_wrist_p_joint rarm_wrist_r_joint; do
    cat <<EOF
  ${joint}_position_controller:
    type: effort_controllers/JointPositionController
    joint: ${joint}
    pid: {p: 1000.0, i: 1, d: 10.0}
EOF
done

for arm in larm rarm; do
    joint_list="${arm}_elbow_p_joint ${arm}_shoulder_p_joint ${arm}_shoulder_r_joint ${arm}_shoulder_y_joint ${arm}_wrist_p_joint ${arm}_wrist_r_joint"
    cat <<EOF

  # Trajectory Controllers ---------------------------------------
  ${arm}_trajectory_controller:
    type: effort_controllers/JointTrajectoryController
    joints:
EOF
    for joint in ${joint_list}; do
    cat <<EOF
      - ${joint}
EOF
    done
    cat <<EOF
    constraints:
      goal_time: 0.5                   # Override default
      stopped_velocity_tolerance: 0.02 # Override default
EOF
    for joint in ${joint_list}; do
        cat <<EOF
      ${joint}:
        trajectory: 0.05               # Not enforced if unspecified
        goal: 0.02                     # Not enforced if unspecified
EOF
    done
    cat <<EOF

    gains: # Required because we're controlling an effort interface
EOF
    for joint in ${joint_list}; do
    cat <<EOF
      ${joint}: {p: 1000,  d: 10, i: 1, i_clamp: 1}
EOF
    done
    cat <<EOF
    state_publish_rate:  25            # Override default
    action_monitor_rate: 30            # Override default
    stop_trajectory_duration: 0        # Override default

EOF
done


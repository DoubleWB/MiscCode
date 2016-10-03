These are projects done personally.

The Kanji Project was an attempt to digitize my flashcard making for my Japanese class, by translating a pile of flashcards into a list,
using a pen tablet to enter the writing, eventually stroke by stroke. Although I had the structure of the entry system for new flashcards done,
the cursor mapping and drawing is not yet smooth and complete. This project is temporarily on hold, as I realized my development could not keep
up with what I actually had to learn in class.

Hangramon.c is a funnily named complete robot logic for a Botball autonomous robot. The logic includes code for blobbing a 3d environment, and processing that blob with
a huge series of nested loops to identify key points on it, if it is the blob we are looking for. This is not an example of beautiful code, but it was extremely effective.
Contains a host of other logic methods for moving the robot, and having the proper sequence of events in a match.

Learning is a proof of concept for an AI self balancing robot - but this proof of concept is done in a digital space. Currently a work in process, and largely uncommented.
Currently the program acts as a algorithmical trial and error behavior learner. The next step is to try and improve guessing new behaviors, which I will try to also
get working with the same encapsulation from the stimulus that the trial and error does - by grouping similar stimuli by what behaviors work well on them. There are currently
wild bad casting issues, which are being ignored right now as the final form of this project will either be in python or c++, and not have such inheritance problems.

catkin_ws is a catkin project containing a simple teleoperation for a Rasperry Pi based robot in ROS. Used to gain familiarity with the ROS framework. Contains two nodes
written in python, one to be used on a base computer (keyop.py), the other to listen to the commands published over the Move topic, and to be run on the robot (teleop.py)
Although it is functional, a more diverse command set would be desired in the future, and an input method that doesn't destroy the tty of the keyop node terminal. Currently
on hiatus because of hardware difficulties.
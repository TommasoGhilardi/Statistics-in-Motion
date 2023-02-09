---
# Coding Scheme Statistics in motion
---
*(Version 1 – 1 June 2021)*


## **Training Videos**

#### **NotWatching:** Code when the infant is NOT looking to the direction of the screen. More explicitly, the infant should not be able to see the screen at all. The start is when the child’s head/gaze is first outside of the range of being able to see the screen. The stop is the first frame that the child’s head/gaze is back in the range of being able to see the screen.

There could be multiple causes to the infant not watching: not paying attention, parent interference, moving, crying. This is not relevant for our analysis. What we are focusing on is the amount of video watched by the infant.

## **EEG session**

### Video watching

Segment the data in trials. Every trial is 1s long. The fixation cross
defines the baseline trials. The other trials of interest are the 1s
between the two actions when on the screen a still frame of the toybox
is presented.

<img src="https://github.com/TommasoGhilardi/Statistics-in-Motion/blob/main/Video/trials.jpg" width="900">

#### **Goodness:**
Define if the trial is Accepted or Rejected. To be
Accepted multiple conditions have to be met:

-   The infant should be looking while the action (interaction with part of the toybox) is performed.

-   The infant should not be performing any gross-motor movement. Fine-motor movement are defined as any movement/action that is performed with individual fingers or toes. Any movement that exceeds individual finger/toe movement are classified as gross-motor movement (e.g., waving arms in the air). Postural movement should not be considered.

-   There should not be any parental interference: The parent is moving the child (e.g., bouncing, etc.), adjusting the child or his/her posture actively. Supporting a current posture of the child (e.g., while standing/sitting) does NOT count as parental interference
-   The child should not be pulling the cables or the cap during the trial


#### **Annotations:**
When a trial is rejected the reason of its rejection should be reported. Options are:
-   Movement
-   NotLookingCue
-   Other

### Action Execution

#### **ActionExecution:**
Segment the data in trials in which the infant is reaching and manipulating the toybox.


<img src="https://github.com/TommasoGhilardi/Statistics-in-Motion/blob/main/Video/ElanExport.jpg" width="350">

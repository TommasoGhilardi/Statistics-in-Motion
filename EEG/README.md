---
# EEG analysis pipeline
---


### ActionExecution_Analysis.m
This script analyses the data to extract the frequenciy range desynchronised during the action execution phase.
The script calls the function *GraspingSegmentation.m* that reads the csv of the video coding, synch the video to the first fization cross and segment the data.




### ActionPrediction_Analysis.m
This script analyses the data in the frequency range extracted from the execution phase. The scripts calls *RejectVisualCoding.m* that allow to reject epochs based on the  vido codding of the session.

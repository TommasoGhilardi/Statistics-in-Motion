---
# EEG analysis pipeline
---


### ActionExecution_Analysis.m
This script analyses the data to extract the frequenciy range desynchronised during the action execution phase.
The script calls the function *GraspingSegmentation.m* that reads the csv of the video coding, synch the video to the first fization cross and segment the data.
<br/>
<br/>
### ActionPrediction_Analysis.m
This script analyses the data in the frequency range extracted from the execution phase. The scripts calls *RejectVisualCoding.m* that allow to reject epochs based on the  vido codding of the session.
<br/>
<br/>
### Frequencies_Extractor.m
This script extract the frequency powerspectrum of both the action execution and prediction phase
<br/>
<br/>
### Plot_Frequencies.m 
This script combines all the action execution frequencies files and the fixation crosss of the action prediction.
The two powerspectrums are then plotted to explore the mu frequency suppressed during action execution.
<br/>
<br/>

### Prediction_toCSV.m
This script extract the frequency powerspectrum of the action prediction phase in the population specific range and saves the data in a csv.

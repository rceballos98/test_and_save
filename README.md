# test_and_save
General framework for machine learning projects in MATLAB that keeps track of past training parameters, accuracy scores and trained models for arbitrary trainers, automatically cataloging optimization routines and eliminating redundant training.

## Basic Use
The test and save function takes in a user defined training function that will be passed a user defined training parameters structure as input. It will then feed the resulting model together with the testing parameter structure to the user defined testing function. The example_script containes a concrete example of how to do this and the svm and cross validation wrapper (svmW and crossValW) are examples of the kind of wrapper functions the test_and_save framework will take in.

### Motivation
I made this framework after going crazy while trying to keep track of all the different parameters and slight variations of training algorithms I had to try for my thesis. What this framework provides is basically a tool to document what training algorithms you have trained before and with what parameters. If you give it the "load_models" options as true, it will also look back through your previous trains and tell you if you are trying a duplicate training session and will instead load the model you already made and feed that into your testing function. This lets you easily re-test all your models with a new metric, for example. 

### Finally, some things to watch out for:
1. I make no guarantees about this software, I made it for me but make it available to whomever wants to use it.
2. This function doesn't look into your trainer and tester function to decide if it's a duplicate, all it does is compare the training and testing parameters and the NAME of the trainer function. If you are editing and testing the same function, add a parameter with the version you are testing so that the framework can tell them apart. 
3. Let me know if you have any comments or edits!



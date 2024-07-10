# Data Dictionaries

## Bernoulli Experiment (A/B Test) Example Data

### Background
The example dataset for a Bernoulli experiment is an A/B test run in 2015 on the ASSISTments platform by Tamisha Thompson.
It was run on an ASSISTments "skill builder"--a mastery-learning module--about the area of triangles.
The skill builder can be accessed [here](https://app.assistments.org/find/lv/ps/487281).

There were four conditions in the experiment, but for this dataset we only kept two, in which struggling students had access to worked examples presented in text or in videos.

Students were independently randomized to each condition with equal probability.

The outcome of interest (for our purposes) is whether or not students completed the skill builder (i.e. demonstrated mastery by solving three right in a row).

The results of the experiment were never published on their own, but were included among many others in [this JEDM article](https://jedm.educationaldatamining.org/index.php/JEDM/article/view/646).

### Variables

|Variable |Description|
|--------:|:-----:|
|user_id|Unique ID for students in the RCT|
|student_prior_*| Aggregated data from each student's work in ASSISTments from before the RCT began|
|video| =TRUE if the student was randomized to the video condition; =FALSE if the student was randomized to the text condition|
|completion| =1 if the student completed the skill builder; =0 if they didn't|

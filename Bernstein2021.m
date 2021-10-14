%formatted for running multiple large data sets

clc;
close all;
clear all;

LBStimulus1 = {'The weight of the package was seen on the high scale'};
LBResponse1 = {'The weight of axe was seen Serbia'};
LBStimulus2 = {'The weight of the package was seen on the high scale'};
LBResponse2 = {'package tree secure'};
LBStimulus3 = {'The weight of the package was seen on the high scale'};
LBResponse3 = {'just by the ice skater by the'};
LBStimulus4 = {'The weight of the package was seen on the high scale'};
LBResponse4 = {'the weight of the package free and secure'};

LBStimulus5 = {'The square peg will settle in the round hole'};
LBResponse5 = {'The square peg were orifice'};
LBStimulus6 = {'The square peg will settle in the round hole'};
LBResponse6 = {'The square pegs were old'};
LBStimulus7 = {'The square peg will settle in the round hole'};
LBResponse7 = {'walk by the peg if it were'};
LBStimulus8 = {'The square peg will settle in the round hole'};
LBResponse8= {'square pig near the round hole'};

LBStimulus9 = {'The store was jammed before the sale could start'};
LBResponse9 = {'the door will close before the sale is'};
LBStimulus10 = {'The store was jammed before the sale could start'};
LBResponse10 = {'twelve stories can reduce the sale'};
LBStimulus11 = {'The store was jammed before the sale could start'};
LBResponse11 = {'twelve stories to reduce the pair'};
LBStimulus12 = {'The store was jammed before the sale could start'};
LBResponse12 = {'a store induce the sale'};



%comment out whichever lines you don't want to run
composite = {...
       {LBStimulus1,LBResponse1,'Bernstein 2021 Example 1'}, ...
       {LBStimulus2,LBResponse2,'Bernstein 2021 Example 2'}, ...       
       {LBStimulus3,LBResponse3,'Bernstein 2021 Example 3'}, ...
       {LBStimulus4,LBResponse4,'Bernstein 2021 Example 4'}, ...
       {LBStimulus5,LBResponse5,'Bernstein 2021 Example 5'}, ...
       {LBStimulus6,LBResponse6,'Bernstein 2021 Example 6'}, ...       
       {LBStimulus7,LBResponse7,'Bernstein 2021 Example 7'}, ...
       {LBStimulus8,LBResponse8,'Bernstein 2021 Example 8'}, ...
       {LBStimulus9,LBResponse9,'Bernstein 2021 Example 9'}, ...
       {LBStimulus10,LBResponse10,'Bernstein 2021 Example 10'}, ...       
       {LBStimulus11,LBResponse11,'Bernstein 2021 Example 11'}, ...
       {LBStimulus12,LBResponse12,'Bernstein 2021 Example 12'}, ...

    };

diary('phoneme_analysis_output.txt')
wpo=false;
phoneme_analysis_fscore(composite,wpo);
diary('off')

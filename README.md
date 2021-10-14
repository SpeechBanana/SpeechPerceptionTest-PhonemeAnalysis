# SpeechPerceptionTest-PhonemeAnalysis
Scripts for analyzing phoneme errors from speech perception tests


October 2021

Credits
- scLite & scKit (alignment via dynamic programming)
- Elad Sagi (feature analysis for phonemegram)
- Seung-Ho "Ben" Bae (phonemegram and testing)
- Lydia Wang (alignment and testing)
- Zachary Heiman (costs for alignment)
- Nole Lin (original design)
- Tilak Ratnanather (concept, editing and testing)
- Daniel Tward (concept)
- Erin O'Neill (validation dataset)

Main scripts are

TestData 
- from six volunteers and published stimulus-response pairs

Bernstein2021
- from Table 1 of Bernstein et al. (2021)

Validation 
- data from O'Neill et al. (2021)
- Stimulus from Original BEL Corpus Text.xlsx
- Responses from Responses.xlsx
- Original Stimulus-Response pairs saved as originalpairs
- Random Stimulus-Response pairs saved as randompairs
- Non-dupliated Stimulus-Response pairs saved as reducedpairs

Working files
- featU for phonemegram
- info2 for phonemegram
- phonene_analysis_fscore
- phoxyz are the phonemes
- splitCMUdict is the CMU dictionary with lexicals removed
- variables 

%formatted for running multiple large data sets

clc;
clear all;
close all;

% % % sheets_corpus = sheetnames('Original BEL Corpus (Text).xlsx');
% % % for k=1:numel(sheets_corpus)
% % %   disp(sheets_corpus{k})
% % %   BELcorpus{k}=readtable('Original BEL Corpus (Text).xlsx','Sheet',sheets_corpus{k});
% % % end
% % % 
% % % sheets_data = sheetnames('All Data.xlsx');
% % % for k=1:numel(sheets_data)
% % %   disp(sheets_data{k})
% % %   data{k}=readtable('Responses.xlsx','Sheet',sheets_data{k});
% % % end
% % % 
% % % UMcorpusTrue = {};
% % % for i=1:numel(BELcorpus)
% % %     UMcorpusTrue = [UMcorpusTrue, BELcorpus{i}];
% % % end
% % % 
% % % stimuli = {};
% % % excluded_lists = [1 4 12 18];
% % % for c=1:20
% % %     if ~ismember(c,excluded_lists)
% % %         for r=1:25
% % %             stimuli = [stimuli, UMcorpusTrue{r,c}];
% % %         end
% % %     end
% % % end
% % % 
% % % sub1 = data{1};
% % % sub1_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub1_responses = [sub1_responses, sub1{r,c}];
% % %     end
% % % end
% % % 
% % % sub2 = data{2};
% % % sub2_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub2_responses = [sub2_responses, sub2{r,c}];
% % %     end
% % % end
% % % 
% % % sub3 = data{3};
% % % sub3_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub3_responses = [sub3_responses, sub3{r,c}];
% % %     end
% % % end
% % % 
% % % sub4 = data{4};
% % % sub4_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub4_responses = [sub4_responses, sub4{r,c}];
% % %     end
% % % end
% % % 
% % % sub5 = data{5};
% % % sub5_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub5_responses = [sub5_responses, sub5{r,c}];
% % %     end
% % % end
% % % 
% % % sub6 = data{6};
% % % sub6_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub6_responses = [sub6_responses, sub6{r,c}];
% % %     end
% % % end
% % % 
% % % sub7 = data{7};
% % % sub7_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub7_responses = [sub7_responses, sub7{r,c}];
% % %     end
% % % end
% % % 
% % % sub8 = data{8};
% % % sub8_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub8_responses = [sub8_responses, sub8{r,c}];
% % %     end
% % % end
% % % 
% % % sub9 = data{9};
% % % sub9_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub9_responses = [sub9_responses, sub9{r,c}];
% % %     end
% % % end
% % % 
% % % sub10 = data{10};
% % % sub10_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub10_responses = [sub10_responses, sub10{r,c}];
% % %     end
% % % end
% % % 
% % % sub11 = data{11};
% % % sub11_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub11_responses = [sub11_responses, sub11{r,c}];
% % %     end
% % % end
% % % 
% % % sub12 = data{12};
% % % sub12_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub12_responses = [sub12_responses, sub12{r,c}];
% % %     end
% % % end
% % % 
% % % sub13 = data{13};
% % % sub13_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub13_responses = [sub13_responses, sub13{r,c}];
% % %     end
% % % end
% % % 
% % % sub14 = data{14};
% % % sub14_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub14_responses = [sub14_responses, sub14{r,c}];
% % %     end
% % % end
% % % 
% % % sub15 = data{15};
% % % sub15_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub15_responses = [sub15_responses, sub15{r,c}];
% % %     end
% % % end
% % % 
% % % sub16 = data{16};
% % % sub16_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub16_responses = [sub16_responses, sub16{r,c}];
% % %     end
% % % end
% % % 
% % % sub17 = data{17};
% % % sub17_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub17_responses = [sub17_responses, sub17{r,c}];
% % %     end
% % % end
% % % 
% % % sub18 = data{18};
% % % sub18_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub18_responses = [sub18_responses, sub18{r,c}];
% % %     end
% % % end
% % % 
% % % sub19 = data{19};
% % % sub19_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub19_responses = [sub19_responses, sub19{r,c}];
% % %     end
% % % end
% % % 
% % % sub20 = data{20};
% % % sub20_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub20_responses = [sub20_responses, sub20{r,c}];
% % %     end
% % % end
% % % 
% % % sub21 = data{21};
% % % sub21_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub21_responses = [sub21_responses, sub21{r,c}];
% % %     end
% % % end
% % % 
% % % sub22 = data{22};
% % % sub22_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub22_responses = [sub22_responses, sub22{r,c}];
% % %     end
% % % end
% % % 
% % % sub23 = data{23};
% % % sub23_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub23_responses = [sub23_responses, sub23{r,c}];
% % %     end
% % % end
% % % 
% % % sub24 = data{24};
% % % sub24_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub24_responses = [sub24_responses, sub24{r,c}];
% % %     end
% % % end
% % % 
% % % sub25 = data{25};
% % % sub25_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub25_responses = [sub25_responses, sub25{r,c}];
% % %     end
% % % end
% % % 
% % % sub26 = data{26};
% % % sub26_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub26_responses = [sub26_responses, sub26{r,c}];
% % %     end
% % % end
% % % 
% % % sub27 = data{27};
% % % sub27_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub27_responses = [sub27_responses, sub27{r,c}];
% % %     end
% % % end
% % % 
% % % sub28 = data{28};
% % % sub28_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub28_responses = [sub28_responses, sub28{r,c}];
% % %     end
% % % end
% % % 
% % % sub29 = data{29};
% % % sub29_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub29_responses = [sub29_responses, sub29{r,c}];
% % %     end
% % % end
% % % 
% % % sub30 = data{30};
% % % sub30_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub30_responses = [sub30_responses, sub30{r,c}];
% % %     end
% % % end
% % % 
% % % sub31 = data{31};
% % % sub31_responses = {};
% % % for c=1:16
% % %     for r=1:25
% % %         sub31_responses = [sub31_responses, sub31{r,c}];
% % %     end
% % % end
% % % 
% % % combined_responses = [sub1_responses, sub2_responses, sub3_responses, sub4_responses, sub5_responses, sub6_responses, sub7_responses, sub8_responses, sub9_responses, sub10_responses, sub11_responses, sub12_responses, sub13_responses, sub14_responses, sub15_responses, sub16_responses, sub17_responses, sub18_responses, sub19_responses, sub20_responses, sub21_responses, sub22_responses, sub23_responses, sub24_responses, sub25_responses, sub26_responses, sub27_responses, sub28_responses, sub29_responses, sub30_responses, sub31_responses];
% % % combined_stimuli = [stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli, stimuli];
% % % 
% % % 
% % %comment out whichever lines you don't want to run
% % composite = {...
% % % {stimuli, sub1_responses, 'Subject 1'}
% % % {stimuli, sub2_responses, 'Subject 2'}
% % % {stimuli, sub3_responses, 'Subject 3'}
% % % {stimuli, sub4_responses, 'Subject 4'}
% % % {stimuli, sub5_responses, 'Subject 5'}
% % % {stimuli, sub6_responses, 'Subject 6'}
% % % {stimuli, sub7_responses, 'Subject 7'}
% % % {stimuli, sub8_responses, 'Subject 8'}
% % % {stimuli, sub9_responses, 'Subject 9'}
% % % {stimuli, sub10_responses, 'Subject 10'}
% % % {stimuli, sub11_responses, 'Subject 11'}
% % % {stimuli, sub12_responses, 'Subject 12'}
% % % {stimuli, sub13_responses, 'Subject 13'}
% % % {stimuli, sub14_responses, 'Subject 14'}
% % % {stimuli, sub15_responses, 'Subject 15'}
% % % {stimuli, sub16_responses, 'Subject 16'}
% % % {stimuli, sub17_responses, 'Subject 17'}
% % % {stimuli, sub18_responses, 'Subject 18'}
% % % {stimuli, sub19_responses, 'Subject 19'}
% % % {stimuli, sub20_responses, 'Subject 20'}
% % % {stimuli, sub21_responses, 'Subject 21'}
% % % {stimuli, sub22_responses, 'Subject 22'}
% % % {stimuli, sub23_responses, 'Subject 23'}
% % % {stimuli, sub24_responses, 'Subject 24'}
% % % {stimuli, sub25_responses, 'Subject 25'}
% % % {stimuli, sub26_responses, 'Subject 26'}
% % % {stimuli, sub27_responses, 'Subject 27'}
% % % {stimuli, sub28_responses, 'Subject 28'}
% % % {stimuli, sub29_responses, 'Subject 29'}
% % % {stimuli, sub30_responses, 'Subject 30'}
% % % {stimuli, sub31_responses, 'Subject 31'}
% % % {combined_stimuli, combined_responses, 'Combined Subjects'}
% % %   };
% % %

% % % %save originalpairs combined_stimuli combined_responses
load originalpairs
% composite = { ...
%     {combined_stimuli, combined_responses, ['Combined Subjects']}
% };

%%%Randomise responses
% oldidx = [1:1:12400];
% newidx = oldidx(randperm(numel(oldidx)));
% random_stimuli = combined_stimuli;
% random_responses = {combined_responses{newidx}};
% save randompairs random_stimuli random_responses
% composite = { ...
%      {random_stimuli, random_responses, ['Random Subjects']}
% };

%%%remove duplicated pairs
C1 = {combined_stimuli{:};combined_responses{:}}';
[~,idx]=unique(strcat(C1(:,1),C1(:,2)));
C2 = C1(idx,:);
reduced_stimuli   = {C2{:,1}};
reduced_responses = {C2{:,2}};
save reducedpairs reduced_stimuli reduced_responses
composite = { ...
    {reduced_stimuli, reduced_responses, ['Reduced Subjects']}
};

dfile ='phoneme_analysis_output.txt';
if exist(dfile, 'file')exit ; delete(dfile); end
diary(dfile)
diary on
wpo=false;
phoneme_analysis_fscore(composite,wpo);
diary('off')
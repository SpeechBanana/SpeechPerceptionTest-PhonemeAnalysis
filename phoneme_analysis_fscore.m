%patched BEST! Time/case/phoneme stats, fast, advanced cost
function [pScores] = phoneme_analysis_fscore(allData,wpo,mult)

%phoxyz.mat contains a map from phoneme to coordinate for phonemic error
%visualization
load phoxyz
load splitCMUdict.mat
load variables.mat

% nontarget = {146/'a', 'the', 'of', 'A', 'The', 'Of'}; % will remove non-target words
% nontarget = {'a', 'of', 'A', 'Of'};
% MAKE SURE ALL NONTARGETS ARE IN ALL UPPERCASE LETTERS
nontarget = {};

stats = cell(length(allData) + 1, 5);

stats{1,1} = 'Name';
stats{1,2} = 'Stimuli';
stats{1,3} = 'Response phonemes';
stats{1,4} = 'Stimulus phonemes';
stats{1,5} = 'Time (sec)';
stats{1,6} = 'Correct # of words';
stats{1,7} = 'Total # of words';
stats{1,8} = 'Correct # of stimulus';

for casenum = 1:length(allData)
	tic;
	totalnum = 0; %total number of true phonemes
	totalresponse = 0; %total number of response phonemes
	Stim = allData{casenum}{1}; %extract stimuli
	Response = allData{casenum}{2}; %extract responses to stimuli
	Name = allData{casenum}{3}; %extract name
	totalUniqPh = {}; %all unique phonemes every response/said
	% phoneme, TP, FP, FN
	totalData = cell(1,length(Stim)); %to hold all data
	stats{casenum+1,1} = Name; %for timing stats
	stats{casenum+1,2} = length(Stim); %for timing stats
	
    %%%Added Sept 2021
%     if(casenum==1)
%         fileID1 = fopen(['Phonemegram.txt'], 'w');
%         fileID2 = fopen(['VowelF1.txt'], 'w');
%         fileID3 = fopen(['VConsF1.txt'], 'w');
%         fileID4 = fopen(['UConsF1.txt'], 'w'); 
%         fileID5 = fopen(['Pairwise.txt'],'w');
%     end
%     fprintf(fileID1,'\n%s\t Stimuli\n', Name);
%     fprintf(fileID2,'\n%s\t Stimuli\n', Name);
%     fprintf(fileID3,'\n%s\t Stimuli\n', Name);
%     fprintf(fileID4,'\n%s\t Stimuli\n', Name);
   
    % Take out all characters that are not letters, apostrophes or spaces
	for i = 1:length(Stim)
		curr_response = Response{i}(regexp(Response{i}, '[a-zA-Z\s'']'));
		curr_stim = Stim{i}(regexp(Stim{i}, '[a-zA-Z\s'']'));
		Response{i} = strtrim(curr_response);
		Stim{i} = strtrim(curr_stim);
	end
	
	% initialize features array (see return_features below)
	features = zeros(10,2);
    % initialize confusion matrices
    vowel_matrix=zeros(15,16);
    consonant_matrix=zeros(24,25);

	% reals and responses are empty cell arrays of length of real
	num = length(Stim);
	reals = cell(1,num);
	responses = cell(1,num);
    num_wordscorrect = 0;
    num_stimcorrect = 0;
    num_totalwords = 0;
    
	for z = 1:num
		% get a list of words in your response
		responseWords = upper(char(Response(z)));
		responseWords = strsplit(responseWords, ' ');
		% get a list of words in the real stimulus
		stimWords = upper(char(Stim(z)));
		stimWords = strsplit(stimWords, ' ');
		% now loop through real words, and remove nontargets (of, the, etc)
		k = 1;
		while k <= length(stimWords)
			if sum(strcmp(stimWords{k}, nontarget))
				stimWords(k) = [];
				k = k - 1;
			end
			k = k + 1;
		end
		k = 1;
		%do the same for response words
		while k <= length(responseWords)
			if sum(strcmp(responseWords{k}, nontarget))
				responseWords(k) = [];
				k = k - 1;
			end
			k = k + 1;
		end
		reals{z} = stimWords;
		responses{z} = responseWords;
    end
    
    for z = 1:num
        %compare response and stimulus words to get # of words correct
        if isequal(responses{z},reals{z})
            num_stimcorrect = num_stimcorrect+1;
            if wpo == true
                continue
            end
        end
        num_wordscorrect = num_wordscorrect + numel(intersect(responses{z},reals{z}));
        num_totalwords = num_totalwords + length(reals{z});
    end
	
	% Go to CMU dictionary, and get appropriate phonemes for each word
	responsephonemes = cell(num,1);
	stimphonemes = cell(num,1);
	
    for z = 1:num
		
        if wpo == true
            if isequal(Response{z},Stim{z})
                continue
            end
        end
        
        %%%Added Sept 2021 for clarity (and debugging)
        fprintf(['Name: ',Name,'. Stimulus Number: ',num2str(z),' out of ',num2str(num),' stimuli.'])
	    fprintf('\nStimulus: %s\n', Stim{z});
		fprintf('Response: %s\n\n', Response{z});
		real2 = {};
		for k = 1:length(reals{z})
		if isKey(splitCMUdict, reals{z}{k})
                   real2{end+1} = splitCMUdict(reals{z}{k});
                else
                fprintf('The true word %s was not found. What is its phoneme represtimation?\n', responses{z}{k});
                isWord = 0;
                while not(isWord)
                    manual = input('(Separate phonemes with spaces. To look up a word in the CMUdict, type ONLY "#word".\n For example, if the problem word is KINTS then look up a similar word like HINTS\n in the CMU Dictionary website and enter the modified phoneme wih H replaced by K.)\n', 's');
                    if(isempty(strfind(manual, '#')))
                        real2{end+1} = upper(manual);
                        isWord = 1;
                    else
                        manual = upper(strtrim(manual(regexp(manual, '[a-zA-Z\s'']'))));
                        if isKey(splitCMUdict, manual)
                            fprintf('%s: %s\n', manual, splitCMUdict(manual))
                        else
                            fprintf('%s is not a word in the CMUdict.\n', manual)
                        end
                    end
                end
                continue;
            end
		end
		stimphonemes{z} = strjoin(real2);
		uniqr = strsplit(stimphonemes{z});
		totalnum = totalnum + length(uniqr);
		
		% uniqr2 holds all of the unique real phonemes.
		uniqr2 = unique(uniqr); % at this point we lose the order
		
		% now we split up the phonemes into cells
		% and check for blanks
		% if there's a blank we stick in a bunch of 'qq's
        
        response2 = {};
        for k = 1:length(responses{z})
            if isKey(splitCMUdict, responses{z}{k})
                response2{end+1} = splitCMUdict(responses{z}{k});
            elseif not(isempty(responses{z}{k}))
                fprintf('The response word %s was not found. What is its phoneme represtimation?\n', responses{z}{k});
                isWord = 0;
                while not(isWord)
                    manual = input('(Separate phonemes with spaces. To look up a word in the CMUdict, type ONLY "#word".\n For example, if the problem word is KINTS then look up a similar word like HINTS\n in the CMU Dictionary website and enter the modified phoneme wih H replaced by K.)\n', 's');
                    if(isempty(strfind(manual, '#')))
                        response2{end+1} = upper(manual);
                        isWord = 1;
                    else
                        manual = upper(strtrim(manual(regexp(manual, '[a-zA-Z\s'']'))));
                        if isKey(splitCMUdict, manual)
                            fprintf('%s: %s\n', manual, splitCMUdict(manual))
                        else
                            fprintf('%s is not a word in the CMUdict.\n', manual)
                        end
                    end
                end
                continue;
            end
        end
        if(isempty(response2))
            responsephonemes{z} = strjoin(horzcat(repmat({'qq'},1,length(uniqr))));
			uniqg = strsplit(responsephonemes{z});
			allUniqPh = unique(uniqr2);
			aligned = vertcat(uniqg, uniqr);
            numberofalignments = 0;
        else
            responsephonemes{z} = strjoin(response2);
            uniqg = strsplit(responsephonemes{z});
            uniqg2 = unique(uniqg);
            allUniqPh = unique(horzcat(uniqr2,uniqg2));
            totalresponse = totalresponse + length(uniqg);
            
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            [aligned,numberofalignments] = AlignPhonemes(uniqr,uniqg,consdict,vowdict,mannerdict,mult);
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
        %%Added October 2021
%         if (numberofalignments > 1)
%            fileID6 = fopen(['StimRespWithMultAligns.txt'],'a');
%            fprintf(fileID6,['Name: ',Name,'. Stimulus Number: ',num2str(z),' out of ',num2str(num),' stimuli.'])
% 	       fprintf(fileID6,'\nStimulus: %s\n', Stim{z});
% 		   fprintf(fileID6,'Response: %s\n\n', Response{z});
%            fclose(fileID6);
%         end    
            
		responseph = aligned(1,:);
		stimph = aligned(2,:);
        disp(flip(aligned))
		
		%user heard phon when there was a phon (match)
		truePos = zeros(1,length(allUniqPh));
		%user heard phon when there was no phon (ins or sub: response phon)
		falsePos = zeros(1,length(allUniqPh));
		%user did not hear phon when there was a phon (del or sub: true phon)
		falseNeg = zeros(1,length(allUniqPh));

		for i = 1 : length(stimph)
			%if the real and response match
			%add one to truePos for the corresponding phoneme
			%else
			%add one falsePos for the response
			%add one falseNeg for the true
			if strcmp(stimph{i},responseph{i})
				truePos(1,find(strcmp(allUniqPh,stimph{i}))) = truePos(1,find(strcmp(allUniqPh,stimph{i})))+1;
            else
				falsePos(1,find(strcmp(allUniqPh,responseph{i}))) = falsePos(1,find(strcmp(allUniqPh,responseph{i})))+1;
				falseNeg(1,find(strcmp(allUniqPh,stimph{i}))) = falseNeg(1,find(strcmp(allUniqPh,stimph{i})))+1;
			end
		end
		%find the F1 score
		singleF1 = zeros(1,length(allUniqPh));
		for i = 1 : length(allUniqPh)
			singleF1(1,i) = 200*truePos(1,i)/(2*truePos(1,i)+falsePos(1,i)+falseNeg(1,i));
        end
        
        realF1 = zeros(1,length(uniqr2));
        %%%Added Sept 2021
        realTP = zeros(1,length(uniqr2));
        realFP = zeros(1,length(uniqr2));
        realFN = zeros(1,length(uniqr2));
        
		for i = 1 : length(uniqr2)
			realF1(1,i) = singleF1(1,find(strcmp(allUniqPh,uniqr2{i})));
            %%%Added Sept 2021
            realTP(1,i) = truePos(1,find(strcmp(allUniqPh,uniqr2{i})));
            realFP(1,i) = falsePos(1,find(strcmp(allUniqPh,uniqr2{i})));
            realFN(1,i) = falseNeg(1,find(strcmp(allUniqPh,uniqr2{i})));
		end
		
		totalUniqPh = unique([totalUniqPh allUniqPh]);
		totalData{z} = vertcat(allUniqPh, num2cell(truePos), num2cell(falsePos), num2cell(falseNeg));
		
        disp('Unique Phonemes and their F-Scores')
		pScores=vertcat(uniqr2,num2cell(realF1));
 		disp(pScores)
        [vowel_matrix, consonant_matrix] = matrix_constructor(stimph,responseph,vowels,consonants,vowel_matrix,consonant_matrix);

        %%%Added Sept 2021
        %%%write data for F1, TP, FP, FN for each stimulus-response pair
%         wScores=vertcat(uniqr2,num2cell(realF1),num2cell(realTP),num2cell(realFP),num2cell(realFN));
%         fprintf(fileID5,"%s \t %i \t %i \n",Name,z,num);
%         maxlen = length(wScores);
%         fmt1 = [repmat('%s ',1,length(wScores)),'\n'];
%         fmt2 = [repmat('%5.2f ',1,length(wScores)),'\n'];
%         fmt3 = [repmat('%i ',1,length(wScores)),'\n'];
%         fprintf(fileID5,fmt1,wScores{1,:});
%         fprintf(fileID5,fmt2,wScores{2,:});
%         fprintf(fileID5,fmt3,wScores{3,:});
%         fprintf(fileID5,fmt3,wScores{4,:});
%         fprintf(fileID5,fmt3,wScores{5,:});
        
    end
    
	totalTP = zeros(1,length(totalUniqPh));
	totalFP = zeros(1,length(totalUniqPh));
	totalFN = zeros(1,length(totalUniqPh));
	    
	for i = 1 : length(totalData)
        len = size(totalData{1,i});
		for j = 1 : len(2)
			index = find(strcmp(totalUniqPh, totalData{1,i}{1,j}));
			totalTP(1,index) = totalTP(1,index) + totalData{1,i}{2,j};
			totalFP(1,index) = totalFP(1,index) + totalData{1,i}{3,j};
			totalFN(1,index) = totalFN(1,index) + totalData{1,i}{4,j};
		end
	end
	
	totalF1 = zeros(1,length(totalUniqPh));
	for i = 1 : length(totalUniqPh)
		totalF1(1,i) = 200*totalTP(1,i)/(2*totalTP(1,i)+totalFP(1,i)+totalFN(1,i));
	end
	totalScores = vertcat(totalUniqPh, num2cell(totalF1));

  	figure('Name', Name, 'NumberTitle', 'off');
	set(gcf, 'Position', [0, 0, 710, 570]);
	if ~strcmp(totalUniqPh{1}, '')
		for k = 1:length(totalUniqPh)
			if ~isempty(strfind('AEIOU',totalUniqPh{k}(1))) % if the phoneme is a vowel
				try
					coord = phoxyz(totalUniqPh{k});
				catch
					disp('You might have misspelled something')
					return
				end
				subplot(2,2,2);
				hold on
				scatter(coord(1), coord(2), 350, totalF1(k), 'filled')
				text(coord(1), coord(2), totalUniqPh{k}, 'Color', [219/256,147/256,112/256], 'HorizontalAlignment','center', 'VerticalAlignment','middle')
                %%%Added Sept 2021
                %%%print scores for vowels
                %fprintf(fileID2,"%s\t%5.2f\t%i\t%i\t%i\n",totalUniqPh{k},totalF1(k),totalTP(k),totalFP(k),totalFN(k));
            elseif ~strcmp(totalUniqPh{k}, '') % phoneme is a consonant
				try
					coord = phoxyz(totalUniqPh{k});
				catch
					disp('You might have misspelled something')
					return
				end
				if coord(3) == 1
					subplot(2,2,3);
					hold on
					scatter(coord(1), coord(2), 350, totalF1(k), 'filled')
					text(coord(1), coord(2), totalUniqPh{k}, 'Color', [219/256,147/256,112/256], 'HorizontalAlignment','center', 'VerticalAlignment','middle')
                    %%%Added Sept 2021
                    %%%print scores for consonants (voiced)
                    %fprintf(fileID3,"%s\t%5.2f\t%i\t%i\t%i\n",totalUniqPh{k},totalF1(k),totalTP(k),totalFP(k),totalFN(k));
				else
					subplot(2,2,4);
					hold on
					scatter(coord(1), coord(2), 350, totalF1(k), 'filled')
					text(coord(1), coord(2), totalUniqPh{k}, 'Color', [219/256,147/256,112/256], 'HorizontalAlignment','center', 'VerticalAlignment','middle')
                    %%%Added Sept 2021
                    %%%print scores for consonants (unvoiced)
                    %fprintf(fileID4,"%s\t%5.2f\t%i\t%i\t%i\n",totalUniqPh{k},totalF1(k),totalTP(k),totalFP(k),totalFN(k));
				end
			end
		end
    end
    
    pm_values = zeros(1,10);

    nasality = [1;1;1;1;1;1;1;1;1;1;2;2;2;1;1;1;1;1;1;1;1;1;1;1];
    manner = [1;5;1;3;3;1;3;5;1;4;2;2;2;1;4;3;3;1;3;3;4;4;3;3];
    voicing = [2;1;2;1;1;2;1;2;1;2;2;2;2;1;2;1;1;1;2;2;2;2;2;2];
    affrication = [1;2;1;2;2;1;2;2;1;1;1;1;1;1;1;2;2;1;2;2;1;1;2;2];
    sibilance =  [1;2;1;1;1;1;1;2;1;1;1;1;1;1;1;2;2;1;1;1;1;1;2;2];
    consonant_place = [1;2;2;1;1;3;3;2;3;2;1;2;3;1;2;2;2;2;1;1;1;2;2;2];

    nasality_fm = featU(consonant_matrix, nasality);
    nasality_it = info2(nasality_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(nasality_fm);
    fm_size = fm_matrix_size(1);
    nasality_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(nasality_fm(i,:));
        num_total = sum(nasality_fm,'all');
        if num_phonemes ~= 0
            nasality_stiminfo = nasality_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    nasality_score = 100*(nasality_it/nasality_stiminfo);
    pm_values(1) = nasality_score;

    manner_fm = featU(consonant_matrix, manner);
    manner_it = info2(manner_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(manner_fm);
    fm_size = fm_matrix_size(1);
    manner_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(manner_fm(i,:));
        num_total = sum(manner_fm,'all');
        if num_phonemes ~= 0
            manner_stiminfo = manner_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    manner_score = 100*(manner_it/manner_stiminfo);
    pm_values(3) = manner_score;

    voicing_fm = featU(consonant_matrix, voicing);
    voicing_it = info2(voicing_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(voicing_fm);
    fm_size = fm_matrix_size(1);
    voicing_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(voicing_fm(i,:));
        num_total = sum(voicing_fm,'all');
        if num_phonemes ~= 0
            voicing_stiminfo = voicing_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    voicing_score = 100*(voicing_it/voicing_stiminfo);
    pm_values(4) = voicing_score;

    affrication_fm = featU(consonant_matrix, affrication);
    affrication_it = info2(affrication_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(affrication_fm);
    fm_size = fm_matrix_size(1);
    affrication_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(affrication_fm(i,:));
        num_total = sum(affrication_fm,'all');
        if num_phonemes ~= 0
            affrication_stiminfo = affrication_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    affrication_score = 100*(affrication_it/affrication_stiminfo);
    pm_values(8) = affrication_score;

    sibilance_fm = featU(consonant_matrix, sibilance);
    sibilance_it = info2(sibilance_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(sibilance_fm);
    fm_size = fm_matrix_size(1);
    sibilance_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(sibilance_fm(i,:));
        num_total = sum(sibilance_fm,'all');
        if num_phonemes ~= 0
            sibilance_stiminfo = sibilance_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    sibilance_score = 100*(sibilance_it/sibilance_stiminfo);
    pm_values(9) = sibilance_score;

    consonant_place_fm = featU(consonant_matrix, consonant_place);
    consonant_place_it = info2(consonant_place_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(consonant_place_fm);
    fm_size = fm_matrix_size(1);
    consonant_place_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(consonant_place_fm(i,:));
        num_total = sum(consonant_place_fm,'all');
        if num_phonemes ~= 0
            consonant_place_stiminfo = consonant_place_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    consonant_place_score = 100*(consonant_place_it/consonant_place_stiminfo);
    pm_values(10) = consonant_place_score;

    vowel_height = [1;1;2;2;1;1;2;2;2;3;3;2;2;3;3];
    contour = [2;2;2;2;3;1;2;2;1;2;2;1;3;2;2];
    vowel_place = [3;2;2;3;2;2;1;2;1;1;1;3;3;3;3];
    vowel_length = [1;1;1;1;2;2;1;1;2;1;2;2;2;1;2];

    vowelheight_fm = featU(vowel_matrix,vowel_height);
    vowelheight_it = info2(vowelheight_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(vowelheight_fm);
    fm_size = fm_matrix_size(1);
    vowelheight_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(vowelheight_fm(i,:));
        num_total = sum(vowelheight_fm,'all');
        if num_phonemes ~= 0
            vowelheight_stiminfo = vowelheight_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    vowelheight_score = 100*(vowelheight_it/vowelheight_stiminfo);
    pm_values(2) = vowelheight_score;

    contour_fm = featU(vowel_matrix, contour);
    contour_it = info2(contour_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(contour_fm);
    fm_size = fm_matrix_size(1);
    contour_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(contour_fm(i,:));
        num_total = sum(contour_fm,'all');
        if num_phonemes ~= 0
            contour_stiminfo = contour_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    contour_score = 100*(contour_it/contour_stiminfo);
    pm_values(5) = contour_score;

    vowelplace_fm = featU(vowel_matrix,vowel_place);
    vowelplace_it = info2(vowelplace_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(vowelplace_fm);
    fm_size = fm_matrix_size(1);
    vowelplace_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(vowelplace_fm(i,:));
        num_total = sum(vowelplace_fm,'all');
        if num_phonemes ~= 0
            vowelplace_stiminfo = vowelplace_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    vowelplace_score = 100*(vowelplace_it/vowelplace_stiminfo);
    pm_values(6) = vowelplace_score;

    vowellength_fm = featU(vowel_matrix,vowel_length);
    vowellength_it = info2(vowellength_fm);
    %calculate the stiminfo from the counts found in the feature matrix
    fm_matrix_size = size(vowellength_fm);
    fm_size = fm_matrix_size(1);
    vowellength_stiminfo = 0;
    for i = 1:fm_size
        num_phonemes = sum(vowellength_fm(i,:));
        num_total = sum(vowellength_fm,'all');
        if num_phonemes ~= 0 
            vowellength_stiminfo = vowellength_stiminfo - (num_phonemes/num_total)*log(num_phonemes/num_total);
        end
    end
    vowellength_score = 100*(vowellength_it/vowellength_stiminfo);
    pm_values(7) = vowellength_score;
    
      
% % %     %%%Information Transfer Analysis for each phoneme from 
% % %     %%%vowel_matrix and consonant_matrix which has already been computed.
% % %     %%%For each phoneme compute - sum_k (p_k)*log2(p_k) where p_k 
% % %     %%%is the proportion of responses in category k and 
% % %     %%%k is an index of summation that represents each possible 
% % %     %%%substitution error
% % %     %%%Save the numbers in a data file

%     vphsum = zeros(1,15);
%     for v=1:15
%         vphsum(v) = vphsum(v)+sum(vowel_matrix(v,1:16));
%         if(vphsum(v)>0)
%             vnewmat(v,:) = vowel_matrix(v,:)/vphsum(v);
%         else
%             vnewmat(v,:) = vowel_matrix(v,:);  
%         end
%     end
%     vbit = zeros(1,15);
%     for v=1:15
%         vksum = 0;
%         for k=1:16
%             if (vnewmat(v,k)>0)
%                 vksum = vksum - vnewmat(v,k)*log2(vnewmat(v,k));
%             end
%         end
%         vbit(v) = vksum;
%     end
%     save vbit
%  
%     cphsum = zeros(1,24);
%     for c=1:24
%         cphsum(c) = cphsum(c)+sum(consonant_matrix(c,1:25));
%         if(cphsum(c)>0)
%             cnewmat(c,:) = consonant_matrix(c,:)/cphsum(c);
%         else
%             cnewmat(c,:) = consonant_matrix(c,:);  
%         end
%     end
%     cbit = zeros(1,24);
%     for c=1:24
%         cksum = 0;
%         for k=1:25
%             if (cnewmat(c,k)>0)
%                 cksum = cksum - cnewmat(c,k)*log2(cnewmat(c,k));
%             end
%         end
%         cbit(c) = cksum;
%     end
%     save cbit
    
    subplot(2,2,1);
    histvals = zeros(1,10);
    hold on
    for i = 1:10
        histvals(i) = pm_values(i);
        single = bar(i,histvals(i));
        set(single, 'LineWidth', 2);
        if i <= 4
            set(single, 'FaceColor', 'k');
        elseif i <= 7
            set(single, 'FaceColor', 'b');
        elseif i == 8
            set(single, 'FaceColor', 'c');
        else
            set(single, 'FaceColor', 'w');
        end
    end
    hold off
    lab = {' ', 'Nasality', 'Vowel height', 'Manner', 'Voicing', 'Contour',...
        'Vowel place', 'Vowel length', 'Affrication', 'Sibilance', 'Consonant Place', ' '};
    title('Phonemegram');
    set(gca, 'XLim', [0 11]);
    set(gca, 'XTickLabel', lab);
    axis = gca;
    axis.XTick = [0 1 2 3 4 5 6 7 8 9 10 11];
    axis.XTickLabelRotation = 30;
    set(gca, 'YLim', [0 100]);
    ylabel('Percent Correct');
    pos = get(gca, 'Position');
    pos(1) = pos(1) - 0.055;
    pos(3) = pos(3) + 0.05;
    set(gca, 'Position', pos);
	
% % %     %%%Added Sept 2021
% % %     %%%Data for phonemegram
%     for i = 1:length(histvals)
%        fprintf(fileID1,"%s\t%f \n",lab{1+i},histvals(i));
%     end
    
    subplot(2,2,2);
	title('Vowels')
	xlabel('Place')
	set(gca,'XLim',[0 8])
	ax = gca;
	ax.XTick = [0 1 2 3 4 5 6 7 8];
	ax.XTickLabelRotation = 20;
	set(gca,'XTickLabel',{' ', 'Front', ' ', ' ', 'Center', ' ', ' ', 'Back', ' '});
	ylabel('Height')
	set(gca,'YLim',[0 6])
	set(gca,'YTickLabel',{' ', 'Low', ' ', 'Mid', ' ', 'High', ' '})
	set(gca,'clim',[0,100]);
	colorbar('Ticks',linspace(0,100,11),...
		'TickLabels',{'0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'})
	pos = get(gca, 'Position');
	pos(3) = pos(3) + 0.01;
	set(gca, 'Position', pos);
    
    subplot(2,2,3)
	title('Consonants (Voiced)')
	xlabel('Place')
	set(gca,'Xlim',[0 7])
	ax = gca;
	ax.XTickLabelRotation = 20;
	set(gca,'Xticklabel',{' ', 'Bilabial', 'Labiodental', 'Lingadental', 'Alveolar', 'Palatal', 'Velar', '  '});
	label_h = ylabel('Manner');
    label_h.Position(1)=-0.75;
    label_h.Position(2)=4;
	set(gca,'ylim',[0 6])
	ax = gca;
	ax.YTickLabelRotation = 60;
	set(gca,'Yticklabel',{' ', 'Sonorant', 'Fricative', 'Affricate', 'Stop', 'Nasal', '  '});
	set(gca,'clim',[0,100]);
	colorbar('Ticks',linspace(0,100,11),...
		'TickLabels',{'0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'})
	pos = get(gca, 'Position');
	pos(1) = pos(1) - 0.055;
	pos(3) = pos(3) + 0.01;
	set(gca, 'Position', pos);
	
	subplot(2,2,4);
	title('Consonants (Unvoiced)')
	xlabel('Place')
	set(gca,'Xlim',[0 7])
	ax = gca;
	ax.XTickLabelRotation = 20;
	set(gca,'Xticklabel',{' ', 'Bilabial', 'Labiodental', 'Lingadental', 'Alveolar', 'Palatal', 'Velar', '  '});
	label_h = ylabel('Manner');
    label_h.Position(1)=-0.75;
    label_h.Position(2)=4;
	set(gca,'ylim',[0 6])
	ax = gca;
	ax.YTickLabelRotation = 60;
	set(gca,'Yticklabel',{' ', 'Sonorant', 'Fricative', 'Affricate', 'Stop', 'Nasal', '  '});
	set(gca,'clim',[0,100]);
	colorbar('Ticks',linspace(0,100,11),...
		'TickLabels',{'0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
	pos = get(gca, 'Position');
	pos(3) = pos(3) + 0.01;
	set(gca, 'Position', pos);
	print(Name, '-dpng');
	
	
	stats{casenum+1,3} = totalresponse;
	stats{casenum+1,4} = totalnum;
	stats{casenum+1,5} = toc;
    stats{casenum+1,6} = num_wordscorrect;
    stats{casenum+1,7} = num_totalwords;
    stats{casenum+1,8} = num_stimcorrect;
	format short g;
	fprintf('~~~~~~~~~~\t~~~~~~~~~~\t~~~~~~~~~~\t~~~~~~~~~~\t~~~~~~~~~~\t~~~~~~~~~~\t');
	fprintf('~~~~~~~~~~\t~~~~~~~~~~\t\n\n');
end

disp(stats)

% % % %%%Added Sept 2021
% fclose(fileID1);
% fclose(fileID2);
% fclose(fileID3);
% fclose(fileID4);
% fclose(fileID5);

end

%%%%Phonemegram
function[features] = return_features(stimph,responseph, attributemaps, features, vowels, consonants)
attributemaps_view = attributemaps;
count=0;
for i = 1 : length(stimph)
	currTrue = stimph{i};
	currResponse = responseph{i};
	memberInfoTrue = [sum(strcmp(currTrue, vowels)), ...
		sum(strcmp(currTrue, consonants))];
	memberInfoResponse = [sum(strcmp(currResponse, vowels)), ...
		sum(strcmp(currResponse, consonants))];
	if memberInfoTrue(1)   %if the current true phoneme is a vowel
       
        vfeature_indices=[2 5 6 7];
        %want to add to running count for nasality only if the true value
        %has a non zero vowel feature
        for vfi=1:length(vfeature_indices)
            if attributemaps{vfeature_indices(vfi)}(currTrue) ~= 0
                features(vfeature_indices(vfi),2) = features(vfeature_indices(vfi),2)+1;
            end
        end

		if ~memberInfoResponse(1);
			continue
		else
			%Height
			if attributemaps{2}(currTrue) == attributemaps{2}(currResponse) && attributemaps{2}(currTrue) ~= 0
				features(2,1) = features(2,1) + 1;
			end
			%Place
			if attributemaps{6}(currTrue) == attributemaps{6}(currResponse) && attributemaps{6}(currTrue) ~= 0
				features(6,1) = features(6,1) + 1;
			end
			%Length
			if attributemaps{7}(currTrue) == attributemaps{7}(currResponse) && attributemaps{7}(currTrue) ~= 0
				features(7,1) = features(7,1) + 1;
			end
			%Contour
			if attributemaps{5}(currTrue) == attributemaps{5}(currResponse) && attributemaps{5}(currTrue) ~= 0
				features(5,1) = features(5,1) + 1;
			end
		end
		
	elseif memberInfoTrue(2) %if the current true phoneme is a consonant
        
        cfeature_indices = [1 3 4 8 9 10];
        %want to add to running count for nasality only if the true value
        %is a nasal consonant
        for cfi=1:length(cfeature_indices)
            if attributemaps{cfeature_indices(cfi)}(currTrue) ~= 0
                features(cfeature_indices(cfi),2) = features(cfeature_indices(cfi),2)+1;
            end
        end
        
		if ~memberInfoResponse(2)
			continue
		else
			%Nasality
			if attributemaps{1}(currTrue) == attributemaps{1}(currResponse) && attributemaps{1}(currTrue) ~= 0 %addition to only add to accuracy if currTrue is a nasal consonant
                features(1,1) = features(1,1) + 1;
			end
			%Manner
			if attributemaps{3}(currTrue) == attributemaps{3}(currResponse) && attributemaps{3}(currTrue) ~= 0
				features(3,1) = features(3,1) + 1;
			end
			%Voicing
			if attributemaps{4}(currTrue) == attributemaps{4}(currResponse) && attributemaps{4}(currTrue) ~= 0
				features(4,1) = features(4,1) + 1;
			end
			%Affrication
			if attributemaps{8}(currTrue) == attributemaps{8}(currResponse) && attributemaps{8}(currTrue) ~= 0
				features(8,1) = features(8,1) + 1;
			end
			%Sibilance
			if attributemaps{9}(currTrue) == attributemaps{9}(currResponse) && attributemaps{9}(currTrue) ~= 0
				features(9,1) = features(9,1) + 1;
			end
			%Place
			if attributemaps{10}(currTrue) == attributemaps{10}(currResponse) && attributemaps{10}(currTrue) ~= 0
				features(10,1) = features(10,1) + 1;
			end
		end
	else  %if the current true phoneme is a space
		continue
	end
	
end

end

function[vowel_matrix, consonant_matrix] = matrix_constructor(stimph,responseph,vowels,consonants,vowel_matrix,consonant_matrix)
vowelph = {'AA','AE','AH','AO','AW','AY','EH','ER','EY','IH','IY','OW','OY','UH','UW'};
vowel_indices = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
vowel_dict = containers.Map(vowelph, vowel_indices);

consonantph = {'B','CH','D','DH','F','G','HH','JH','K','L','M','N','NG','P','R','S','SH','T','TH','V','W','Y','Z','ZH'};
consonant_indices = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
consonant_dict = containers.Map(consonantph, consonant_indices);

for i = 1 : length(stimph)
    currTrue = stimph{i};
	currResponse = responseph{i};
    memberInfoTrue = [sum(strcmp(currTrue, vowels)), ...
		sum(strcmp(currTrue, consonants))];
	memberInfoResponse = [sum(strcmp(currResponse, vowels)), ...
		sum(strcmp(currResponse, consonants))];
    if memberInfoTrue(1)   %if the current true phoneme is a vowel
        row = vowel_dict(currTrue);
        if currResponse == "qq" 
            %col = vowel_dict(currResponse);
            vowel_matrix(row,16) = vowel_matrix(row,16)+1;
        elseif currResponse == " "
            vowel_matrix(row,16) = vowel_matrix(row,16)+1;
        else
            if isKey(vowel_dict, currResponse)
                col = vowel_dict(currResponse);
            else
                col = 16;
            end
            vowel_matrix(row,col) = vowel_matrix(row,col)+1;
        end
    elseif memberInfoTrue(2) %if the current true phoneme is a consonant
        row = consonant_dict(currTrue);
        if currResponse == "qq"        
            %col = consonant_dict(currResponse);
            consonant_matrix(row,25) = consonant_matrix(row,25)+1;
        elseif currResponse == " "
            consonant_matrix(row,25) = consonant_matrix(row,25)+1;
        else
            if isKey(consonant_dict, currResponse)
                col = consonant_dict(currResponse);
            else
                col = 25;
            end
            consonant_matrix(row,col) = consonant_matrix(row,col)+1;
        end
    else  %if the current true phoneme is a space
		continue
	end
    
end


end
